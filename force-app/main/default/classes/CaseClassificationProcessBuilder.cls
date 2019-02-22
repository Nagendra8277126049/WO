/* ---------------------------------------------------------------------------------------------------------------------------
 * Name:       CaseClassificationProcessBuilder
 * Description:  Makes an API call to the Intent API and fetches the predictions according to the title and description.
 * ---------------------------------------------------------------------------------------------------------------------------
 * Date         Version          Author             Summary of Changes 
 * -----------  -------  ------------------------  ---------------------------------------------------------------------------
 * 08/30/2018     1.0    Shaurya Bajaj             Initial Release
 * 08/30/2018     1.0    Shaurya Bajaj             STORY 5639508 Display "None" when the Probability % for CC is less than 40%
 * 10/04/2018     1.0    Jorge Montalvão           STORY 5562402 Call Guided Resolution
 * 10/23/2018     1.0    Shaurya Bajaj             DEFECT 5737475 FLS Update - Case Classification
 * 10/25/2018     1.0    Jorge Montalvão           DEFECT 5748301 Call Einstein Platform using case title and description in lowercase
 * 10/25/2018     1.0    Jorge Montalvão           DEFECT 5737709 Removing reserved characteres for Next Best Action
 * 10/31/2018     1.0    Jorge Montalvão           Removing Guided Resolution
 * 10/31/2018     1.0    Shaurya Bajaj             Removing DEFECT 5737475 FLS Update - Case Classification
 * 11/23/2018     1.0    Jorge Montalvão           5865856 Errors in Prod: NullPointerException Class CaseClassificationProcessBuilder
 * 11/23/2018     1.0    Jorge Montalvão           5812310 [FY19:1101][QE]_[Intelligence]Next Best Action field displays "Null" value
 * 12/21/2018     2.0    Jorge Montalvão           Story 5794725: Performance dataset and labels to be added
 * 01/03/2018     2.0    Jorge Montalvão           Defect 6023261: [QE]FY20_0202_Lightning_Intelligence_CC List and NBA field is blank for cases created for the mentioned performance labels in SIT1
 * --------------------------------------------------------------------------------------------------------------------------- */


public class CaseClassificationProcessBuilder {
    
    @TestVisible private static Boolean checkUnitTest    = false;
    @TestVisible private static Boolean checkCCLower     = false;
    @TestVisible private static Boolean checkCCPerf      = false;
    @TestVisible private static Boolean checkBadDoc      = false;
    @TestVisible private static Boolean checkGRLPwd      = false;
    @TestVisible private static Boolean checkGRToken     = false;
    @TestVisible private static Boolean checkGRBadResult = false;
    
/* -----------------------------------------------------------------------------------------------------------------------
   Method Name:  doCallout
   Description:  Fetches the title and description from the case for Classification
   ----------------------------------------------------------------------------------------------------------------------------
   Date         Version          Author             Summary of Changes 
   -----------  -------  ------------------------  ------------------------------------------------------------------------------
   08/30/2018     1.0         Shaurya Bajaj               Initial Release
   -------------------------------------------------------------------------------------------------------------------------- */
    
    
    
