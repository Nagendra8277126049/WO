/* -----------------------------------------------------------------------------------------------------------------------
Name:       ADClassificationProcessBuilderTest
Description: Makes an API call to the Intent API and fetches the predictions according to the title and description.
This class used the CaseClassificationProcessBuilderTest as base.
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
12/06/2018     1.0          Rayana Alencar         Initial Release
-------------------------------------------------------------------------------------------------------------------------- */



@isTest
public class ADClassificationProcessBuilderTest {
    
    @testSetup
    static void createCase(){
        //Create Custom Settings
        Einstein_Message_Alerts__c messagesAlert = new Einstein_Message_Alerts__c();
        messagesAlert.expiredAD_EinsteinAD__c = 'Purchasing additional Accidental Damage for this dispatch, because the customer already used their entitlement';
        messagesAlert.activeAD_EinsteinAD__c = 'Use Accidental Damage for this dispatch';
        messagesAlert.Alert_Name__c = 'Einstein suggestions';
        insert messagesAlert;
        
        //create a test account
        Account acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.Type='Customer';
        acnt.AccountNumber='1234567890';
        acnt.BUID__c='99';
        insert acnt;
        
        //create a test Product
        Product2 p=SRVS_CreateTestDataFactory.createProduct2();
        p.Product_Identifier__c='S360';
        p.External_Id__c = 'AH129';
        insert p;
        
        //create a test asset
        Asset ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Name='Test Asset';
        ast.Product2Id=p.Id;
        ast.UsageEndDate = System.Today();
        insert ast;       
        
        //create a test contact
        contact con=SRVS_CreateTestDataFactory.createContactRecord(acnt);
        con.Email = 'testtag@test.com';
        con.firstname = 'firstname';
        con.LastName = 'testtag';   
        con.accountid = acnt.id;
        con.Primary_Phone__c = '800-123-4567';
        insert con;
        
        //create a test case
        Case cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse.subject='Mouse not working';
        cse.Description = 'Mouse not working';
        cse.Service_Tag__c = '86LKVS1';
        //cse.Case_Source__c = 'Delta';
        cse.AssetId=ast.id;
        cse.NonAgentContactEmail__c = 'testtag@test.com';
        cse.NonAgentContactFirstName__c = 'firstname';
        cse.NonAgentContactLastName__c = 'testtag';
        cse.NonAgentContactPhone__c = '800-123-4567';
        insert cse;
        
        //create a test case 2
        Case cse2=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse2.Description = 'Mouse not working';
        cse2.Service_Tag__c = '86LKVS1';
        //cse.Case_Source__c = 'Delta';
        cse2.AssetId=ast.id;
        cse2.NonAgentContactEmail__c = 'testtag@test.com';
        cse2.NonAgentContactFirstName__c = 'firstname';
        cse2.NonAgentContactLastName__c = 'testtag';
        cse2.NonAgentContactPhone__c = '800-123-4567';
        insert cse2;
        
        //create a test case 3
        Case cse3=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse3.subject='Mouse problem';
        cse3.Service_Tag__c = '86LKVS1';
        //cse.Case_Source__c = 'Delta';
        cse3.AssetId=ast.id;
        cse3.NonAgentContactEmail__c = 'testtag@test.com';
        cse3.NonAgentContactFirstName__c = 'firstname';
        cse3.NonAgentContactLastName__c = 'testtag';
        cse3.NonAgentContactPhone__c = '800-123-4567';
        insert cse3;
        
        //create a test case 4
        Case cse4=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse4.Service_Tag__c = '86LKVS1';
        //cse.Case_Source__c = 'Delta';
        cse4.AssetId=ast.id;
        cse4.NonAgentContactEmail__c = 'testtag@test.com';
        cse4.NonAgentContactFirstName__c = 'firstname';
        cse4.NonAgentContactLastName__c = 'testtag';
        cse4.NonAgentContactPhone__c = '800-123-4567';
        insert cse4;
        
        //create a test case 5
        Case cse5=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse5.Service_Tag__c = '86LKVS1';
        cse5.Subject = 'Keyboard is broken';
        //cse.Case_Source__c = 'Delta';
        cse5.AssetId=ast.id;
        cse5.NonAgentContactEmail__c = 'testtag@test.com';
        cse5.NonAgentContactFirstName__c = 'firstname';
        cse5.NonAgentContactLastName__c = 'testtag';
        cse5.NonAgentContactPhone__c = '800-123-4567';
        insert cse5;
        
        
    }
    
    private static List<WorkOrder> createWorkOrder(Case cse){
        List<WorkOrder> orders = new List<WorkOrder> ();
        //create work order with active AD
        WorkOrder order1 = new WorkOrder();
        order1.Complete_Care_Option__c = True;
        order1.caseId = cse.id;
        insert order1;
        
        //Create a DispatchDefaults__c related with workOrder
        DispatchDefaults__c dispatch = new DispatchDefaults__c();
        dispatch.Work_Order__c = order1.id;
        dispatch.CompleteCareOption__c = True;
        insert dispatch;
        
        //create work order with expired AD
        WorkOrder order2 = new WorkOrder();
        order2.Complete_Care_Option__c = False;
        order2.caseId = cse.id;
        insert order2;
        
        //Create a DispatchDefaults__c related with workOrder
        DispatchDefaults__c dispatch2 = new DispatchDefaults__c();
        dispatch2.Work_Order__c = order2.id;
        dispatch2.CompleteCareOption__c = False;
        insert dispatch2;
        
        //create work order alert different than expected
        Dispatch_Alert__c alert1 = new Dispatch_Alert__c();
        alert1.Name='Einstein suggestions';
        alert1.Alert_Details__c='Purchasing additional Accidental Damage for this dispatch, because the customer already used their entitlement';
        alert1.Einstein_AD_Classification__c = True;
        alert1.Work_Order__c= order1.Id;
        alert1.Alert_Reason__c= 'customer has expired AD and Einstein says it is not AD';
        insert alert1;
                
        
        //create work order alert equal than expected
        Dispatch_Alert__c alert2 = new Dispatch_Alert__c();
        alert2.Name='Einstein suggestions';
        alert2.Alert_Details__c='Use Accidental Damage for this dispatch';
        alert2.Einstein_AD_Classification__c = True;
        alert2.Work_Order__c= order1.Id;
        alert2.Alert_Reason__c= 'customer has active AD and Einstein says it is AD';
        insert alert2;
        
        orders.add(order1);
        orders.add(order2);
        
        return orders;
       
    }
    
