declare module "@salesforce/apex/CallTransferHandler.GetTransferCount" {
  export default function GetTransferCount(param: {ctId: any, Agent_Id: any, IVR_Input: any}): Promise<any>;
}
declare module "@salesforce/apex/CallTransferHandler.getCallTransferAttrId" {
  export default function getCallTransferAttrId(param: {CallTranscriptId: any}): Promise<any>;
}
declare module "@salesforce/apex/CallTransferHandler.CallBRE_API" {
  export default function CallBRE_API(param: {RecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CallTransferHandler.UpdateTransferCount" {
  export default function UpdateTransferCount(param: {ctaId: any}): Promise<any>;
}
