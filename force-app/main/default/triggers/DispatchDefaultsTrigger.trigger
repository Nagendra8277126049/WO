trigger DispatchDefaultsTrigger on DispatchDefaults__c(before insert, after insert, before update, after update,after delete) {

    if(Trigger.isAfter && !Trigger.isDelete){
      List<DispatchDefaults__c> dispatchs = Trigger.new;
      EinsteinAlertController.adAlertByDispatch(dispatchs);
    }
    
    if(Trigger.isDelete){
      List<DispatchDefaults__c> dispatchs = Trigger.old;
      EinsteinAlertController.adAlertByDispatch(dispatchs);
    }
    
    if (!(Trigger_Execution_Control__c.getInstance().Skip_DispatchDefault_Trigger__c)) {// Added By Harsha - To disable Triggers Based on Custom Setting
        if (Trigger.isBefore && Trigger.isInsert && !Trigger.isDelete) {
            /*

            list < DispatchDefaults__c > newDDList = new List < DispatchDefaults__c > ();

            for (DispatchDefaults__c DD: Trigger.New) {

                //if(DD.Complete_Care_Option__c){ MB: commented
                newDDList.add(DD);
                //}
            }
            //system.debug('newDDList ###' + newDDList);
            if (newDDList.size() > 0) {
                DispatchDefaultHelper.ADdispatchValidation(newDDList);
            }
            */
            DispatchDefaultHelper.ADdispatchValidation(Trigger.New);
        }

        if (Trigger.isAfter && !Trigger.isDelete){
        
            Set <Id> WoIds = new Set<Id>();
            for (DispatchDefaults__c dd: Trigger.new) {
                WoIds.add(dd.Work_Order__c);
            }
            if(Trigger.isUpdate) {
            DispatchDefaultHelper.InsertCustomerReminders(WoIds);
            }
            
            Set <Id> ddWithServiceOptionsIdSet = new Set<Id>();
            for (DispatchDefaults__c dd: Trigger.new) {
                if(string.isNotBlank(dd.selected_service_option__c) && string.isNotBlank(dd.Country__c) && dd.Country__c.equalsIgnoreCase('US'))
                    ddWithServiceOptionsIdSet.add(dd.Work_Order__c);
            }
            
            if((Trigger.isUpdate || Trigger.isInsert) && ddWithServiceOptionsIdSet.size() > 0) {
                    DispatchDefaultHelper.populateCFINumCheckOnWO(WoIds);
            }
        }
    }
}