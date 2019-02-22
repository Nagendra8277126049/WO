/* -----------------------------------------------------------------------------------------------------------------------
Name:       ContentVersionTriggerHelper_Test
Description: Test class for ContentVersionTrigger 
            -  Story #4202316
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
05/01/2017     1.0         Swarnalatha          Initial Release
01/08/2018     1.1         Surya Subramanian    Chaneges are based on Code Review Defect 4378242
01/17/2018     1.2     	   Surya Subramanian    Chaneges are based on Code Review Defect 4561213
-------------------------------------------------------------------------------------------------------------------------- */

@isTest()
private class ContentVersionTriggerHelper_Test {
    
    @isTest
    private static void unitTestAttach(){
        
        Test.startTest(); 
       	Contentversion cV=SRVS_CreateTestDataFactory.createContentversion('test.txt');
        insert cV;
        Test.stopTest();
        
        System.assertNotEquals(null, cV.Id);
    }
    
    @isTest
    private static void unitTestAttachExp(){
        Contentversion cV;
        Test.startTest(); 
        try{
            cV=SRVS_CreateTestDataFactory.createContentversion('test.cmd');
            insert cV;            
        }catch(Exception e){}
        Test.stopTest();        
        
        System.assertNotEquals(null, cV.Id);
    }
}