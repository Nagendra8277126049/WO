/* -----------------------------------------------------------------------------------------------------------------------
Name:       Service1CommonUlitity
Description:  This class contain common methods that could called within the application
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
11/02/2017     1.0     Rodrigo Carpio      Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
global with sharing class Service1CommonUlitity 
{    
    public Object sendAPIRequest(string apiCallOutObject, string strRequestBody, string strMethod, System.Type objClassToBeReturned)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       sendAPIRequest
    Description:  this functions calls REST API operation, this is only accessible within this class - application
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    11/02/2017     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try {
            JSONParser parser;
            Object objToBeReturn;
            
            Http httpProtocol = new Http();
            
            // Create HTTP request to send.
            HttpRequest request = new HttpRequest();
            
            // set end point
            request.setEndPoint(apiCallOutObject);
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(120000); 
            
            // initialize generator
            JSONGenerator gen = JSON.createGenerator(true);
                    
            // set request body
            request.setBody(strRequestBody);
            
            // Set the HTTP verb to GET.
            request.setMethod(strMethod);
            
            // Send the HTTP request and get the response.
            // The response is in JSON format.
            HttpResponse response = httpProtocol.send(request);
            
            // get JSONparser object
            parser = JSON.createParser(response.getBody());
            
            if(response.getStatusCode() == 200) {
                if (objClassToBeReturned != null) 
                {
                    objToBeReturn = parser.readValueAs(objClassToBeReturned);                                    
                }  
                else 
                    objToBeReturn = parser;        
            }
            else{
               /* ExceptionLogger.newAPIExceptionLogger(String.valueOf(response.getStatusCode()), 
                                                      'Service1CommonUlitity','sendAPIRequest', apiCallOutObject); */              
            }  
            return objToBeReturn;
        }
        catch(exception e){
           // ExceptionLogger.newExceptionLogger(e.getMessage(), 'Service1CommonUlitity','sendAPIRequest');
           ExceptionHandler.logHandledExceptions(e,'Service1CommonUlitity','sendAPIRequest','CaseManagement');             
            return null;
        }
        
        
    }
    
    @AuraEnabled
    public static List < String > getSelectOptions(sObject objObject, string fld)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getSelectOptions
    Description:  this functions returns value of picklist field provided - application
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    11/02/2017     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        List < String > allOpts = new list < String > ();
        try{
            //system.debug('objObject --->' + objObject);
            //system.debug('fld --->' + fld);
            
            // Get the object type of the SObject.
            Schema.sObjectType objType = objObject.getSObjectType();
            
            // Describe the SObject using its object type.
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            
            // Get a map of fields for the SObject
            map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
            
            // Get the list of picklist values for this field.
            list < Schema.PicklistEntry > values =
                fieldMap.get(fld).getDescribe().getPickListValues();
            
            // Add these values to the selectoption list.
            for (Schema.PicklistEntry a: values) {
                allOpts.add(a.getValue());
            }
            //system.debug('allOpts ---->' + allOpts);
            allOpts.sort();
            
            return allOpts;
        }
        catch(Exception e)
        {
           // ExceptionLogger.newExceptionLogger(e.getMessage(), 'Service1CommonUlitity','getSelectOptions'); 
           ExceptionHandler.logHandledExceptions(e,'Service1CommonUlitity','getSelectOptions','CaseManagement');           
            return null;
        }
           
     }
    
    public List<SelectOption> getSelectOptionValues(Schema.DescribeFieldResult fieldObject)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getSelectOptions
    Description:  this functions returns value of picklist field provided - application
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    11/02/2017     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try{
            List<SelectOption> selectOptions = new list<SelectOption>();
            
            for (Schema.Picklistentry picklistEntry : fieldObject.getPicklistValues())
            {
                selectOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
            }
        
            return selectOptions;
        }
        catch(Exception e)
        {
           // ExceptionLogger.newExceptionLogger(e.getMessage(), 'Service1CommonUlitity','getSelectOptions'); 
           ExceptionHandler.logHandledExceptions(e,'Service1CommonUlitity','getSelectOptionValues','CaseManagement');           
            return null;
        }
    }
        
}