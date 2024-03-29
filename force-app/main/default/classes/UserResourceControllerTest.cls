/*
      Purpose   : Test class to cover the automation which
                  Updates Resource fields when User gets deactivated.
                    Covered Classes:
                        1. UserResourceController
      Author    : Pawan K
      Company   : OAC Services, INC.
      Created   : 1/4/19
*/
@isTest
public class UserResourceControllerTest 
{
    @testSetup
    static void setupData()
    {
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        system.debug(objProfile);
        User user = new User(
            Alias = 'dellUser',
            FirstName='Test_pk_Dell', 
            Email='delluser@dell.com',
            IsActive=True,
            EmailEncodingKey='UTF-8', 
            LastName='Dell', 
            LanguageLocaleKey='en_US',
            FederationIdentifier='1234567',
            Dell_NTUserID__c='DELL_TEST',
            Service_User_Type__c='DEV',
            External_ID__c='1234567',
            Organization__c='Dell',
            File_Source__c='AMS - System Admin',
            LocaleSidKey='en_US', 
            ProfileId = objProfile.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName = 'testUser@dell.com', 
            OSP__c='Yes'
        );
        insert(user);
        
        system.debug(user);
        
    }
    
    public static testMethod void updateResource()
    {
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()]; 
        User objUser = [SELECT Id,ProfileId,
                                            Name,
                                            IsActive
                        FROM User 
                        WHERE FirstName='Test_pk_Dell' limit 1];
        system.debug(objUser);
        system.runAs(thisUser) 
        {
            Trigger_Execution_Control__c triggerToggle = new Trigger_Execution_Control__c(
            Skip_Resource_Update__c = false
            );
            insert triggerToggle;
            
            
            
            Account testAccnt = new Account(
                Name = 'Test Acc Dell',            
                Industry = 'Fashion',
                Type = 'Customer'
            );
            insert testAccnt;
            
            contact cont = new contact(
                email = 'test@dell.com',
                FirstName = 'Test',
                LastName = 'Dell',
                accountId = testAccnt.Id,
                country_code__c= 'USA & Canada (1)', 
                Primary_Phone__c='1234567890',
                pse__Salesforce_User__c = objUser.Id,
				Federal_Access__c = true                
            );
            insert cont;
            
            
            Test.startTest();
                objUser.IsActive = false;
                update objUser;
            Test.stopTest();
        }
    }
}