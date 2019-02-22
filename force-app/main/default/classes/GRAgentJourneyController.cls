public with sharing class GRAgentJourneyController {
    /*******************************************************************************************************
Name: GRAgentJourneyController.apxc
Description: Controller for agent journey, Integration to Support Assist API
Story 5772346: KMT GR Agent Journey - Support Assist fields to be available for Flows
*******************************************************************************************************
Date         Version            Author                Summary of Changes 
*******************************************************************************************************
3/12/2018     1.0       	Naveen K N               Initial draft  
******************************************************************************************************/
    
    @InvocableMethod
    public static List<String> GetAttributesFromSupportAssist(List<String> ServiceTag){
        list<String> SAattributes = new list<String>();
        String BIOSVersion, OS, sAtt; 
        try{
            if(ServiceTag != null){
                system.debug('GRAgentJourneyController class, GetAttributesFromSupportAssist method has started, Service tag is ' + ServiceTag);
                //String APIURL = 'https://dit.apidp.dell.com/KMT/GuidedResolution/AgentJourney/v1/assetOverview/'+ ServiceTag[0] + '?apikey=fcfa346b-5615-4710-881d-dcd36f3b1a6a'; 
                String APIURL = Label.GR_DPSystemOverviewURL + ServiceTag[0] + Label.GR_DPSystemOverviewKEY;
                
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                //req.setHeader('Token', '1df7616d-1e13-4edd-9a51-eef7b361aff8');
                req.setHeader('Token', Label.GR_DPSystemOverviewTOKEN);
                req.setEndpoint(APIURL);
                Http http = new Http();
                HttpResponse res = http.send(req);
                Integer statusCode = res.getStatusCode();
                system.debug('statusCode is ' + statusCode);
                if(statusCode == 200){
                    system.debug(res.getBody());
                    map<String, object> m = (map<String, object>) JSON.deserializeUntyped(res.getBody());
                    system.debug(m.get('biosVersion').toString());
                    BIOSVersion = m.get('biosVersion').toString();
                    if(BIOSVersion == null || BIOSVersion == ''){
                        BIOSVersion = 'NA';    
                    }
                    
                    OS = m.get('os').toString();
                    if(OS == null || os == ''){
                        OS = 'NA';    
                    }else if (OS.contains('7')){
                        OS = 'Windows 7';
                    }else if (OS.contains('8')){
                        OS = 'Windows 8/8.1';
                    }else if (OS.contains('10')){
                        OS = 'Windows 10';
                    }
                    sAtt = BIOSVersion + ';' + OS;
                }
            }
            SAattributes.add(sAtt);
        }
        catch(exception e){
            //Handling exception
            ExceptionHandler.logHandledExceptions(e,'GRAgentJourneyController','GetAttributesFromSupportAssist','KMT');
        }
        system.debug('return list is' + SAattributes);
        return SAattributes;
    }
}