@isTest
public class AffinityControllerTest {
 	
    @testSetup
    static void setupData(){
        Account account = new Account(Name = 'Test account');
        insert account;  
        pse__Proj__c proj = new pse__Proj__c(
            Name = 'Proj Test 1',
            pse__Account__c = account.Id,
            pse__Is_Active__c = true
        );
        insert proj;
        Order order = new Order();
        order.AccountId = account.Id;
        order.OrderNumber__c = '12345';
        order.EffectiveDate = Date.today();
        order.Status = 'BK';
        order.BUID__c = '11';
        order.CustomerNumber__c = '10036';
        
        order.Project__c = proj.Id;
        insert order;
        
        pse__Proj__c proj2 = new pse__Proj__c(
            Name = 'Proj Test 2',
            pse__Account__c = account.Id,
            pse__Is_Active__c = true
        );
        insert proj2;
    }  
    
    @isTest
    static void shouldReturnListOfContacts(){
        pse__Proj__c proj = [SELECT Id FROM pse__Proj__c WHERE Name = 'Proj Test 1'];
                        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        
		Test.startTest();
        List<AccountTeamInformation> accountTeamInformationList = AffinityController.getTeamInfo(proj.Id);
        Test.stopTest();
        
        System.assertEquals(2, accountTeamInformationList.size());
	}
    
    @isTest
    static void shouldReturnOnlyOneContact(){
        pse__Proj__c proj = [SELECT Id FROM pse__Proj__c WHERE Name = 'Proj Test 1'];
                        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessOnlyOneContact());
        
		Test.startTest();
        List<AccountTeamInformation> accountTeamInformationList = AffinityController.getTeamInfo(proj.Id);
        Test.stopTest();
        