    @InvocableMethod 
    public static void doCallout(List<Id> recordId) {
        // Stopping the execution, if this function is called from a batch/Future/Queable Method
        if (system.isFuture() || system.isBatch() || system.isQueueable() || (Test.isRunningTest() && checkUnitTest == false) ) { 
            return;
        }
       system.debug('isRunningTest:' + Test.isRunningTest() 
                    + '; checkUnitTest: ' + checkUnitTest 
                    + '; checkCCLower: ' + checkCCLower 
                    + '; checkCCPerf: ' + checkCCPerf
                    + '; checkGRLPwd: ' + checkGRLPwd
                    + '; checkGRToken: ' + checkGRToken);
        
       Case rec         = [select Subject,TranscriptId__c, Description, Asset.Name, CaseClassification__c 
                              from Case 
                            where id =:recordId.get(0)];
         
        String subject = '';
        String descr   = '';
        id rec_id      = rec.id;
        String asset_name = rec.Asset.Name;
        String chat_transcript_id = rec.TranscriptId__C;
        System.debug(chat_transcript_id);
        String all_chat_tarnscripts = '';
        
        subject=  rec.subject;
        descr = rec.Description;
          
        
        String  trans_body = '';
        
        If(chat_transcript_id!= null){
            //System.debug(chat_transcript_id);
             List<LiveChatTranscript> Trans_obj = [select body from LiveChatTranscript where Caseid = :rec_id ];
             	
            for(LiveChatTranscript TS : Trans_obj){
                if(TS.body != null){
            trans_body = (String)TS.body;
                System.debug(trans_body);
                    
                
    		
            
            
            
        trans_body = trans_body.replaceAll(Label.CC_Chat_Regex1,' ');
        trans_body = trans_body.replaceAll(Label.CC_Chat_Regex2, ' ');
        String[] final_transcript_body = trans_body.split(Label.CC_Chat_Review);
                if(final_transcript_body[0]==null){
                    final_transcript_body = trans_body.split(Label.CC_Chat_Perf);
                }
        String cleaned_chat_transcript = final_transcript_body[0];
        cleaned_chat_transcript= cleaned_chat_transcript.toLowerCase();
        
        List<String> stopwords = new List<String>{' a ', ' about ', ' above ', ' after ', ' again ', ' against ', ' all ', ' am ', ' an ', ' and ', ' any ', ' are ', ' as ', ' at ', ' be ', ' because ', ' been ', ' before ', ' being ', ' below ', ' between ', ' both ', ' but ', ' by ', ' could ', ' did ', ' do ', ' does ', ' doing ', ' down ', ' during ', ' each ', ' few ', ' for ', ' from ', ' further ', ' had ', ' has ', ' have ', ' having ', ' he ', ' he\'d ', ' he\'ll ', ' he\'s ', ' her ', ' here ', ' here\'s ', ' hers ', ' herself ', ' him ', ' himself ', ' his ', ' how ', ' how\'s ', ' i ', ' i\'d ', ' i\'ll ', ' i\'m ', ' i\'ve ', ' if ', ' in ', ' into ', ' is ', ' it ', ' it\'s ', ' its ', ' itself ', ' let\'s ', ' me ', ' more ', ' most ', ' my ', ' myself ', ' nor ', ' of ', ' on ', ' once ', ' only ', ' or ', ' other ', ' ought ', ' our ', ' ours ', ' ourselves ', ' out ', ' over ', ' own ', ' same ', ' she ', ' she\'d ', ' she\'ll ', ' she\'s ', ' should ', ' so ', ' some ', ' such ', ' than ', ' that ', ' that\'s ', ' the ', ' their ', ' theirs ', ' them ', ' themselves ', ' then ', ' there ', ' there\'s ', ' these ', ' they ', ' they\'d ', ' they\'ll ', ' they\'re ', ' they\'ve ', ' this ', ' those ', ' through ', ' to ', ' too ', ' under ', ' until ', ' up ', ' very ', ' was ', ' we ', ' we\'d ', ' we\'ll ', ' we\'re ', ' we\'ve ', ' were ', ' what ', ' what\'s ', ' when ', ' when\'s ', ' where ', ' where\'s ', ' which ', ' while ', ' who ', ' who\'s ', ' whom ', ' why ', ' why\'s ', ' with ', ' would ', ' you ', ' you\'d ', ' you\'ll ', ' you\'re ', ' you\'ve ', ' your ', ' yours ', ' yourself ', ' yourselves'};
            //System.debug(Body);
        
         for ( Integer i =0; i<stopWords.size();i++) {
            cleaned_chat_transcript = cleaned_chat_transcript.replace(stopWords[i], ' ');
                }

                cleaned_chat_transcript = cleaned_chat_transcript.replace('  ', '');
                cleaned_chat_transcript = cleaned_chat_transcript.toLowerCase();
                all_chat_tarnscripts =  all_chat_tarnscripts + ' '+ cleaned_chat_transcript;
                System.debug('Final Chat Transcript is ' + all_chat_tarnscripts);
            }
            }
        
        }
        //Sending both, Title and Desc as the input
        String total_text = subject + ' ' + descr+' '+all_chat_tarnscripts;
        callreturnIntent(rec_id,total_text,asset_name, descr);
    }
    
/* -----------------------------------------------------------------------------------------------------------------------
    Method Name:  callreturnIntent
    Description:  Fetches the best predicted value and the top 3 predictions and updates the case record
    ----------------------------------------------------------------------------------------------------------------------------
    Date         Version          Author             Summary of Changes 
    -----------  -------  ------------------------  ------------------------------------------------------------------------------
    08/30/2018     1.0         Shaurya Bajaj               Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    
    //Asynchronous call
    @future(callout=true) 
    public static void callreturnIntent(Id rec_id, String Subject, String serviceTag, String symptomDescription){
        List<String> perfLabels = new List<String>{
            'SLOW BOOT TIME',
            'SLOW SHUTDOWN',
            'SYSTEM DOES NOT SHUTDOWN',
            'SYSTEM FREEZING/LOCKING UP',
            'SLOW SYSTEM PERFORMANCE',
            'SLOW PERFORMANCE WITH 100% HARD DRIVE ACTIVITY USING WINDOWS 8 /8.1/10',
            'SLOW BROWSER PERFORMANCE',
            'SLOW SYSTEM PERFORMANCE WHEN DOCKED(NOTEBOOKS ONLY)',
            'NO BOOT'};
        List<String> resultNBA = new String[2];
        Case rec = new Case();
        rec.id = rec_id;
        List<String> returnIntent = returnIntent(subject,rec_id);
        system.debug('Return Intent: ' + returnIntent);
        //if(Schema.sObjectType.Case.fields.Top_3_Predictions__c.isUpdateable() && Schema.sObjectType.Case.fields.Best_Prediction__c.isUpdateable() && Schema.sObjectType.Case.fields.Case_Classification_List__c.isUpdateable() ){  //Defering for feb Release , Defect 5737475 
            if(returnIntent[0] == 'no'){
                
                //STORY 5639508 Display "None" when the Probability % for CC is less than 40%
                rec.Top_3_Predictions__c        = 'Best Prob value less than 40%'; 
                rec.Best_Prediction__c          = 'None';
                rec.Case_Classification_List__c = 'None';
            }
            else{
                rec.Best_Prediction__c          = returnIntent[0];
                rec.Case_Classification_List__c = returnIntent[0];
                rec.Top_3_Predictions__c        = returnIntent[1];
            }
        //} //Defering for feb Release , Defect 5737475
        
        //if(Schema.sObjectType.Case.fields.next_best_action__c.isUpdateable() && Schema.sObjectType.Case.fields.next_best_action_link__c.isUpdateable()){//Defering for feb Release , Defect 5737475

        if (perfLabels.contains(rec.Case_Classification_List__c.toUpperCase()) || checkCCPerf == true){
            //CC is related perf
            rec.next_best_action_link__c = '[NA]';
            rec.next_best_action__c = 'Go to "System Performance Flow" under "More > Guided Action List"';
        }
        else{
            //CC is not related perf
            resultNBA = returnNBA(serviceTag,symptomDescription,rec_id); //(String serviceTag,String symptomDescription);
            rec.next_best_action__c      = resultNBA[0];
            rec.next_best_action_link__c = resultNBA[1];
        }
        //}  //Defering for feb Release , Defect 5737475
        SYSTEM.debug('resultNBA[1]: ' + resultNBA[1]);
        update rec;
    }
    
/* -----------------------------------------------------------------------------------------------------------------------
   Method Name:  returnIntent
   Description:  Calls the Intent API, Fetches the best best predicted value and the top 3 predictions,
   Removes the unnecessary characters (Cleaning)
   -----------------------------------------------------------------------------------------------------------------------
   Date         Version          Author             Summary of Changes 
   -----------  -------  ------------------------  -----------------------------------------------------------------------
   08/30/2018     1.0         Shaurya Bajaj               Initial Release
   ----------------------------------------------------------------------------------------------------------------------- */
    
    
    