    @isTest
    static void test1()
    {	 
        //Test if the code is working when Einstein Intent return an classification result
        Test.startTest();
        ADClassificationProcessBuilder.checkUnitTest = true;
        List<Id> recordsIds =new List<Id>();
        List<Case> cases = [Select id from Case]; 
        system.debug('cases '+ cases.size());
        for(Case caseObj: cases){
            recordsIds.add(caseObj.Id);
        }
        
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.Einstein_EMail__c = 'test@mail.com';
        upsert settings;
        
        ADClassificationProcessBuilder.doCallout(recordsIds);
        
        Test.stopTest();
        
        cases = [Select id,ADClassification__c from Case];
        Case case1 = cases.get(0);
        Case case2 = cases.get(1);
        Case case3 = cases.get(2);
        Case case4 = cases.get(3);
        
        System.assertEquals('Mouse', case1.ADClassification__c);
        System.assertEquals('Mouse', case2.ADClassification__c);
        System.assertEquals('Mouse', case3.ADClassification__c);
        System.assertEquals(null, 	 case4.ADClassification__c);
        
        
        
    } 
    
    @isTest
    static void test2(){	
        // Test if the code is working when Einstein Intent return an Error 
        Test.startTest();
        Test_Einstein_HttpMockResponses httpMockResponses = new Test_Einstein_HttpMockResponses();
        httpMockResponses.forceHttpError = true;
        Test.setMock(HttpCalloutMock.class, httpMockResponses);
        
        ADClassificationProcessBuilder.checkUnitTest = true;
        List<Case> cases = [Select id from Case]; 
        Id caseId = cases.get(0).id;
        List<Id> recordsIds =new List<Id>();
        recordsIds.add(caseId);
        
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.Einstein_EMail__c = 'test@mail.com';
        upsert settings;
        
        ADClassificationProcessBuilder.checkErrorHandler = true;
        
        ADClassificationProcessBuilder.doCallout(recordsIds);
        
        Test.stopTest();
        
        cases = [Select id,ADClassification__c from Case];
        Case case1 = cases.get(0);
        
        System.assertEquals(null, case1.ADClassification__c);
        
    } 
    
    @isTest
    static void testADNotification(){
        List<Case> cases = [Select id, Accidental_Damage__c, Description from Case LIMIT 1]; 
        //testing AD Notification when a Case is updated
        Case case1 = cases.get(0);                          
        List<WorkOrder> orders = createWorkOrder(case1);
               
        case1.Description = 'Testing AD Notification';
        update case1;
              
  
        //Test if the code is working when Einstein Intent return an classification result
        Test.startTest();
        ADClassificationProcessBuilder.checkUnitTest = true;
        List<Id> recordsIds =new List<Id>();
        recordsIds.add(case1.Id);
         
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.Einstein_EMail__c = 'test@mail.com';
        upsert settings;
        
        ADClassificationProcessBuilder.doCallout(recordsIds);
        
        Test.stopTest();
               
        List<Dispatch_Alert__c> alerts = [SELECT Id,Name,Work_Order__c, Work_Order__r.CaseID, Alert_Details__c, Alert_Reason__c, Alerts_Id__c
                                          FROM Dispatch_Alert__c 
                                          WHERE Work_Order__r.CaseID = :case1.Id and Einstein_AD_Classification__c = True];
        
       System.assertEquals(2, alerts.size());
        
       // get alert for the first work order
       List<Dispatch_Alert__c> alert1 = [SELECT Id,Name,Work_Order__c, Work_Order__r.CaseID, Alert_Details__c, Alert_Reason__c, Alerts_Id__c
                                          FROM Dispatch_Alert__c 
                                          WHERE Work_Order__r.CaseID = :case1.Id and Einstein_AD_Classification__c = True and Work_Order__c = :orders.get(0).Id];
       System.assertEquals(1, alert1.size());
       System.assertEquals('Use Accidental Damage for this dispatch', alert1.get(0).Alert_Details__c);
        
        // get alert for the second work order
        List<Dispatch_Alert__c> alert2 = [SELECT Id,Name,Work_Order__c, Work_Order__r.CaseID, Alert_Details__c, Alert_Reason__c, Alerts_Id__c
                                          FROM Dispatch_Alert__c 
                                          WHERE Work_Order__r.CaseID = :case1.Id and Einstein_AD_Classification__c = True and Work_Order__c = :orders.get(1).Id];
        System.assertEquals(1, alert2.size());
        System.assertEquals('Purchasing additional Accidental Damage for this dispatch, because the customer already used their entitlement', alert2.get(0).Alert_Details__c);

        
    }
}