import promptAction from '@ohos.promptAction'
import WindowUtils from './WindowUtils'

export function toast(message: string | Resource) {
  if (message) {
    const bottom = WindowUtils.windowHeight > 0 ? (WindowUtils.windowHeight / 2 + 'px') : undefined;
    promptAction.showToast({
      message: message,
      bottom: bottom
    })
  }
}


export function logToast(message: string) {
  let DEMO_TAG = "[ADVANCE_DEMO]"
  console.log(DEMO_TAG + message)
  toast(message)
}
