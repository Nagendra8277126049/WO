declare module "@salesforce/apex/DispatchGccConfiguration.getGccConfigurations" {
  export default function getGccConfigurations(param: {workOrderId: any, CountryCode: any}): Promise<any>;
}
declare module "@salesforce/apex/DispatchGccConfiguration.saveGccDSPUpdate" {
  export default function saveGccDSPUpdate(param: {workOrderId: any, DSPCode: any, DSPName: any}): Promise<any>;
}
declare module "@salesforce/apex/DispatchGccConfiguration.checkBussinessHourLogic" {
  export default function checkBussinessHourLogic(param: {EntStartDate: any, Country: any}): Promise<any>;
}
