declare module "@salesforce/apex/DispatchDefaultsConfiguration.getDispatchDefaults" {
  export default function getDispatchDefaults(param: {workOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/DispatchDefaultsConfiguration.updateDefaultsRecord" {
  export default function updateDefaultsRecord(param: {recordId: any, defaultRecId: any, serTypeValue: any, serOptionValue: any, speOptionvalue: any, prodClassValue: any, kYcompvalue: any, accDamageValue: any, dSPOverideValue: any, billToValue: any, OrderNumber: any, servOptionPicklist: any, instructions: any, dspInstrnRecId: any, kyhdFlag: any, KYHDFlagChangedTrue: any, ADOverrideReason: any, accDamageFlag: any, altReturnAddressFlag: any, altReturnAddressStreet: any, altReturnAddressPostalCode: any, altReturnAddressCity: any, altReturnAddressState: any, altReturnAddressCountry: any, reasonForDamage: any, DASPValue: any, DSPSelectedfromDASP: any, KoreaMonitor: any}): Promise<any>;
}
declare module "@salesforce/apex/DispatchDefaultsConfiguration.getBillToAvailableOptions" {
  export default function getBillToAvailableOptions(param: {recordId: any, billToFlag: any, serviceType: any, selectedServiceOption: any, DASP: any}): Promise<any>;
}
declare module "@salesforce/apex/DispatchDefaultsConfiguration.getEntitlementSLA" {
  export default function getEntitlementSLA(param: {wONumber: any, serviceOpt: any, pCode: any, country: any, state_code: any}): Promise<any>;
}
declare module "@salesforce/apex/DispatchDefaultsConfiguration.updateDispatchDefaults" {
  export default function updateDispatchDefaults(param: {workOrderId: any, dDefaultRecId: any}): Promise<any>;
}
declare module "@salesforce/apex/DispatchDefaultsConfiguration.getWOdata" {
  export default function getWOdata(param: {WorkOrderId: any, ServiceType: any, SvcOptions: any, DASP: any}): Promise<any>;
}
declare module "@salesforce/apex/DispatchDefaultsConfiguration.getServiceTypesBasedBillTo" {
  export default function getServiceTypesBasedBillTo(param: {dDRecId: any, billToFlag: any}): Promise<any>;
}
declare module "@salesforce/apex/DispatchDefaultsConfiguration.fetchCountryAndStateMap" {
  export default function fetchCountryAndStateMap(): Promise<any>;
}
declare module "@salesforce/apex/DispatchDefaultsConfiguration.calculateServiceOption" {
  export default function calculateServiceOption(param: {workOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/DispatchDefaultsConfiguration.getDASPValue" {
  export default function getDASPValue(param: {CountryCode: any}): Promise<any>;
}