        System.assertEquals(1, accountTeamInformationList.size());
	}
    
    @isTest
    static void shouldReturnNoContact(){
        pse__Proj__c proj = [SELECT Id FROM pse__Proj__c WHERE Name = 'Proj Test 2'];
                        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        
		Test.startTest();
        List<AccountTeamInformation> accountTeamInformationList = AffinityController.getTeamInfo(proj.Id);
        System.assertEquals(null, accountTeamInformationList);
        Test.stopTest();  
	} 
    
    @isTest
    static void shouldReturnNoContactResponseNotFound(){
        pse__Proj__c proj = [SELECT Id FROM pse__Proj__c WHERE Name = 'Proj Test 1'];
 		List<AccountTeamInformation> accountTeamInformationList = new List<AccountTeamInformation>();
                        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseNotFound());
        
		Test.startTest();
        accountTeamInformationList = AffinityController.getTeamInfo(proj.Id);
        System.assertEquals(null, accountTeamInformationList);
        Test.stopTest();  
	}
    
    @isTest
    static void shouldThrowExceptionCallbackSearchAccount(){
        pse__Proj__c proj = [SELECT Id FROM pse__Proj__c WHERE Name = 'Proj Test 1'];
 		List<AccountTeamInformation> accountTeamInformationList = new List<AccountTeamInformation>();
                        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseInternalServerError());
        
		Test.startTest();
        try{
            accountTeamInformationList = AffinityController.getTeamInfo(proj.Id);
        }catch(Exception error){
            System.assert(error.getMessage().contains('Script-thrown exception'));
        }
        Test.stopTest();  
	} 
    
    @isTest
    static void shouldThrowExceptionCallbackGetTeamInfo(){
        pse__Proj__c proj = [SELECT Id FROM pse__Proj__c WHERE Name = 'Proj Test 1'];
 		List<AccountTeamInformation> accountTeamInformationList = new List<AccountTeamInformation>();
                        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseErrorGetTeamInfo());
        
		Test.startTest();
        try{
            accountTeamInformationList = AffinityController.getTeamInfo(proj.Id);
        }catch(Exception error){
            System.assert(error.getMessage().contains('Script-thrown exception'));
        }
        
        Test.stopTest();  
	} 
    
    public class MockHttpResponseSuccess implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            String endPoint = req.getEndpoint();
            if(endPoint.contains('Affinity_Search_Account')){
                System.assertEquals('callout:Affinity_Search_Account', endPoint);
                res.setBody('{ "SearchAccountResponse": { ' +
                          '      "SearchAccountResult": { ' +
                           '         "CommonSearchResponse": { ' +
                            '            "CommonSearchResponseBObj": { '  +
                                   '         "AccountId": "2738329498", ' +
                                        '    "State": "TX" ' +
                                        '} ' +
                                    '}, ' +
                                    '"Requester": "Authenticated User", ' +
                                    '"TxStatusCode": "SUCCESS" ' +
                               ' } ' +
                            '} ' +
                        '} ');
            }else{
                System.assertEquals('callout:Affinity_Team_Info', endPoint);
                res.setBody('{ ' +
                         '   "GetAccountTeamInformationResponse": {' +
                          '      "GetAccountTeamInformationResult": { ' +
                           '         "CommonSearchResponse": { ' +
                            '            "CommonSearchResponseBObj": [ ' +
                             '               { ' +
                              '                  "AssignmentType": "Direct", ' +
                                '                "Email": "Carl_Allen@Dell.com", ' +
                                   '             "Phone": "5139110", ' +
                                       '         "RoleName": "Inside Sales Rep", ' +
                                        '        "SalesRepName": "Allen, Carl" ' +
                                        '    }, ' +
                                        '    { ' +
                                        '        "AssignmentType": "Direct", ' +
                                        '        "Email": "Paolo.Prisco@dell.com",' +
                                         '       "Phone": "390652609357",' +
                                          '      "RoleName": "Technical Sales Rep",' +
                                          '      "SalesRepName": "Prisco, Paolo"' +
                                          '  }' +
                                    '    ]' +
                                  '  },' +
                                   ' "Requester": "Authenticated User",' +
                                  '  "TxStatusCode": "SUCCESS"' +
                               ' }' +
                          '  }' +
                        '}  ');
            }
            
            res.setStatusCode(200);
            return res;
        }
	}
    
    public class MockHttpResponseSuccessOnlyOneContact implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            String endPoint = req.getEndpoint();
            if(endPoint.contains('Affinity_Search_Account')){
                System.assertEquals('callout:Affinity_Search_Account', endPoint);
                res.setBody('{ "SearchAccountResponse": { ' +
                          '      "SearchAccountResult": { ' +
                           '         "CommonSearchResponse": { ' +
                            '            "CommonSearchResponseBObj": { '  +
                                   '         "AccountId": "2738329498", ' +
                                        '    "State": "TX" ' +
                                        '} ' +
                                    '}, ' +
                                    '"Requester": "Authenticated User", ' +
                                    '"TxStatusCode": "SUCCESS" ' +
                               ' } ' +
                            '} ' +
                        '} ');
            }else{
                System.assertEquals('callout:Affinity_Team_Info', endPoint);
                res.setBody('{ ' +
                         '   "GetAccountTeamInformationResponse": {' +
                          '      "GetAccountTeamInformationResult": { ' +
                           '         "CommonSearchResponse": { ' +
                            '            "CommonSearchResponseBObj": {  ' +
                              '                  "AssignmentType": "Direct", ' +
                                '                "Email": "Carl_Allen@Dell.com", ' +
                                   '             "Phone": "5139110", ' +
                                       '         "RoleName": "Inside Sales Rep", ' +
                                        '        "SalesRepName": "Allen, Carl" ' +
                                        '    } ' +
                                  '  },' +
                                   ' "Requester": "Authenticated User",' +
                                  '  "TxStatusCode": "SUCCESS"' +
                               ' }' +
                          '  }' +
                        '}  ');
            }
            
            res.setStatusCode(200);
            return res;
        }
	}
    
    public class MockHttpResponseNotFound implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('');
            res.setStatusCode(404);
            return res;
        }
	}
    
    public class MockHttpResponseInternalServerError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"errorMessage": "error"}');
            res.setStatusCode(500);
            return res;
        }
	}
    
    public class MockHttpResponseErrorGetTeamInfo implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            String endPoint = req.getEndpoint();
            if(endPoint.contains('Affinity_Search_Account')){
                res.setBody('{ "SearchAccountResponse": { ' +
                          '      "SearchAccountResult": { ' +
                           '         "CommonSearchResponse": { ' +
                            '            "CommonSearchResponseBObj": { '  +
                                   '         "AccountId": "2738329498", ' +
                                        '    "State": "TX" ' +
                                        '} ' +
                                    '}, ' +
                                    '"Requester": "Authenticated User", ' +
                                    '"TxStatusCode": "SUCCESS" ' +
                               ' } ' +
                            '} ' +
                        '} ');
                res.setStatusCode(200);
            }else{
                res.setBody('{"errorMessage": "error"}');
                res.setStatusCode(500);
            }
            
            return res;
        }
	}
    
    
}