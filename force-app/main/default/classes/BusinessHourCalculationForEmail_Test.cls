@isTest
public class BusinessHourCalculationForEmail_Test { 
    
    
    @testSetup
    private static void setupTestData() {
     
        //create a test account
        Account acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.Type='Customer';
        acnt.AccountNumber='1234567890';
        acnt.BUID__c='99';
        insert acnt;
        
        //create a test asset
        Asset ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Name='Test Asset';
        ast.UsageEndDate = System.Today();
        insert ast;
        
        //create a test contact
        contact con=SRVS_CreateTestDataFactory.createContactRecord(acnt);
        con.Email = 'testtag@test.com';
        con.firstname = 'firstname';
        con.LastName = 'testtag';   
        con.accountid = acnt.id;
        insert con;
        
        //create a test LiveChatVisitor
        LiveChatVisitor visitor=SRVS_CreateTestDataFactory.createLiveChatVisitor();
        insert visitor;
        
       // create a LiveChatTranscript
        LiveChatTranscript lct=SRVS_CreateTestDataFactory.createLiveChatTranscript(visitor,ast);
        insert lct;
        
        //create a test case
        Case cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse.subject='Test Controller Acct Case';
        cse.Service_Tag__c = 'TESTTAG';
        cse.NonAgentContactEmail__c = 'testtag@test.com';
        cse.NonAgentContactFirstName__c = 'firstname';
        cse.NonAgentContactLastName__c = 'testtag';
        cse.NonAgentContactPhone__c = '800-123-4567';
        cse.TranscriptId__c = lct.Id;
        cse.Date_time_for_the_first_email__c= System.now()+1;
        cse.Accepted_time__c=System.now();
        insert cse;
        
        }  
        
        @isTest static void updateEmailFieldsWithBusinessHoursTest(){
        
            List<EmailMessage> emailMessageList = new List<EmailMessage>();
            List<Case> caseList = [select Id from Case limit 1];
            EmailMessage em = new EmailMessage(FromAddress = 'test@abc.org', Incoming = false, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = caseList[0].Id, No_Reply_Required__c = false); 
            emailMessageList.add(em);
            insert emailMessageList;
            BusinessHourCalculationForEmail.UpdateEmailFieldsWithBusinessHours(emailMessageList);
           
        } 
        @isTest static void updateEmailFieldsWithBusinessHoursIncoming(){
        
            List<EmailMessage> emailMessageList = new List<EmailMessage>();
            List<Case> caseList = [select Id from Case limit 1];
            EmailMessage em = new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = caseList[0].Id, No_Reply_Required__c = true);
            emailMessageList.add(em);
            insert emailMessageList;
            BusinessHourCalculationForEmail.UpdateEmailFieldsWithBusinessHours(emailMessageList);
           
        }
        @isTest static void updateEmailFieldsWithoutBusinessHours(){
        
            List<EmailMessage> emailMessageList = new List<EmailMessage>();
            List<EmailMessage> emailMessageListReply = new List<EmailMessage>();
            List<Case> caseList = [select Id, BusinessHoursID from Case limit 1];
            BusinessHours bH = new BusinessHours();
            caseList[0].BusinessHoursID = bH.Id;
            caseList[0].Accepted_time__c = Date.today() -10;
            caseList[0].First_Email_Age_Business_Hours__c = null;
            update caseList[0];
            EmailMessage em = new EmailMessage(FromAddress = 'test@abc.org', Incoming = false,MessageDate=system.now(), ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = caseList[0].Id, No_Reply_Required__c = false); 
            emailMessageList.add(em);
            insert emailMessageList;
            BusinessHourCalculationForEmail.UpdateEmailFieldsWithBusinessHours(emailMessageList);
            BusinessHourCalculationForEmail.dummyMethod();
        }
    
        @isTest static void updateEmailFieldsException(){
        
            List<EmailMessage> emailMessageList = new List<EmailMessage>();
            EmailMessage em;
            emailMessageList.add(em);
            emailMessageList.add(em);
            emailMessageList.add(em);
            //insert emailMessageList;
            BusinessHourCalculationForEmail.UpdateEmailFieldsWithBusinessHours(emailMessageList);
           
        }
 }