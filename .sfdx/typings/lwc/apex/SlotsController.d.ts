declare module "@salesforce/apex/SlotsController.setDeferralDate" {
  export default function setDeferralDate(param: {woRecordId: any, entitlementStartDate: any, entitlementEndDate: any, sProvider: any, deferPopup: any}): Promise<any>;
}
declare module "@salesforce/apex/SlotsController.cancelScheduledSlot" {
  export default function cancelScheduledSlot(param: {woRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/SlotsController.scheduledSlot" {
  export default function scheduledSlot(param: {woRecordId: any, scheduleStartTime: any, scheduleEndTime: any}): Promise<any>;
}
declare module "@salesforce/apex/SlotsController.rescheduledSlot" {
  export default function rescheduledSlot(param: {woRecordId: any, scheduleStartTime: any, scheduleEndTime: any}): Promise<any>;
}
declare module "@salesforce/apex/SlotsController.nonSubmittedDispatch" {
  export default function nonSubmittedDispatch(param: {woRecordId: any, scheduleStartTime: any, scheduleEndTime: any}): Promise<any>;
}
declare module "@salesforce/apex/SlotsController.getScheduleSlots" {
  export default function getScheduleSlots(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/SlotsController.getDeferralSlots" {
  export default function getDeferralSlots(param: {recordId: any}): Promise<any>;
}
