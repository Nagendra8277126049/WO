declare module "@salesforce/apex/PhoneCheck.check" {
  export default function check(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/PhoneCheck.getCaseDetails" {
  export default function getCaseDetails(param: {cId: any}): Promise<any>;
}
