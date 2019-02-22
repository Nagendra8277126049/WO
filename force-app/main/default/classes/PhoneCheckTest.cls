/* -----------------------------------------------------------------------------------------------------------------------
Name:         PhoneCheckTest
Description:  this is test class for Apex Class PhoneCheck.apxc  Story 5428506
Date          Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
10/18/2018     1.0     Rajesh Guru    Initial Release

-------------------------------------------------------------------------------------------------------------------------- */ 



@isTest
public class PhoneCheckTest {
        
        


    static testMethod void unitTest1() {
        
        
        //Create Account
        Account accountid = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert accountid;
        Contact coNew = SRVS_CreateTestDataFactory.createContactRecord(accountid);
        insert coNew;
        Case cse = SRVS_CreateTestDataFactory.createSingleCase(null, accountid.id, coNew.id);
        insert cse;
        
        //create a test case
        //Case cse = new Case(Subject = 'Test Case', ContactId = co.Id);
        //insert cse;  
        Test.startTest();
        PhoneCheck.getCaseDetails(cse.Id);
        PhoneCheck.check(cse.Id);
        Test.stopTest();
       // System.assertEquals('0',PhoneCheck.check(cse.Id) );
        
    }
    
    static testMethod void unitTest2() {
        
         //Create Account
        Account accountid = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert accountid;
        Contact coNew = SRVS_CreateTestDataFactory.createContactRecord(accountid);
        insert coNew;
        Case cse = SRVS_CreateTestDataFactory.createSingleCase(null, accountid.id, coNew.id);
        insert cse;
        
        Test.startTest();
        PhoneCheck.getCaseDetails(cse.Id);
        PhoneCheck.check(cse.Id);
        Test.stopTest();
       // System.assertEquals('0',PhoneCheck.check(cse.Id) );
        
    }
}