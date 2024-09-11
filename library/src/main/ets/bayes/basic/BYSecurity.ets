
import util from '@ohos.util';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

const KEY = "bayescom1000000w"

export class BYSecurity {
  static async encrypt(content: string ): Promise<string> {
    try {
      //0.base64
      let that = new util.Base64Helper();
      //1.创建密钥生成器
      let generator = cryptoFramework.createSymKeyGenerator('AES128')
      //2.使用密钥生成器将密钥转换成 cryptoFramework.SymKey
      let key = await generator.convertKey({ data: BYSecurity.stringToUint8Array(KEY) })
      //3.创建cipher
      let aesCipher = cryptoFramework.createCipher('AES128|ECB|PKCS5')
      //4.init cipher
      await aesCipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, key, BYSecurity.genIvParamsSpec())
      //5.aes 加密
      let encryptText = await aesCipher.doFinal({ data: BYSecurity.stringToUint8Array(content) })
      // return that.encodeToStringSync(encryptText.data,util.Type.BASIC_URL_SAFE)
      return that.encodeToStringSync(encryptText.data)
    } catch (error) {
      return ''
    }
  }


  static async decrypt(content: string): Promise<string> {
    try {
      //0.base64
      let that = new util.Base64Helper();
      //1.创建密钥生成器
      let generator = cryptoFramework.createSymKeyGenerator('AES128')
      //2.使用密钥生成器将密钥转换成 cryptoFramework.SymKey
      let key = await generator.convertKey({ data: BYSecurity.stringToUint8Array(KEY) })
      //3.创建cipher
      let aesCipher = cryptoFramework.createCipher('AES128|ECB|PKCS5')
      //4.init cipher
      await aesCipher.init(cryptoFramework.CryptoMode.DECRYPT_MODE, key, BYSecurity.genIvParamsSpec())
      //5.解密
      let clearText = await aesCipher.doFinal({ data: BYSecurity.stringToUint8Array(content) })
      //6.返回解密结果
      return that.encodeToStringSync(clearText.data)
    } catch (error) {
      return ''
    }
  }

  static stringToUint8Array(str: string) {
    let arr: Array<number> = [];
    for (let i = 0, j = str.length; i < j; ++i) {
      arr.push(str.charCodeAt(i));
    }
    let tempArray = new Uint8Array(arr);
    return tempArray;
  }

  static uint8ArrayToString(array: Uint8Array) {
    let arrayString = '';
    for (let i = 0; i < array.length; i++) {
      arrayString += String.fromCharCode(array[i]);
    }
    return arrayString;
  }

  static genIvParamsSpec() {
    let arr = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]; // 16 bytes
    let dataIv = new Uint8Array(arr);
    let ivBlob: cryptoFramework.DataBlob = { data: dataIv };
    let ivParamsSpec: cryptoFramework.IvParamsSpec = {
      algName: "IvParamsSpec",
      iv: ivBlob
    };
    return ivParamsSpec;
  }
}
