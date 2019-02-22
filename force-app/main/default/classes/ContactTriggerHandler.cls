/* -----------------------------------------------------------------------------------------------------------------------
Class Name:       ContactTriggerHandler
Description:           
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
01/23/2018     1.0            Prasanth               Initial Release
-------------------------------------------------------------------------------------------------------------------------- 
*/
public with sharing class ContactTriggerHandler
{   
    public static void callMethods(List<Contact> Contacts)
    {
        if(trigger.isbefore && trigger.isinsert)
        {
            beforeInsert(Contacts);
        }
         if(trigger.isbefore && trigger.isupdate)
        {
            beforeUpdate(Contacts);
        }
    }
    
    //before Insert logic
    public static void beforeInsert(List<Contact> Contacts)
    {
        for(Contact A:Contacts)
        {
            if(A.AccountId != NULL)
            {
                A.Account_Id__c = A.AccountId;
            }
        }
    
    
    //Bulk Load via API --> Prevent duplciate records from entering system --> Start    
    Map<string, contact> retainOneMainContactEmailValid = new Map<string, contact>();
    Map<string, contact> retainOneMainContactPhoneValid = new Map<string, contact>();

    for(Contact c: Contacts){
        
        if(c.AccountId != null || c.AccountId != '')
        {
            //Check if Email repeats
            if((c.Email != null || c.Email != '') && (c.Primary_Phone__c == null || c.Primary_Phone__c == ''))
            {
                String EmailKey = c.FirstName+c.LastName+c.AccountId+c.Email;
                if(!retainOneMainContactEmailValid.containsKey(EmailKey))
                {
                    retainOneMainContactEmailValid.put(EmailKey,c);
                }
                else{
                    c.addError('Duplicate contact found , Please use another email id');
                }
            }
            
            //Check if Phone repeats
            if((c.Email == null || c.Email == '') && (c.Primary_Phone__c != null || c.Primary_Phone__c != ''))
            {
                String PhoneKey = c.FirstName+c.LastName+c.AccountId+c.Primary_Phone__c;
                if(!retainOneMainContactPhoneValid.containsKey(PhoneKey))
                {
                    retainOneMainContactPhoneValid.put(PhoneKey,c);
                }
                else{
                    c.addError('Duplicate contact found, Please use another phone number');
                }
            }    
        }   
    }
    //Bulk Load via API --> Prevent duplciate records from entering system --> End
    }     
    
    //before update logic
    public static void beforeUpdate(List<Contact> Contacts)
    {
        for(Contact A1:Contacts)
        {    
            if(A1.AccountId  !=  A1.Account_Id__c)
            {
                A1.Account_Id__c = A1.AccountId;
            }  
        }
    
   
    }       
}