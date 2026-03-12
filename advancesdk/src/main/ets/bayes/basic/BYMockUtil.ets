import { BYLog } from './BYLog'
import { BYSetting } from './BYSetting'

export class BYMockUtil {
  static canMock(): boolean {
    let result = false
    result = BYSetting.get().isDev && BYSetting.get().canMock
    BYLog.debug("canMock:" + result)
    return result
  }
}