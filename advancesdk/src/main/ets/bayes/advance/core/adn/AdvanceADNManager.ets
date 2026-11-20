import { AdvanceADNUnitData, AdvanceCommonAdapter } from './AdvanceCommonAdapter'
import { AdvanceSupplierModel } from '../../model/AdvanceNetModel'
import { AdvanceAdnInitState } from '../../define/AdvanceDefine'
import { AdvanceError, ADV_ERR_ADN_INIT_FAILED, ADV_ERR_ADN_UNINSTALLED,
  ADV_ERR_CUSTOM_ADN_LOAD_FAILED } from '../../define/AdvanceError'
import { BusinessError } from '@kit.BasicServicesKit'
import { AdvanceAdapterRepository } from './AdvanceAdapterRepository'


// 定义队列里存放的 Promise 触发器结构
interface PromiseHandler {
  resolve: (value: AdvanceError | undefined) => void;
  reject?: (reason: Error) => void;
}

export class AdvanceADNManager {
  // 状态表：平台id -> 当前初始化状态
  static initializeStatus: Map<string, AdvanceAdnInitState> = new Map();
  // 回调队列：平台 id -> 挂起的 Promise 控制器数组
  static pendingCompletions: Map<string, Array<PromiseHandler>> = new Map();

  //生成对应adapter实现类
  static async generateAdnAdapter(adnData: AdvanceADNUnitData): Promise<AdvanceCommonAdapter | undefined> {
    const descriptor = AdvanceAdapterRepository.descriptorForSupplierId(adnData.adnId)
    const className = descriptor?.adapters.get(adnData.adType)
    if (!descriptor?.moduleName || !className) {
      return undefined
    }
    try {
      const ns: ESObject = await import(descriptor.moduleName);
      const AdapterClass: ESObject = ns[className];
      // 如果类存在则实例化并返回，否则返回 undefined
      return AdapterClass ? new AdapterClass(adnData) : undefined;
    } catch (error) {
      // 捕获 import 失败或者 new 失败的异常
      return undefined;
    }
  }

