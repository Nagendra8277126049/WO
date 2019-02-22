/* -----------------------------------------------------------------------------------------------------------------------
Name       :       AttachmentRestriction_Test
Description:       Test class for AttachmentRestriction class
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author                   Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
01/05/2018   1.0           Dhamodharan Duraisamy        Initial Release
01/09/2018   1.1           Surya Subramanian            Changes are based on Code Review Defect 4378242
01/17/2018   1.1           Roselin Hephzibah            Changes are based on Code Review Defect 4561213
01/22/2018   1.2           Roselin Hephzibah             Changes are based on SRVS_CreateTestDataFactory Class
01/24/2018   1.3           Roselin Hephzibah            Changes are based on Code Review Defect 4561229
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class AttachmentRestriction_Test { 
    
     @testSetup
     static void setUpData(){
        Test.startTest();
        Account acc = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert acc;
        Contact con = SRVS_CreateTestDataFactory.createContactRecord(acc);
        con.LastName = 'Test Attachment Contact123';
        con.Primary_Phone__c = '576686';
        insert con;
        Asset asst = SRVS_CreateTestDataFactory.createSingleAsset(acc.Id);
        insert asst;
        Case cas = SRVS_CreateTestDataFactory.createSingleCase(asst.Id, acc.Id, con.Id);
        insert cas;
        EmailMessage emailMsg = SRVS_CreateTestDataFactory.createEmailMessage(cas.Id);
        insert emailMsg;
        List<Attachment> attachList = new List<Attachment>();
        Attachment attach1 = SRVS_CreateTestDataFactory.createAttachment('Unit Test Attachment.jpeg',cas.Id);
        attachList.add(attach1);
        Attachment attach2 = SRVS_CreateTestDataFactory.createAttachment('Unit Test Attachment',cas.Id);
        attachList.add(attach2);
        Attachment attach3 = SRVS_CreateTestDataFactory.createAttachment('Unit Test Attachment.exe',emailMsg.Id);
        attachList.add(attach3);
        insert attachList;
        Test.stopTest();
    }
     static testMethod void testAttachments()
    {
        Test.startTest();
        Case c = [SELECT id from Case Limit 1];
        EmailMessage e = [SELECT Id from EmailMessage LIMIT 1];
        List<Attachment> caseAttachList = [SELECT Id, Name, Body, parentId from Attachment Where parentId =: c.ID];
        List<Attachment> emailAttachList = [SELECT Id, Name, Body, parentId from Attachment Where parentId =: e.ID];
        Test.stopTest();
        System.assertEquals(2, caseAttachList.size());
        System.assertEquals(0, emailAttachList.size());
    }

}