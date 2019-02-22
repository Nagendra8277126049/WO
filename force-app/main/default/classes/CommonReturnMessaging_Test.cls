/* -----------------------------------------------------------------------------------------------------------------------
Name:       CommonReturnMessaging_Test
Description:  Test class for CommonReturnMessaging class 
----------------------------------------------------------------------------------------------------------------------------
Date         Version  		  Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
12/14/2017     1.0     		Mohammed Farhan       Initial Release
01/22/2018     1.1     	   Surya Subramanian   	  Changes are based on SRVS_CreateTestDataFactory Class
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class CommonReturnMessaging_Test {    
    
    private static User u= SRVS_CreateTestDataFactory.createUser('Service Agent');
    
    @isTest
    private static void CommonReturnMessaging(){        
        
        System.runAs(u){
            CommonReturnMessaging crm = new CommonReturnMessaging();
                
            /****************** Negative Testing ****************/
            system.assertEquals(null,crm.type);
            system.assertEquals(null,crm.details);
            system.assertEquals(null,crm.message);
            system.assertEquals(null,crm.code);  
            
            /************* Positive Testing ********************/
            crm.type = 'Success';
            crm.details = '100000, Operation Successful.';
            crm.message = 'Operation completed success';
            crm.code = '100';       
            
            system.assertEquals('Success',crm.type);
            system.assertEquals('100',crm.code);  
        }
    }
}