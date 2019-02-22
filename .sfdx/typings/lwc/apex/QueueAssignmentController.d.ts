declare module "@salesforce/apex/QueueAssignmentController.fetchSearchQueueUser" {
  export default function fetchSearchQueueUser(param: {SearchUserKeyword: any, grpId: any}): Promise<any>;
}
declare module "@salesforce/apex/QueueAssignmentController.fetchQueue" {
  export default function fetchQueue(param: {SearchQueueKeyword: any}): Promise<any>;
}
declare module "@salesforce/apex/QueueAssignmentController.fetchQueueUser" {
  export default function fetchQueueUser(param: {grpId: any}): Promise<any>;
}
declare module "@salesforce/apex/QueueAssignmentController.RemoveUser" {
  export default function RemoveUser(param: {lstRecordId: any, grpid: any}): Promise<any>;
}
declare module "@salesforce/apex/QueueAssignmentController.fetchLookUpValues" {
  export default function fetchLookUpValues(param: {searchKeyWord: any, ObjectName: any, ExcludeitemsList: any, lstofgm: any, CloneId: any}): Promise<any>;
}
declare module "@salesforce/apex/QueueAssignmentController.addusers" {
  export default function addusers(param: {UserId: any, grpid: any}): Promise<any>;
}