    public static List<String> returnIntent(String subject,ID sfdcId){
        if(Test.isRunningTest() && checkUnitTest == true){
            Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        } 
        
        //Taking the values from custom settings
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        /* 1 - APEX classes */
        Einstein_PredictionResult predictIntent;
        Einstein_PredictionService predserv = new Einstein_PredictionService(Einstein_PredictionService.Types.INTENT);
        List<String> returned_value = new String[]{'no','no'};
        
        // Calling the API
        try{
            predictIntent = predserv.predictIntent(
                settings.CCModel_ID__c, 
                subject.toLowerCase(), 
                3, 
                subject.toLowerCase()
            );
            system.debug('Predict Intent: ' + predictIntent);
        }catch (Exception e) {
            System.debug(LoggingLevel.Error, '1 Einstein Platform error: ');
            ExceptionHandler.logHandledExceptions(e, 'CaseClassificationProcessBuilder', 'returnIntent', '1 Einstein Platform error response code'); 
            return returned_value;
        }
        
        //Comparing the value of threshold
        if(predictIntent.probabilities[0].probability < 0.4){ 
            return returned_value;
        }  
        
        returned_value[0]=predictIntent.probabilities[0].label;

        
        List<String> list_values = new List<String>();
        for (Einstein_PredictionResult.probabilities checkProb : predictIntent.probabilities) {
            //returned_value[1] += checkProb.label + ': ' + checkProb.probability + ', ';
            list_values.add(checkProb.label);
            list_values.add(String.valueOf(checkProb.probability));
        }
        returned_value[1] = JSON.serialize(list_values);

        return returned_value;
        
    }
    
