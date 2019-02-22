declare module "@salesforce/apex/OmniListener.queueCheck" {
  export default function queueCheck(param: {workId: any, workItemId: any}): Promise<any>;
}
