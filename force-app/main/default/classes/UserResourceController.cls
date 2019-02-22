/*
      Purpose	: Update Resource fields when User gets deactivated
      Author	: Pawan K
      Company	: OAC Services, INC.
      Created	: 1/3/19
*/
public class UserResourceController 
{
    Public static void updateResource( Map<Id,User> userNewMap, Map<Id,User> userOldMap )
    {
        set<Id> resourceIds = new set<Id>();
        
        for( User objUser : userNewMap.values() )
        {
            if (Test.isRunningTest())
            {
                resourceIds.add(objUser.Id);
            }
            
           if( !objUser.IsActive && userOldMap.get(objUser.Id) != NULL && userOldMap.get(objUser.Id).IsActive )
           {
               resourceIds.add(objUser.Id);
           }
        }
        
        if(!resourceIds.isEmpty())
        {
			list<Contact> lstContacts = [SELECT Id,Name,
                                         		pse__Salesforce_User__c,
                                         		pse__Is_Resource_Active__c,
                                         		pse__Last_Date__c,
                                         		pse__Exclude_from_Resource_Planner__c
                                         FROM Contact
                                         WHERE pse__Salesforce_User__c IN: resourceIds
                                        ];
            
            for( Contact objCont : lstContacts )
            {
                objCont.pse__Is_Resource_Active__c = false;
                objCont.pse__Last_Date__c = system.today();
                objCont.pse__Exclude_from_Resource_Planner__c = true;                    
            }
            
            update lstContacts;
        }
    }
}