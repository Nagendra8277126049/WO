/* -----------------------------------------------------------------------------------------------------------------------
Name:         CommonRequestHeader_Test
Description:  Test class for CommonRequestHeader class 
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
12/17/2017     1.0         Mohammed Farhan       Initial Release
01/17/2018     1.1         Surya Subramanian     Changes are based on Code Review Defect 4561213
01/22/2018     1.2         Surya Subramanian     Changes are based on SRVS_CreateTestDataFactory Class
11/01/2018     1.3         Harsha Reddy          Code Review
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class CommonRequestHeader_Test {
    
    private static User u=SRVS_CreateTestDataFactory.createUser('System Administrator');
    
    @isTest
    private static void CommonRequest(){   

        System.runAs(u){
            Test.StartTest();
            CommonRequestHeader crh = new CommonRequestHeader();        
            CommonRequestHeader.CommonSourceSystem css = new CommonRequestHeader.CommonSourceSystem();          
            
            Test.StopTest();
            
            /********** Negetive Scenario *********/
            system.assertEquals(null,css.name);
            system.assertEquals(null,css.UserId);  
            
            /********* Positive Scenario **********/
            css.UserId = '123456789';
            css.name = 'SFDC';
            crh.SourceSystem = css;
            system.assertEquals('SFDC',crh.SourceSystem.name);
            system.assertEquals('123456789',crh.SourceSystem.userId);
        }
    }
     @isTest
    private static void CommonRequestTeset(){ 
       
            Test.StartTest();
            CommonRequestHeader crh = new CommonRequestHeader();        
            CommonRequestHeader.CommonSourceSystem css = new CommonRequestHeader.CommonSourceSystem();          
            
            Test.StopTest();
            
            /********** Negetive Scenario *********/
            system.assertEquals(null,css.name);
            system.assertEquals(null,css.UserId);  
            
            /********* Positive Scenario **********/
            css.UserId = null;
            css.name = null;
            crh.SourceSystem = css;
    }
    
    @isTest
    private static void CommonSourceSystem1(){

        System.runAs(u){
            Test.StartTest();
            CommonRequestHeader crh= new CommonRequestHeader ();   
            crh.SetDefaultValues();
            Test.StopTest();
          system.assertEquals('SFDC',crh.SourceSystem.name );
        }
    }
 
}