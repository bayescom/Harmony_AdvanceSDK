export class DemoUtil{

  /**
   * 字符串是否为空(undefined、null、字符串长度为0)
   * @param str 被检测的字符串
   * @return 是否为空
   */
  static isEmpty(str: string | undefined | null): boolean {
    return str == undefined || str == null || str.length == 0;
  }

  /**
   * 判断字符串是否为非空。true为非空空，否则false
   * @param str
   * @returns
   */
  static isNotEmpty(str: string | undefined | null) {
    return false == DemoUtil.isEmpty(str);
  }
}
export class AdInf{
  adId:string = ''
}