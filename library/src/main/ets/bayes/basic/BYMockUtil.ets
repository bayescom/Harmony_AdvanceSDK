import { BYLog } from './BYLog'
import { BYSetting } from './BYSetting'
import { BYSingleton } from './BYSingleton'

export class BYMockUtil {
  static canMock(): boolean {
    let result = false
    result = BYSetting.get().isDev && BYSetting.get().canMock && BYSingleton.get().debug
    BYLog.debug("canMock:" + result)
    return result
  }
}