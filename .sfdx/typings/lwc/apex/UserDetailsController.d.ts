declare module "@salesforce/apex/UserDetailsController.fetchsearchuser" {
  export default function fetchsearchuser(param: {SearchUserKeyword: any, UserId: any, isAsc: any, isSort: any}): Promise<any>;
}
declare module "@salesforce/apex/UserDetailsController.fetchUserqueue" {
  export default function fetchUserqueue(param: {SearchQueueKeyword: any, usrId: any}): Promise<any>;
}
declare module "@salesforce/apex/UserDetailsController.RemoveUser" {
  export default function RemoveUser(param: {lstRecordId: any, usrId: any}): Promise<any>;
}
declare module "@salesforce/apex/UserDetailsController.Addqueue" {
  export default function Addqueue(param: {grpid: any, usrId: any}): Promise<any>;
}
declare module "@salesforce/apex/UserDetailsController.fetchLookUpValues" {
  export default function fetchLookUpValues(param: {searchKeyWord: any, ObjectName: any, ExcludeitemsList: any, UserId: any}): Promise<any>;
}
declare module "@salesforce/apex/UserDetailsController.clonequeueuser" {
  export default function clonequeueuser(param: {UserId: any, CloneId: any}): Promise<any>;
}
