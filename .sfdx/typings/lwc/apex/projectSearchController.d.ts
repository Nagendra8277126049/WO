declare module "@salesforce/apex/projectSearchController.searchProjects" {
  export default function searchProjects(param: {orderNumber: any, projectName: any, poNumber: any, customerName: any, dealId: any, dateCreatedStart: any, dateCreatedEnd: any, orderIds: any}): Promise<any>;
}
declare module "@salesforce/apex/projectSearchController.getOrderNumbers" {
  export default function getOrderNumbers(param: {orderIds: any}): Promise<any>;
}
declare module "@salesforce/apex/projectSearchController.associateOrdersToProject" {
  export default function associateOrdersToProject(param: {orderIds: any, projectId: any}): Promise<any>;
}
