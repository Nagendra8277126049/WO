public class AffinityController {
    
    private final static Integer STATUS_SUCCESS = 200; 
    private final static Integer STATUS_NOT_FOUND = 404; 
    
    public static String getAccountId(Id projId){ 
        try{
            Order ordInfo = getProjInfo(projId);
            if(ordInfo == null){
                return null; 
            } 
            
            String jsonReqBodyAcc = '{"SearchAccount" : {"request": {"CustomerMDMAccountSearchExtension" : {"AccountExt" : [{"BuId" : '+ ordInfo.BUID__c +',"CustomerNumber" : "'+ ordInfo.CustomerNumber__c +'","OmegaFlag" : "No"}]},"HierarchyType" : "SALES","PageNumber" : 1,"PageSize" : 4}}} ';
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Affinity_Search_Account');
            request.setMethod('POST');
            request.setBody(jsonReqBodyAcc);
        
            Http http = new Http();
            HttpResponse response = http.send(request);            
            
			if(response.getStatusCode() == STATUS_SUCCESS){
            	return findAccountId(response.getBody());
            }else if(response.getStatusCode() == STATUS_NOT_FOUND){
                system.debug('PROJECT ' + projId + ' - ACCOUNT ID NOT FOUND.');
            	return null; 
        	}else{ 
                //Error Status Code 
                system.debug('ERROR. Response: ' + response);
                system.debug('ERROR. Response Body: ' + response.getBody());
                throw new AuraHandledException(response.getBody());
            }
        } catch(System.Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'AffinityController','getAccountId','FinancialForce');
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
	public static List<AccountTeamInformation> getTeamInfo(Id projId){
        try{
            String accountId = getAccountId(projId);
            
            if(accountId != null){
                String jsonReqBodyAcc = '{"GetAccountTeamInformation":{"request":{"AccountId": "'+accountId+'"}}}';
                HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:Affinity_Team_Info');
                request.setMethod('POST');
                request.setBody(jsonReqBodyAcc);
                
                Http http = new Http();
                HttpResponse response = http.send(request);
                
                if(response.getStatusCode() == STATUS_SUCCESS){
                    system.debug('RETORNO:' + convertJSONToAccountTeamInformationList(response.getBody()));
                    return convertJSONToAccountTeamInformationList(response.getBody());
                }else{
                    system.debug('ERROR. Status Code: ' + response.getStatusCode());
                    return null; 
                }
            }else{
                return null;
            }
        } catch(Exception e) {
			ExceptionHandler.logHandledExceptions(e, 'AffinityController','getTeamInfo','FinancialForce');
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
   private static String findAccountId(String responseBody){
       try{
           Map<String, Object> bodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
           Map<String, Object> searchAccountResponse = (Map<String, Object>) bodyMap.get('SearchAccountResponse');
           Map<String, Object> searchAccountResult = (Map<String, Object>) searchAccountResponse.get('SearchAccountResult');
           Map<String, Object> commonSearchResponse = (Map<String, Object>) searchAccountResult.get('CommonSearchResponse');
           Map<String, Object> commonSearchResponseBObj = (Map<String, Object>) commonSearchResponse.get('CommonSearchResponseBObj');
           return (String) commonSearchResponseBObj.get('AccountId');
       }catch(System.Exception e) {
       	   ExceptionHandler.logHandledExceptions(e, 'AffinityController','findAccountId','FinancialForce');
           return null;
       }
        
    }
    
    private static List<AccountTeamInformation> convertJSONToAccountTeamInformationList(String responseBody){
        try{
            Map<String, Object> bodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            Map<String, Object> getAccountTeamInformationResponse = (Map<String, Object>) bodyMap.get('GetAccountTeamInformationResponse');
            Map<String, Object> getAccountTeamInformationResult = (Map<String, Object>) getAccountTeamInformationResponse.get('GetAccountTeamInformationResult');
            Map<String, Object> commonSearchResponse = (Map<String, Object>) getAccountTeamInformationResult.get('CommonSearchResponse');
            
            List<Object> commonSearchResponseBObj;
            if(commonSearchResponse.get('CommonSearchResponseBObj') instanceOf List<Object>){
                //more than one record
                commonSearchResponseBObj = (List<Object>) commonSearchResponse.get('CommonSearchResponseBObj');
            }else{
                //only one record
                commonSearchResponseBObj = new List<Object>();
                commonSearchResponseBObj.add((Map<String, Object>) commonSearchResponse.get('CommonSearchResponseBObj'));
            }
       
            List<AccountTeamInformation> accountTeamInformationList = new List<AccountTeamInformation>();
            for(Object obj : commonSearchResponseBObj){
                Map<String, Object> objMap = (Map<String, Object>) obj;
                AccountTeamInformation accountTeamInformation = new AccountTeamInformation();
                accountTeamInformation.name = (String) objMap.get('SalesRepName');
                accountTeamInformation.role = (String) objMap.get('RoleName');
                accountTeamInformation.email = (String) objMap.get('Email');
                accountTeamInformation.phone = (String) objMap.get('Phone');
                accountTeamInformationList.add(accountTeamInformation);
            }
    
            return accountTeamInformationList;
        }catch(System.Exception e) {
       	   ExceptionHandler.logHandledExceptions(e, 'AffinityController','findAccountId','FinancialForce');
           return null;
        }
    }
     
    public static Order getProjInfo(Id projId) {
        List<Order> orders = [SELECT BUID__c,CustomerNumber__c FROM Order WHERE Project__c =: projId LIMIT 1]; 
        if(orders != null && !orders.isEmpty()){
            return orders.get(0);
        }else{
            return null;
        } 
    }  
}