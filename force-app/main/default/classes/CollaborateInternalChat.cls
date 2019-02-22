/* -----------------------------------------------------------------------------------------------------------------------
Name:         CollaborateInternalChat 
Description:  this Controller is used by Collaborate.cmp for Story 5086637 & 5150078
Date          Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
09/24/2018     1.0     Sunil Surappagari     Initial Release

-------------------------------------------------------------------------------------------------------------------------- */  



public with sharing class CollaborateInternalChat {
    /* -----------------------------------------------------------------------------------------------------------------------
Name:         fetchUser
Description:  this functions query Current users details
-----------  -------  -----------------  ----------------------------------------------------------------------------- */  
    /*    @AuraEnabled 
public static String fetchUser(){

User oUser = [select id,FirstName, LastName, Name
FROM User Where id =: userInfo.getUserId()];
return oUser.Name;
}
/* -----------------------------------------------------------------------------------------------------------------------
Name:         fetchCaseNumber
Description:  this functions is used to query CaseNumber of current case

-----------  -------  -----------------  ------------------------------------------------------------------------------*/  
    /*      @AuraEnabled 
public static String fetchCaseNumber(String CaseId){

return [Select Id, CaseNumber From Case Where Id=: CaseId].CaseNumber;

}

/* -----------------------------------------------------------------------------------------------------------------------
Name:       getSelectedValue  
Description:  this function get the Value field of Pre_Value__C custom settings of Current User.

-------------------------------------------------------------------------------------------------------------------------- */
    @AuraEnabled
    public static String getSelectedValue() {
        Prev_Value__c p = Prev_Value__c.getInstance(UserInfo.getUserId());
        if(p != null)
            return p.Value__c;
        return null;  
    }
    /* -----------------------------------------------------------------------------------------------------------------------
Name:         saveSelectedValue
Description:  this function saves the queueName selected by user and update Value field of Prev_Value__c custom settings

-------------------------------------------------------------------------------------------------------------------------- */  
    
    
    @AuraEnabled
    public static String saveSelectedValuee(String val) {
        Prev_Value__c p = Prev_Value__c.getInstance(UserInfo.getUserId());
        if(p != null) {
            p.Value__c = val;
            upsert p;
        } else {
            Prev_Value__c pp = new Prev_Value__c(SetupOwnerId = UserInfo.getUserId(), Value__c = val);
            insert pp;
        }
        System.debug('>>>: '+p);
        return null;  
    }
    
/* -----------------------------------------------------------------------------------------------------------------------
Name:         getOptions
Description:  this function get the records from Custom Metadata type 'Queueid__mdt' */   
    
    @AuraEnabled
    public static List<WrapperForOptions> getOptions() {
        List<WrapperForOptions> listWFO = new List<WrapperForOptions>();
        List<Queueid__mdt> lstBT = [SELECT Id,Label, buttonid__c FROM Queueid__mdt limit 200];
        if(!lstBT.isEmpty()) {
            for(Queueid__mdt objBT: lstBT) {
                listWFO.add(new WrapperForOptions(objBT));
            }
        }
        if(!listWFO.isEmpty()) {
            return listWFO; 
        }
        return null;
    }
    //Wrapper for custom metadata type
    public class WrapperForOptions {
        @AuraEnabled public Queueid__mdt objB;
        public WrapperForOptions(Queueid__mdt objB) {
            this.objB = objB;         
        }
    }
   
    
    
/* -----------------------------------------------------------------------------------------------------------------------
Name:         getDependentMap
Description:  this function  will used for display of Dependent picklist on Collaborate component

-------------------------------------------------------------------------------------------------------------------------- */  
    
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    // Wrapper class for dependent picklist
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
    
    
    
}