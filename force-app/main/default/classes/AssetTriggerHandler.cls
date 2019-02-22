/* -----------------------------------------------------------------------------------------------------------------------
Class Name:       AssetTriggerHandler
Description:           
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
01/03/2017     1.0              Sonia               Initial Release
-------------------------------------------------------------------------------------------------------------------------- 
*/
public with sharing class AssetTriggerHandler
{   
    public static void callMethods(List<Asset> Assets)
    {
        if(trigger.isbefore && trigger.isinsert)
        {
        beforeInsert(Assets);
        }
         if(trigger.isbefore && trigger.isupdate)
        {
        beforeUpdate(Assets);
        }
    }
    //before Insert logic
    public static void beforeInsert(List<Asset> Assets)
    {
        for(Asset A:Assets)
        {
            if(A.Parent_Asset_Id__c != NULL)
            {
                A.ParentId = A.Parent_Asset_Id__c;
            }
        } 
    }     
    
    //before update logic
    public static void beforeUpdate(List<Asset> Assets)
    {
        for(Asset A1:Assets)
        {    
            if(A1.Parent_Asset_Id__c  !=  A1.ParentId)
            {
                A1.ParentId = A1.Parent_Asset_Id__c;
            }  
        }
        
    }       
}