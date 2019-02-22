declare module "@salesforce/apex/OrderImporterController.importOrder" {
  export default function importOrder(param: {orderNumbers: any, buid: any, projectId: any}): Promise<any>;
}
declare module "@salesforce/apex/OrderImporterController.getImportQueue" {
  export default function getImportQueue(param: {projectId: any}): Promise<any>;
}
declare module "@salesforce/apex/OrderImporterController.validateImportOrder" {
  export default function validateImportOrder(param: {orderNumber: any, buid: any, projectId: any}): Promise<any>;
}