    /*--------------------------------------------------------------------------------------------------------------------------
      Date         Version          Author             Summary of Changes 
      -----------  -------  ------------------------  --------------------------------------------------------------------------
      10/04/2018     1.0         Jorge Montalvão          Call Guided Resolution
      -------------------------------------------------------------------------------------------------------------------------- */
    class GR_Login{
        String username;
        String password;
    }
    
    class GR_OverAll{
        String tag;
        String text;
    }
    
    public static List<String> returnNBA(String serviceTag, String symptomDescription, ID sfdcId){

        if(Test.isRunningTest() && checkUnitTest == true){
            Test.setMock(HttpCalloutMock.class, new Test_Einstein_HttpMockResponses());
        }
        
        Einstein_GR_Token grToken;
        List<String> resultNBA       = new String[]{'[NA]','[NA]'};
        GR_OverAll        gr_overall = new GR_OverAll();
        Http              http     = new Http();
        HttpRequest       request  = new HttpRequest();
        HttpResponse      response = new HttpResponse();

        try{
            gr_overall.text       = symptomDescription.replaceAll('[\'",‘’]', '').replace('\\','').replaceAll('[^a-zA-Z0-9]', ' ');
        }catch (Exception e) {
            System.debug(LoggingLevel.Error, '005 Symptom Description replace error');
            ExceptionHandler.logHandledExceptions(e, 'CaseClassificationProcessBuilder', 'returnNBA', '005 Symptom Description replace error'); 
            return resultNBA;
        }
        gr_overall.tag = serviceTag;

        request.setEndPoint('callout:Guided_Resolution_Login');
        
        // only for test bad user/password
        if(Test.isRunningTest() && checkUnitTest == true && checkGRLPwd == true){
            request.setEndPoint('https://sdsazmlgw01.dell.com/loginError');
        }
        
        request.setMethod('POST');
        request.setHeader('Cache-Control', 'no-cache');
        request.setHeader('Content-Type','application/json');
        request.setTimeout(5000);//added by harsha
        GR_Login gr_login = new GR_Login();
        gr_login.username ='{!$Credential.Username}';
        gr_login.password ='{!$Credential.Password}';            
        request.setBody(Json.serialize(gr_login));
        
        try{
            response = http.send(request);
            if (response.getStatusCode() ==401){
                CalloutException e = new CalloutException();
                e.setMessage('Response status code 401: Unauthorized access');
                throw e;
            }
        }catch (Exception e) {
            System.debug(LoggingLevel.Error, '002 Guided_Resolution_Login HTTP error response code = ' + response.getStatusCode() + '. GR_Login = ' + Json.serialize(gr_login));
            ExceptionHandler.logHandledExceptions(e, 'CaseClassificationProcessBuilder', 'returnNBA', '002 Guided_Resolution_Login HTTP error response code'); 
            ExceptionHandler.logCalloutErrors(response,'CaseClassificationProcessBuilder', sfdcId ,'002 Guided_Resolution_Login HTTP error response code');
            return resultNBA;
        }
        
        grToken = Einstein_GR_Token.parse(response.getBody());
        request.setEndPoint('callout:Guided_Resolution');
        
        // only for test bad token
        if(Test.isRunningTest() && checkUnitTest == true && checkGRToken == true){
            request.setEndPoint('https://sdsazmlgw01.dell.com/api/overall_guided_res_wrapper_error');
        }
        else if(Test.isRunningTest() && checkUnitTest == true && checkGRBadResult == true){
            request.setEndPoint('https://sdsazmlgw01.dell.com/api/overall_guided_res_wrapper_bad_result');
        }
        request.setTimeout(5000);//added by harsha
        request.setMethod('POST');
        request.setHeader('Cache-Control', 'no-cache');
        request.setHeader('Content-Type','application/json');
        request.setHeader('Authorization','Bearer ' + grToken.access_token);

        // Set the body as a JSON object
        // serviceTag,symptomDescription
        // {"tag": "8g2xfm2", "text": "my keyboard is not working"}
        request.setBody(JSON.serialize(gr_overall));
        
        System.JSONToken token;
        String text, next_best_action, next_best_action_link;
        
        try{
            response = http.send(request);
            if (response.getStatusCode() == 401){
                CalloutException e = new CalloutException();
                e.setMessage('Response status code 401: Unauthorized access');
                throw e;
            }
        }catch (Exception e) {
            System.debug(LoggingLevel.Error, '003 Guided_Resolution HTTP error response code = ' + response.getStatusCode() + '. GR_OverAll = ' + JSON.serialize(gr_overall));
            //ExceptionHandler.logHandledExceptions(Exception ex,String className, String methodName, String module)
            ExceptionHandler.logHandledExceptions(e, 'CaseClassificationProcessBuilder', 'returnNBA', '003 Guided_Resolution HTTP error response code'); 
            ExceptionHandler.logCalloutErrors(response,'CaseClassificationProcessBuilder', sfdcId ,'003 Guided_Resolution HTTP error response code');
            return resultNBA;
        }

        JSONParser parser = JSON.createParser(response.getBody());
        while((token = parser.nextToken()) != null) {
            // Parse the object
            if ((token = parser.getCurrentToken()) != JSONToken.END_OBJECT) {
                text = parser.getText();
                if ((token + '=' + text) == 'FIELD_NAME=next_best_action'){
                    token = parser.nextToken();
                    token = parser.nextToken();
                    token = parser.nextToken();
                    text = parser.getText();
                    next_best_action = text;
                    
                }
                if ((token + '=' + text) == 'FIELD_NAME=next_best_action_link'){
                    token = parser.nextToken();
                    token = parser.nextToken();
                    token = parser.nextToken();
                    text = parser.getText();
                    next_best_action_link = text;
                }
            }
        }
        
        if (String.isNotBlank(next_best_action)){
            resultNBA[0] = next_best_action;
            resultNBA[1] = next_best_action_link;
            return resultNBA ;
        }
        else{
            String errorMsg = '004 Guided_Resolution JSON response code not expected: ' + response.getBody();
            errorMsg += '. JSON request Body: ' + JSON.serialize(gr_overall);
            System.debug(errorMsg);
            //ExceptionHandler.logCalloutErrors(HttpResponse httpRes,String className, String sfdcId ,String module)
            ExceptionHandler.logCalloutErrors(response,'CaseClassificationProcessBuilder', sfdcId ,'004 Guided_Resolution JSON response code not expected');
            return resultNBA;
        }
    }
}