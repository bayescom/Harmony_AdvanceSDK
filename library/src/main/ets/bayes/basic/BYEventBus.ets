import { emitter } from '@kit.BasicServicesKit';
import { BYLog } from './BYLog';

//窗口焦点恢复，此时需要进行传感器得重监听
export const BY_EVENT_KEY_WINDOW_FOCUS_RESUME = 'focusResumeWindow'
export const BY_EVENT_KEY_WINDOW_FOCUS_LOST = 'focusLostWindow'
export const BY_EVENT_KEY_APP_STATE_CHANGE = 'appStateChange'
// export const MERCURY_EVENT_KEY_APP_PAUSE = 'appOnPause'

/// 事件通知工具类
export abstract class BYEventBus {
  static send(eventKey: string, eventData?: Object | Record<string, Object> | null,) {
    try {
      let data: string | undefined
      if (eventData !== null && eventData !== undefined) {
        if (typeof eventData === 'string') {
          data = eventData
        } else {
          data = JSON.stringify(eventData)
        }
      }

      BYLog.devDebug(` BYEventBus send eventKey:${eventKey}, data:${eventData} `)

      emitter.emit(BYEventBus.generateEventID(eventKey), { priority: emitter.EventPriority.IMMEDIATE }, {
        data: {
          'data': data
        }
      },);
    } catch (e) {
    }

  }

  static listen<T>(eventKey: string, callback: (data?: T) => void,) {
    try {
      emitter.once(BYEventBus.generateEventID(eventKey), (eventData: emitter.EventData) => {
        try {
          let data: string | undefined = eventData.data!['data']
          if (data == undefined) {
            callback(undefined)
          } else {
            if (data.startsWith("{") && data.endsWith("}")) {
              callback(JSON.parse(data) as T)
            } else {
              callback(data as T)
            }
          }
        } catch (e) {
        }
      });
    } catch (e) {
    }
  }

  //注意此状态下需要结束后，调用cancel主动取消监听
  static listenOn<T>(eventKey: string, callback: (data?: T) => void,) {
    try {
      emitter.on(BYEventBus.generateEventID(eventKey), (eventData: emitter.EventData) => {
        try {
          let data: string | undefined = eventData.data!['data']
          if (data == undefined) {
            callback(undefined)
          } else {
            if (data.startsWith("{") && data.endsWith("}")) {
              callback(JSON.parse(data) as T)
            } else {
              callback(data as T)
            }
          }
        } catch (e) {
        }
      });
    } catch (e) {
    }
  }

  static cancel<T>(eventKey: string, callback?: (data?: T) => void) {
    try {
      if (callback) {
        emitter.off(BYEventBus.generateEventID(eventKey),callback);
      }else {
        emitter.off(BYEventBus.generateEventID(eventKey));
      }
    } catch (e) {
    }
  }

  static generateEventID(key: string): string {
    return `BYEvent_${key}`
  }
}