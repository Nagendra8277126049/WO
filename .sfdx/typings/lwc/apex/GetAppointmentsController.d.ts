declare module "@salesforce/apex/GetAppointmentsController.getSA" {
  export default function getSA(param: {serviceAppointmentId: any}): Promise<any>;
}
declare module "@salesforce/apex/GetAppointmentsController.getAppointmentsCallout" {
  export default function getAppointmentsCallout(param: {saId: any}): Promise<any>;
}
declare module "@salesforce/apex/GetAppointmentsController.processTaskExCallout" {
  export default function processTaskExCallout(param: {saId: any, slot: any, isSLA: any, isAppointmentTask: any}): Promise<any>;
}
