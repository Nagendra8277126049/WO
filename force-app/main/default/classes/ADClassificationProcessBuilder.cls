/**
*  ---------------------------------------------------------------------------------------------------------------------------
* Name: 		ADClassificationProcessBuilder
* Description: This Class is responsible to send text from the Case object to Einstein Intent API to classify if a case is AD or not.
* 				The class CaseClassificationProcessBuilder was used as basis
* ---------------------------------------------------------------------------------------------------------------------------
* Date         Version          Author             Summary of Changes 
* -----------  -------  ------------------------  ---------------------------------------------------------------------------
* 05/12/2018     1.0    	Rayana Alencar           Initial Release
  09/01/2019     1.1     	Rayana Alencar     		 STORY 5870144
* 
* */
public class ADClassificationProcessBuilder {
    
    @TestVisible private static Boolean checkUnitTest = false;
    @TestVisible private static Boolean checkErrorHandler = false;
    
    private static String 	NON_AD = 'NON-AD';
    private static String 	NON_AD_LABEL = 'Non-Accidental Damage';
    
    private static String 	EINSTEIN_ENDPOINT	= 'https://api.einstein.ai/v2/language/intent';
    private static String 	POST_METHOD	= 'POST';
    private static String 	AUTHORIZATION = 'Authorization';
    private static String 	AUTHORIZATION_VALUE = 'Bearer ';
    private static String 	CACHE_CONTROL = 'Cache-Control';
    private static String 	CACHE_CONTROL_VALUE	= 'no-cache';
    private static String 	CONTENT_TYPE = 'Content-Type';
    private static String 	CONTENT_TYPE_VALUE = 'application/json;charset=UTF-8';
    
    private static Double	CLASSIFICATION_THRESHOLD = 0.4;
    
    
    
    @InvocableMethod 
    public static void doCallout(List<Id> recordIds) {
        // Stopping the execution, if this function is called from a batch/Future/Queable Method
        if (system.isFuture() || system.isBatch() || system.isQueueable() || (Test.isRunningTest() && checkUnitTest == false) ) { 
            return;
        }
        
        for(Id caseId : recordIds){
            Id objId = caseId;
            accDamageClassification(objId);
        }
        
    }
    
    //Asynchronous call
    @future(callout=true)
    public static void accDamageClassification(Id objId) {
        String userInput = '';
        
        Case caseObj          = [Select Id, Description,Subject,Comments,Issue_Description__c from Case where id =:objId];
        system.debug(caseObj);
        system.debug('String.isNotEmpty(caseObj.Subject)' + String.isNotEmpty(caseObj.Subject));
        system.debug('String.isNotEmpty(caseObj.Description)' +String.isNotEmpty(caseObj.Description));

        if(String.isNotEmpty(caseObj.Subject) && String.isNotEmpty(caseObj.Description)){
            userInput = caseObj.Subject + ' ' + caseObj.Description;
        }else if(String.isNotEmpty(caseObj.Subject)) {
            userInput = caseObj.Subject;
        }else if(String.isNotEmpty(caseObj.Description)){
            userInput = caseObj.Description;
        }else{
            return;
        }
        
        EinsteinLabel einsteinLabel =  callEinsteinIntent(userInput,caseObj.Id);
        
        
        if(String.isEmpty(einsteinLabel.label)){
            caseObj.ADClassification__c = '';
            caseObj.Accidental_Damage_Probability__c = 0.0;   
            caseObj.Accidental_Damage__c = False;
        }else{
            caseObj.ADClassification__c = einsteinLabel.label;
            caseObj.Accidental_Damage_Probability__c =  einsteinLabel.probability; 
            caseObj.Accidental_Damage__c = True;
            if(einsteinLabel.label.equals(NON_AD)){
                caseObj.Accidental_Damage__c = False;
            }
        }
        
        update caseObj;
        
        updateWorkOrdersAlert(objId);
        
        
    }
    
