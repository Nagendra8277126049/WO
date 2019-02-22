declare module "@salesforce/apex/AutoSelectPartController.getserviceType" {
  export default function getserviceType(param: {workOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/AutoSelectPartController.insertAndReturnWorkOrderLI" {
  export default function insertAndReturnWorkOrderLI(param: {workOrderIds: any, serviceTag: any, addressBUID: any}): Promise<any>;
}
declare module "@salesforce/apex/AutoSelectPartController.FindSelectedParts" {
  export default function FindSelectedParts(param: {selectedList: any, WorkOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/AutoSelectPartController.validateSelectedParts" {
  export default function validateSelectedParts(param: {selectedParts: any, EditRec: any, callType: any, addCFIAutoPart: any}): Promise<any>;
}
declare module "@salesforce/apex/AutoSelectPartController.saveSelectedParts" {
  export default function saveSelectedParts(param: {selectedParts: any, callType: any, manualSelectReason: any, autoAddCFIPart: any}): Promise<any>;
}
declare module "@salesforce/apex/AutoSelectPartController.getSelectedParts" {
  export default function getSelectedParts(param: {workOrderId: any}): Promise<any>;
}
