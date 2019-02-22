declare module "@salesforce/apex/DispatchManualPartSelection.getCommodities" {
  export default function getCommodities(param: {recordId: any, assetId: any, serviceTag: any, addressBUID: any}): Promise<any>;
}
declare module "@salesforce/apex/DispatchManualPartSelection.getReplacementParts" {
  export default function getReplacementParts(param: {WorkOrderId: any, assetId: any, serviceTag: any, addressBUID: any, listCommodities: any, searchText: any}): Promise<any>;
}
declare module "@salesforce/apex/DispatchManualPartSelection.validateSelectedParts" {
  export default function validateSelectedParts(param: {selectedParts: any, manualSelectReason: any, autoAddCFIPartForHardDrive: any}): Promise<any>;
}
declare module "@salesforce/apex/DispatchManualPartSelection.getManualSelectionReason" {
  export default function getManualSelectionReason(param: {WorkOrderId: any}): Promise<any>;
}
