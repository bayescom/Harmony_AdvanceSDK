import {
  BYLog,
} from 'advancesdk'
import { rcp } from '@kit.RemoteCommunicationKit'

export interface BiddingInfo {
  // 本条广告的eCPM（每一千次展示可以获得的广告收入）
  price: number;
  // 本条广告的价格币种
  cur: string;
  // 媒体回传竞价成功结果的URL
  nurl: string;
  // 媒体回传竞价失败结果的URL
  lurl: string;
}

const TAG = `[AdvHuaweiUtil] `

export class AdvHuaweiUtil {
  
}

export async function sendBiddingResult(url: string): Promise<void> {
  let session: rcp.Session | undefined = undefined;
  try {
    session = rcp.createSession();
    await session.get(url);
  } catch (e) {
    BYLog.debug(`Failed to send bidding result. Code is ${e.code}, message is ${e.message}`);
  } finally {
    session?.close();
  }
}