    private  static EinsteinLabel callEinsteinIntent(String subject, Id caseID){
        EinsteinLabel bestLabel = new EinsteinLabel();
        
        if(Test.isRunningTest() && !checkErrorHandler){
            Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        }
        
        Einstein_PredictionService predserv = new Einstein_PredictionService(Einstein_PredictionService.Types.INTENT);
        String token = predserv.getBearerToken();
        
        //Taking the values from custom settings
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        
        String modelID = settings.ADModel_ID__c;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        // API URL
        request.setEndpoint(EINSTEIN_ENDPOINT);
        request.setMethod(POST_METHOD);
        request.setHeader(AUTHORIZATION, AUTHORIZATION_VALUE + token);
        request.setHeader(CACHE_CONTROL, CACHE_CONTROL_VALUE);    
        request.setHeader(CONTENT_TYPE, CONTENT_TYPE_VALUE);
        
        try{
            subject = subject.toLowerCase(); 
        }catch (Exception e) {
            //System.debug(LoggingLevel.Error, '008 subject.toLowerCase error');
            ExceptionHandler.logHandledExceptions(e, 'ADClassification', 'returnIntent', '008 subject.toLowerCase error'); 
            return bestLabel;
        }
        
        
        Message einsteinInput = new Message(modelID,subject);
        string strJson = einsteinInput.toJson();
        request.setBody(strJson);
        
        // Calling the API
        try{
            response = http.send(request);
        }catch (Exception e) {
            //System.debug(LoggingLevel.Error, '1 Einstein Platform error response code = ' + response.getStatusCode() + '. inputText = ' + strJson);
            ExceptionHandler.logHandledExceptions(e, 'ADClassification', 'returnIntent', '1 Einstein Platform error response code'); 
            ExceptionHandler.logCalloutErrors(response,'ADClassification', caseID ,'1 Einstein Platform error response code');
            return bestLabel;
        }
        
        if(response.getStatusCode() != 200){
            //System.debug(LoggingLevel.Error, '1 Einstein Platform error response code = ' + response.getStatusCode() + '. inputText = ' + strJson);
            ExceptionHandler.logCalloutErrors(response,'ADClassification', caseID ,'1 Einstein Platform error response code');
        }else{
            
            EinsteinResponse einsteinResponse = (EinsteinResponse) JSON.deserialize( response.getBody(), EinsteinResponse.class);
            
            bestLabel = einsteinResponse.probabilities[0];
            
        }
        
        return bestLabel;
    }
    
