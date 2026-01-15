import { AdvanceADNUnitData } from './AdvanceADNUnitData';
import { NodeController } from '@kit.ArkUI';
import { BYLog } from '../../../basic/BYLog';
import { AdvanceAdnResult } from '../../model/AdvanceSendModel';
import { AdvanceRenderOption } from '../../config/AdvanceOption';
import { AdvanceBaseEventListener } from '../AdvanceOpenListener';
import { BYStrUtil } from '../../../basic/util/BYStrUtil';
import AdvanceNet from '../../net/AdvanceRequest';
import { AdvanceUtil } from '../AdvanceUtil';
import { taskpool } from '@kit.ArkTS';
import { AdvanceError } from '../../model/AdvanceError';

export abstract class AdvanceADNCommonAdapter {
  //渠道参数
  unitData: AdvanceADNUnitData
  appContext: Context
  baseListener?: AdvanceBaseEventListener

  constructor(supData: AdvanceADNUnitData, context: Context) {
    this.unitData = supData
    this.appContext = context
    BYLog.debug('AdvanceADNCommonAdapter init')
  }


  /**
   *  loadAd 子类抽象实现模板
   *
   *
   loadAd(): Promise<AdvanceAdnResult> {
   BYLog.devDebug(TAG + ` loadAd start`)
   return new Promise<AdvanceAdnResult>(async (resolve, reject) => {
   let result = new AdvanceAdnResult()
   try {
   } catch (e) {
   BYLog.printE(e)
   if (result.resultStatus >= 0) {
   return
   }
   result.errCode = ADV_ERR_EXCEPTION_LOAD
   result.errMsg = 'adn请求时，代码异常'
   resolve(result)
   }

   })
   }

   * @returns
   */

  abstract loadAd(): Promise<AdvanceAdnResult>

  abstract showAd(advanceRenderOP: AdvanceRenderOption)

  abstract getAdComponent(): NodeController | undefined

  callAdRenderSuccess() {
    this.baseListener?.onRenderSuccess()
  }

  callAdRenderFailed(err: AdvanceError) {
    this.baseListener?.onRenderFail(err)
    this.reportRenderErr(err)
  }

  callAdShow() {
    this.baseListener?.onShow()
    this.reportShow()
  }

  callAdClick() {
    this.baseListener?.onClick()
    this.reportClick()
  }

  // todo 去重
  private reportShow() {
    try {
      let urls = this.unitData.supplier?.imptk
      if (urls) {
        taskpool.execute(reportAdnShow, urls)
      }
    } catch (e) {
    }

  }

  // todo 去重
  private reportClick() {
    try {
      let urls = this.unitData.supplier?.clicktk
      if (urls) {
        taskpool.execute(reportAdnClick, urls)
      }
    } catch (e) {
    }
  }

  private reportRenderErr(err: AdvanceError) {
    try {
      let urls = this.unitData.supplier?.failedtk
      if (urls) {
        taskpool.execute(reportAdnRenderErr, urls, err)
      }
    } catch (e) {
    }
  }
}


@Concurrent
function reportAdnRenderErr(urlList: string[], err: AdvanceError) {
  try {
    if (!urlList) {
      BYLog.debug('reportAdnRenderErr null')
      return
    }
    BYLog.debug(`广告曝光失败上报发起`)
    for (let index = 0; index < urlList.length; index++) {
      const element = urlList[index];
      if (BYStrUtil.isNotEmpty(element)) {
        BYLog.debug('start reportAdnRenderErr')
        let url = AdvanceUtil.appendFailedReason(element, err)
        AdvanceNet.get().reportUrl(AdvanceUtil.getTimeReplacedTk(url))
      }
    }
  } catch (e) {
    BYLog.printE(e)
  }
}

@Concurrent
function reportAdnShow(urlList: string[]) {
  try {
    if (!urlList) {
      BYLog.debug('reportAdnShow null')
      return
    }
    BYLog.debug(`广告曝光成功上报发起`)
    for (let index = 0; index < urlList.length; index++) {
      const element = urlList[index];
      if (BYStrUtil.isNotEmpty(element)) {
        BYLog.debug('start reportAdnShow')
        AdvanceNet.get().reportUrl(AdvanceUtil.getTimeReplacedTk(element))
      }
    }
  } catch (e) {
    BYLog.printE(e)
  }
}

@Concurrent
function reportAdnClick(urlList: string[]) {
  try {
    if (!urlList) {
      BYLog.debug('reportAdnClick null')
      return
    }
    BYLog.debug(`广告点击成功上报发起`)
    for (let index = 0; index < urlList.length; index++) {
      const element = urlList[index];
      if (BYStrUtil.isNotEmpty(element)) {
        BYLog.debug('start reportAdnClick')
        AdvanceNet.get().reportUrl(AdvanceUtil.getTimeReplacedTk(element))
      }
    }
  } catch (e) {
    BYLog.printE(e)
  }
}