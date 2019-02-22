declare module "@salesforce/apex/AddGroupMember.getGroupmembers" {
  export default function getGroupmembers(): Promise<any>;
}
declare module "@salesforce/apex/AddGroupMember.fetchLookUpValues" {
  export default function fetchLookUpValues(param: {searchKeyWord: any, ObjectName: any, groupid_s: any, label_button: any}): Promise<any>;
}
declare module "@salesforce/apex/AddGroupMember.addUsers" {
  export default function addUsers(param: {lstRecordId: any, groupid: any, buttonlabels: any}): Promise<any>;
}
declare module "@salesforce/apex/AddGroupMember.fetchGroup" {
  export default function fetchGroup(param: {searchKeyWord: any}): Promise<any>;
}