    //this method  create/remove/update alert in work ordes related to a Case
    private static void updateWorkOrdersAlert(Id caseID){
        
        Case caseObj          = [SELECT Id, ADClassification__c, Accidental_Damage_probability__c, Accidental_Damage__c 
                                 FROM Case
                                 WHERE id =:caseID];
        
        List<WorkOrder> workOrders = [SELECT Id, Complete_Care_Option__c FROM WorkOrder WHERE CaseId = :caseID];
        
        //CompleteCareOption__c is related with adEntitlement
        List<DispatchDefaults__c> dispatchDefaults = [SELECT Id, CompleteCareOption__c, Work_Order__c FROM DispatchDefaults__c
                                                      WHERE Work_Order__r.CaseID = :caseID ORDER BY CreatedDate DESC];
        
        List<Dispatch_Alert__c> alerts = [SELECT Id,Name,Work_Order__c, Work_Order__r.CaseID, Alert_Details__c, Alert_Reason__c, Alerts_Id__c
                                          FROM Dispatch_Alert__c 
                                          WHERE Work_Order__r.CaseID = :caseID and Einstein_AD_Classification__c = True];
        
        Map<ID,List<Dispatch_Alert__c>> workOrderAlerts = new Map<ID,List<Dispatch_Alert__c>>();
        Map<ID,Boolean> workOrderDispatch = new Map<ID,Boolean>();
        
        for(Dispatch_Alert__c alert: alerts) {
            List<Dispatch_Alert__c> adAlerts = null;
            if(workOrderAlerts.containsKey(alert.Work_Order__c)) {
                adAlerts = workOrderAlerts.get(alert.Work_Order__c);
                adAlerts.add(alert);
                workOrderAlerts.put(alert.Work_Order__c,adAlerts);
            } else {
                adAlerts = new List<Dispatch_Alert__c>();
                adAlerts.add(alert);
                workOrderAlerts.put(alert.Work_Order__c,adAlerts);
            }
        }
        
        for(DispatchDefaults__c dispatch: dispatchDefaults) {
            if(!workOrderDispatch.containsKey(dispatch.Work_Order__c)) {
                Boolean adEntitlement = dispatch.CompleteCareOption__c;
                workOrderDispatch.put(dispatch.Work_Order__c,adEntitlement);
            }
        }
        
        String einteinClassification = caseObj.ADClassification__c;
        Double classificationProb = caseObj.Accidental_Damage_probability__c;
        Boolean isAccidentalDamage = caseObj.Accidental_Damage__c;
        List<Dispatch_Alert__c> createAlerts = new List<Dispatch_Alert__c>();
        List<Dispatch_Alert__c> deleteAlerts = new List<Dispatch_Alert__c>();
        
        //for each work order of a case
        for(WorkOrder workOrderObj: workOrders){
            Boolean adEntitlement = False;
            Boolean alertAlreadyExists = False;
            
            //there is CompleteCareOption__c related with this workOrder
            if(workOrderDispatch.containsKey(workOrderObj.Id)) {
                adEntitlement = workOrderDispatch.get(workOrderObj.Id);
            }
            List<Dispatch_Alert__c> workAlerts = new List<Dispatch_Alert__c>();
            
            if(workOrderAlerts.containsKey(workOrderObj.Id)) {   
                workAlerts = workOrderAlerts.get(workOrderObj.Id);
            } 
            
            // alert based on Einstein classification and AD entitlement
            Dispatch_Alert__c adAlert = createADAlert(workOrderObj.Id,adEntitlement,isAccidentalDamage,einteinClassification); 
            
			//if there is no CompleteCareOption__c related with this workOrder all AD alert should be deleted		
            if(!workOrderDispatch.containsKey(workOrderObj.Id)) {
                adAlert = null;
            }
				             
            // delete currently alert on this work order if any and create one if its alert message does not exists
            if(adAlert != null){
                for(Dispatch_Alert__c alert: workAlerts){
                    if(!((alert.Alert_Details__c.equals(adAlert.Alert_Details__c)) && 
                       (alert.Name.equals(adAlert.Name)) && (alert.Alert_Reason__c.equals(adAlert.Alert_Reason__c)))){
                           // remove previous AD alert related to this work order
                           deleteAlerts.add(alert);
                       }else{
                           alertAlreadyExists = True;
                       }
                }
            }else{
                deleteAlerts.addAll(workAlerts);
            }
            
            if(adAlert != null && !alertAlreadyExists){
                createAlerts.add(adAlert);
            }
            
        } 
        
        //Add AD alerts 
        insert createAlerts;
        //Remove AD alerts
        delete deleteAlerts;
        
    }
    
    public static Dispatch_Alert__c createADAlert(Id workOrderId,Boolean adEntitlement, Boolean isAccidentalDamage, String einsteinClassification ){
        Dispatch_Alert__c adAlert;
        //Taking the values from custom settings
        Einstein_Message_Alerts__c messagesAlert = Einstein_Message_Alerts__c.getOrgDefaults();
        String messageName = messagesAlert.Alert_Name__c;
        String messageactiveAD = messagesAlert.activeAD_EinsteinAD__c;
        String messageexpiredAD = messagesAlert.expiredAD_EinsteinAD__c;
        if(adEntitlement && isAccidentalDamage){
            adAlert = new Dispatch_Alert__c(Name= messageName,
                                            Alert_Details__c= messageactiveAD,
                                            Einstein_AD_Classification__c = True,
                                            Work_Order__c=workOrderId,
                                            Alert_Reason__c= 'customer has active AD and Einstein says it is AD'); 
        }else if(!adEntitlement && isAccidentalDamage){
            adAlert = new Dispatch_Alert__c(Name= messageName,
                                            Alert_Details__c= messageexpiredAD,
                                            Einstein_AD_Classification__c = True,
                                            Work_Order__c=workOrderId,
                                            Alert_Reason__c= 'customer has expired AD and Einstein says it is not AD');   
            
        }
        
        return adAlert;
    }
    
    private class Message {
        String modelId;
        String document;
        
        public Message(String modelId, String document){
            this.modelId = modelId;
            this.document = document;
        }
        
        public String toJson(){
            return Json.serialize(this);
        }
    }
    
    private class EinsteinResponse{
        List<EinsteinLabel> probabilities;
    }
    
    private class EinsteinLabel{
        String label {get;set;}
        Double probability {get;set;}
    }
    
}