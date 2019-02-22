declare module "@salesforce/apex/ARRProposalApexController.getExternalId" {
  export default function getExternalId(param: {internalId: any}): Promise<any>;
}
declare module "@salesforce/apex/ARRProposalApexController.getInternalId" {
  export default function getInternalId(param: {requestId: any}): Promise<any>;
}
declare module "@salesforce/apex/ARRProposalApexController.getOrderLink" {
  export default function getOrderLink(param: {countryCode: any}): Promise<any>;
}
declare module "@salesforce/apex/ARRProposalApexController.getCountries" {
  export default function getCountries(): Promise<any>;
}
declare module "@salesforce/apex/ARRProposalApexController.getServiceTypes" {
  export default function getServiceTypes(): Promise<any>;
}
declare module "@salesforce/apex/ARRProposalApexController.getSummary" {
  export default function getSummary(param: {proposalId: any}): Promise<any>;
}
declare module "@salesforce/apex/ARRProposalApexController.getTypes" {
  export default function getTypes(): Promise<any>;
}
declare module "@salesforce/apex/ARRProposalApexController.getBrands" {
  export default function getBrands(): Promise<any>;
}
declare module "@salesforce/apex/ARRProposalApexController.getProcessors" {
  export default function getProcessors(): Promise<any>;
}
declare module "@salesforce/apex/ARRProposalApexController.getBaseUnits" {
  export default function getBaseUnits(param: {queryString: any}): Promise<any>;
}
declare module "@salesforce/apex/ARRProposalApexController.newVrp" {
  export default function newVrp(param: {body: any}): Promise<any>;
}
declare module "@salesforce/apex/ARRProposalApexController.refreshVrp" {
  export default function refreshVrp(param: {requestId: any}): Promise<any>;
}
declare module "@salesforce/apex/ARRProposalApexController.postDispatch" {
  export default function postDispatch(param: {requestId: any}): Promise<any>;
}
declare module "@salesforce/apex/ARRProposalApexController.deleteVrp" {
  export default function deleteVrp(param: {requestId: any}): Promise<any>;
}
declare module "@salesforce/apex/ARRProposalApexController.newServiceSku" {
  export default function newServiceSku(param: {body: any}): Promise<any>;
}
declare module "@salesforce/apex/ARRProposalApexController.makeRequest" {
  export default function makeRequest(param: {type: any, url: any, body: any}): Promise<any>;
}
