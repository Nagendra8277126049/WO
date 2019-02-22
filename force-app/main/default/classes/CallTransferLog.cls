public class CallTransferLog {
 @AuraEnabled
public static CTAttrWrapper getCTAttrRec(String ucid) {
    try
    {
        CTAttrWrapper CTAttrWrapper = new  CTAttrWrapper (); 
        if (!String.isEmpty(ucid)){
            CTAttrWrapper.CTAttr = [Select Name,Created_By__c,Category__c,CreatedById,Transfer_Reason__c,Transferred_To_Queue__c from Call_Transfer_Attributes__c where Status__c = 'Completed' AND Call_UCID__c =: ucid];
            System.debug('CTAttrWrapper.CTAttr' +CTAttrWrapper.CTAttr);
       }
        else
            CTAttrWrapper.CTAttr = new List<Call_Transfer_Attributes__c>();

        CTAttrWrapper.logSize = CTAttrWrapper.CTAttr.size(); 
        CTAttrWrapper.headerMsg = Label.voiceCTAttrHeaderMsg;
        return CTAttrWrapper;
    }
    catch(Exception e)
        { system.debug('Error Message : '+e.getMessage()); return null;}
	}
     public class CTAttrWrapper{
        @AuraEnabled public List<Call_Transfer_Attributes__c> CTAttr {get;set;}
        @AuraEnabled public Integer logSize{get;set;}
        @AuraEnabled public String headerMsg {get;set;}
    }
    
}