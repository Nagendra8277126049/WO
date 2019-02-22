declare module "@salesforce/apex/DispatchApproveRejectController.ApproveDispatch" {
  export default function ApproveDispatch(param: {recordId: any, approveReason: any, approveComment: any}): Promise<any>;
}
declare module "@salesforce/apex/DispatchApproveRejectController.RejectDispatch" {
  export default function RejectDispatch(param: {recordId: any, rejectReason: any, rejectComment: any}): Promise<any>;
}
