/* -----------------------------------------------------------------------------------------------------------------------
Name:       Service1CommonAPIUlitity
Description:  This class contain common API operation call - application
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
11/02/2017     1.0     Rodrigo Carpio      Initial Release
10/07/2018     1.1     Brundha Rajkumar    task #5317972
-------------------------------------------------------------------------------------------------------------------------- */
global with sharing class Service1CommonAPIUlitity {
    @TestVisible public integer statusCode{get; private set;}
    @TestVisible public string statusMessage{get; private set;}
    @TestVisible public Object responseObject{get; private set;}
    @TestVisible public HttpResponse responseHTTPObject{get; private set;}
    
    public void sendAPIRequest(string apiCallOutObject, string strRequestBody, 
                               string strMethod, System.Type objClassToBeReturned)
        /* -----------------------------------------------------------------------------------------------------------------------
Name:       sendAPIRequest
Description:  This class contain common API operation call - application
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
11/02/2017     1.0     Rodrigo Carpio      Initial Release
16/08/2018     1.1     Srikanth reddy      Defect #5450123
-------------------------------------------------------------------------------------------------------------------------- */
    {
        try{
            Http httpProtocol = new Http();
            
            // Create HTTP request to send.
            HttpRequest request = new HttpRequest();
            
            HttpResponse response = new HttpResponse();
            // set end point
            request.setEndPoint(apiCallOutObject);
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            
            /*Timeout Updated to 5sec - After Architectural Review */
            /* Updated by Sri Harsha G - 12Dec2017 */
            //request.setTimeout(120000); 
            
            request.setTimeout(5000);
            
            // initialize generator
            JSONGenerator gen = JSON.createGenerator(true);
            
            // set request body
            // Added condition for the task #5317972
            if(!string.isEmpty(strRequestBody)){
                request.setBody(strRequestBody);
            }
               
               // Set the HTTP verb to GET.
               request.setMethod(strMethod);
               
               // Send the HTTP request and get the response.
               // The response is in JSON format.
               response = httpProtocol.send(request);
               
               // get JSONparser object
               JSONParser parser = JSON.createParser(response.getBody());
               Object obj;
               
               statusCode = response.getStatusCode();
               statusMessage = response.getStatus();
               
               responseHTTPObject = new HttpResponse();
               if(statusCode == 200) 
               {
                   if (objClassToBeReturned != null) 
                   {
                       ResponseObject = parser.readValueAs(objClassToBeReturned);                                    
                   }  
                   else 
                       ResponseObject = parser;        
               }
               else{
                   /*  ExceptionLogger.newAPIExceptionLogger(String.valueOf(response.getStatusCode()), 
'Service1CommonAPIUlitity','sendAPIRequest', apiCallOutObject); */ 
                   
                   responseHTTPObject = response;
               }
               
               }
               catch(exception e){
                   // ExceptionLogger.newExceptionLogger(e.getMessage(), 'Service1CommonAPIUlitity','sendAPIRequest');
                   ExceptionHandler.logHandledExceptions(e,'Service1CommonAPIUlitity','sendAPIRequest','CaseManagement');            
               }
               }        
               }