  // 加载渠道SDK进行初始化调用
  static async loadADN(supplier: AdvanceSupplierModel): Promise<AdvanceError | undefined> {
    const supplierId: string = supplier.id;

    // 1. 初始化该平台的队列与状态
    if (!AdvanceADNManager.pendingCompletions.has(supplierId)) {
      AdvanceADNManager.pendingCompletions.set(supplierId, []);
      AdvanceADNManager.initializeStatus.set(supplierId, AdvanceAdnInitState.default);
    }

    const currentState = AdvanceADNManager.initializeStatus.get(supplierId);

    // 2. 已经初始化成功，直接返回成功 (利用 async 特性直接 return)
    if (currentState === AdvanceAdnInitState.success) {
      return undefined;
    }

    // 3. 正在初始化中（并发进来的请求），就在这里原地生成一个 Promise 并挂起
    if (currentState === AdvanceAdnInitState.loading) {
      return await new Promise<AdvanceError | undefined>((resolve) => {
        // 仅仅把 resolve 塞入队列，不触发任何初始化动作，原地 await 静静等待
        AdvanceADNManager.pendingCompletions.get(supplierId)!.push({ resolve });
      });
    }

    // 4. 首次进来，或者之前失败了重试 -> 走真正的初始化流程
    AdvanceADNManager.initializeStatus.set(supplierId, AdvanceAdnInitState.loading);
    try {
      // 动态加载适配
      const descriptor = AdvanceAdapterRepository.descriptorForSupplierId(supplierId);
      const harName = descriptor?.moduleName ?? '';
      const className = descriptor?.configAdapterName ?? '';

      const ns: ESObject = await import(harName);
      const AdapterClass: ESObject = ns[className];

      // 媒体未引入渠道SDK或Adapter
      if (!AdapterClass) {
        AdvanceADNManager.initializeStatus.set(supplierId, AdvanceAdnInitState.failed);
        const error = supplier.is_custom_adn === 1
          ? new AdvanceError(ADV_ERR_CUSTOM_ADN_LOAD_FAILED, `自定义Adn配置类获取失败【请检查配置类是否在模块的Index文件中被导出】`)
          : new AdvanceError(ADV_ERR_ADN_UNINSTALLED, `渠道SDK未被安装【请检查配置类是否在模块的Index文件中被导出】`);
        // 当前请求与已经排队的请求都返回相同的失败结果。
        AdvanceADNManager.executePendingCompletions(supplier, error);
        return error;
      }

      // 作为“第一个发起者”，要把自己塞进队列里，同时去 await 初始化结果
      return await new Promise<AdvanceError | undefined>((resolve) => {
        // 先把自己塞进队列
        AdvanceADNManager.pendingCompletions.get(supplierId)!.push({ resolve });
        try {
          // 开始触发三方 SDK 初始化
          AdapterClass.initializeAdapter(supplier.mediaid, supplier.mediakey,
            (error: BusinessError<void> | undefined) => {
              // 更改全局状态
              AdvanceADNManager.initializeStatus.set(supplierId,
                error ? AdvanceAdnInitState.failed : AdvanceAdnInitState.success);
              // 批量引爆队列（包含自己和所有在步骤 3 挂起排队的并发请求）
              AdvanceADNManager.executePendingCompletions(supplier, error);
            });
        } catch (syncError) {
          // 捕获三方 SDK 同步崩溃异常，转为失败并强行引爆队列，防止所有人卡死
          AdvanceADNManager.initializeStatus.set(supplierId, AdvanceAdnInitState.failed);
          const errObj: BusinessError = {
            code: ADV_ERR_ADN_INIT_FAILED,
            name: 'SyncError',
            message: syncError instanceof Error ? syncError.message : String(syncError)
          };
          AdvanceADNManager.executePendingCompletions(supplier, errObj);
        }
      });

    } catch (error) {
      // 捕获 import 失败或其他未知崩溃
      AdvanceADNManager.initializeStatus.set(supplierId, AdvanceAdnInitState.failed);
      AdvanceADNManager.executePendingCompletions(supplier, error as BusinessError);
      return new AdvanceError(ADV_ERR_ADN_INIT_FAILED, `初始化异常: ${error.message}`);
    }
  }

  // 执行所有等待中的回调
  static executePendingCompletions(supplier: AdvanceSupplierModel, error: BusinessError | AdvanceError | undefined): void {
    const queue = AdvanceADNManager.pendingCompletions.get(supplier.id);
    if (!queue || queue.length === 0) return;

    // 浅拷贝一份回调列表，防重入导致崩溃
    const completionsToTrigger = [...queue];
    queue.length = 0; // 清空历史队列

    // 一次性批量引爆这些挂起的 Promise 触发器
    completionsToTrigger.forEach((handler) => {
      if (!error) {
        handler.resolve(undefined);
      } else if (error instanceof AdvanceError) {
        handler.resolve(error);
      } else {
        handler.resolve(new AdvanceError(ADV_ERR_ADN_INIT_FAILED,
          `${supplier.name}初始化失败：code: ${error.code}, msg: ${error.message}`))
      }
    });
  }

  //获取ADN版本号
  static async getSDKVersion(supplierId: string): Promise<string | undefined> {
    const descriptor = AdvanceAdapterRepository.descriptorForSupplierId(supplierId)
    if (!descriptor?.moduleName || !descriptor.configAdapterName) {
      return undefined
    }
    try {
      const ns: ESObject = await import(descriptor.moduleName);
      const AdapterClass: ESObject = ns[descriptor.configAdapterName];
      return AdapterClass ? AdapterClass.getSDKVersion() : undefined;
    } catch (error) {
      return undefined;
    }
  }

}
