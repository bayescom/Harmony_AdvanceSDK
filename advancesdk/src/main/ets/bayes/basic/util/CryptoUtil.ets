import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { crypto } from './crypto';
import { buffer, util } from '@kit.ArkTS';

/**
 * 加解密公用工具类
 */
export class CryptoUtil {


  /**
   * 摘要，异步
   * @param data 待摘要的数据
   * @param algName 摘要算法名（SHA1、SHA224、SHA256、SHA384、SHA512、MD5、SM3）。
   * @param resultCoding 摘要的编码方式(base64/hex)
   * @returns
   */
  static async digest(data: string, algName: string, resultCoding: crypto.BhCoding = 'hex'): Promise<string> {
    let md = cryptoFramework.createMd(algName);
    //数据量较少时，可以只做一次update，将数据全部传入，接口未对入参长度做限制
    await md.update({ data: CryptoUtil.strToUint8Array(data, 'utf-8') });
    let dataBlob = await md.digest();
    let result = CryptoUtil.uint8ArrayToStr(dataBlob.data, resultCoding);
    return result;
  }


  /**
   * 字符串转Uint8Array
   * @param symKey 字符串
   * @param coding 编码方式(base64/hex/utf8/utf-8)。
   * @returns
   */
  static strToUint8Array(str: string, coding: crypto.BhuCoding): Uint8Array {
    if (coding === 'base64') { //base64
      return CryptoUtil.decodeBase64Sync(str);
    } else if (coding === 'hex') { //hex-16进制类型
      return CryptoUtil.strToHex(str);
    } else {
      return CryptoUtil.strToUint8ArrayElse(str, coding);
    }
  }


  /**
   * Uint8Array转字符串
   * @param arr Uint8Array
   * @param coding 编码方式(base64/hex/utf8/utf-8)。
   * @returns
   */
  static uint8ArrayToStr(arr: Uint8Array, coding: crypto.BhuCoding): string {
    if (coding === 'base64') { //base64
      return CryptoUtil.encodeToStrSync(arr);
    } else if (coding === 'hex') { //hex-16进制类型
      return CryptoUtil.hexToStr(arr);
    } else {
      return CryptoUtil.unit8ArrayToStrElse(arr, coding);
    }
  }


  /**
   * 解码，通过输入参数解码后输出对应Uint8Array对象。
   * @param array
   * @returns
   */
  static decodeBase64Sync(array: Uint8Array | string, options?: util.Type): Uint8Array {
    let base64 = new util.Base64Helper();
    let result = base64.decodeSync(array, options);
    return result;
  }


  /**
   * 编码，通过输入参数编码后输出对应文本。
   * @param array
   * @returns
   */
  static encodeToStrSync(array: Uint8Array, options?: util.Type): string {
    let base64 = new util.Base64Helper();
    let result = base64.encodeToStringSync(array, options);
    return result;
  }

  /**
   * 16进制字符串转换unit8Array
   * @param hexStr
   * @returns
   */
  static strToHex(hexStr: string): Uint8Array {
    return new Uint8Array(buffer.from(hexStr, 'hex').buffer);
  }

  /**
   * 16进制unit8Array转字符串
   * @param arr
   * @returns
   */
  static hexToStr(arr: Uint8Array): string {
    return buffer.from(arr).toString('hex');
  }

  /**
   * 字符串转Uint8Array
   * @param src 字符串
   * @returns Uint8Array
   */
  public static strToUint8ArrayElse(src: string, encoding: buffer.BufferEncoding = 'utf-8'): Uint8Array {
    let textEncoder = new util.TextEncoder(encoding);
    let result = textEncoder.encodeInto(src);
    return result;
  }

  /**
   * Uint8Array转字符串
   * @param src Uint8Array
   * @returns 字符串
   */
  static unit8ArrayToStrElse(src: Uint8Array, encoding: buffer.BufferEncoding = 'utf-8'): string {
    let textDecoder = util.TextDecoder.create(encoding, { ignoreBOM: true })
    let result = textDecoder.decodeWithStream(src, { stream: true });
    return result;
  }


}