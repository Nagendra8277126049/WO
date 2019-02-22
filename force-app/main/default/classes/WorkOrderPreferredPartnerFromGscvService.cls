public class WorkOrderPreferredPartnerFromGscvService {
    @future(callout=true)
    public static void getPreferredPartnerFromGscv(ID workOrderId, String countryCode, String state, String city, String zipCode, String region) {
        System.debug ('getPreferredPartnerFromGscv - workOrderId: ' + workOrderId);
        Provider result = new Provider();
        
        List<GSCVDetails> deltaGSCVDetails = new List<GSCVDetails>();
        
        // set message values
        GSCVDetails gscvDetails = new GSCVDetails();

		gscvDetails.CountryCode = countryCode;
        gscvDetails.State = state;
        gscvDetails.City = city;
        gscvDetails.PostalCode = zipCode;
        //gscvDetails.ServiceType = 'Asset Recovery';
        gscvDetails.ServiceType = 'Install';
        gscvDetails.Region = region;
        
        deltaGSCVDetails.add(gscvDetails);
        
        System.debug(JSON.serialize(gscvDetails));
        
        // Call the webservice
        HttpResponse response = callout(JSON.serialize(gscvDetails));
            
        
        System.debug(response.getBody());
        
        Provider provider = (Provider)JSON.deserialize(response.getBody(), Provider.class);
        
        String partnerCode = provider.Code;
        
        System.debug(partnerCode);
        
        Partner_Details__c[] partnerDetails = [SELECT Id, Name, Code__c, DPS_Type__c, Call_Type__c FROM Partner_Details__c WHERE Code__c =:partnerCode LIMIT 1];
        
        if (partnerDetails.size() > 0) {
            
        }
        
        PartnerDetails partnerDetailsResponse = new PartnerDetails();
        
        System.debug (partnerDetailsResponse);
        
        System.debug('Update fields with values above');
        
        WorkOrder workOrderToUpdate;
        
        workOrderToUpdate =
            [SELECT PartnerName__c, Partner_Code__c, CallType__c, DPSType__c FROM WorkOrder
             WHERE Id = :workOrderId
             LIMIT 1
            ];
        
        if (workOrderToUpdate != null) {
            workOrderToUpdate.PartnerName__c = partnerDetails[0].Id;
            workOrderToUpdate.Partner_Code__c = partnerDetails[0].Code__C;
        	workOrderToUpdate.CallType__c = partnerDetails[0].Call_Type__c;
            
            if (workOrderToUpdate.DPSType__c == null) {
            	workOrderToUpdate.DPSType__c = partnerDetails[0].DPS_Type__c;
            }
           
            System.debug('PartnerName__c to update: ' + workOrderToUpdate.PartnerName__c);
            System.debug('Partner_Code__c to update: ' + workOrderToUpdate.Partner_Code__c);
            System.debug('CallType__c to update: ' + workOrderToUpdate.CallType__c);
            System.debug('DPSType__c to update: ' + workOrderToUpdate.DPSType__c);
            
        	update workOrderToUpdate;
            
            System.debug('Work Order updated');
    	}
        //return partnerDetailsResponse;
        
        //GetProvidersByCoverageResponseDetails providers = new GetProvidersByCoverageResponseDetails();
        
        //if (response.getStatusCode() != 200) {
        	//providers = (GetProvidersByCoverageResponseDetails)JSON.deserialize(response.getBody(), GetProvidersByCoverageResponseDetails.class);
            //result = providers.GetProvidersByCoverageResponse.GetProvidersByCoverageResult.Providers.Provider[0];
        	//System.debug(providers);
        //}
            
        //System.debug(providers.GetProvidersByCoverageResponse.GetProvidersByCoverageResult.Providers.Provider[0]);
        
        //return result
    }
    
    public static HttpResponse callout(string jsonMessage) {
        
        // http request
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:ResourceScheduling_Partner_By_Location');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        // Set the body as a JSON object
        request.setBody(jsonMessage);
        
        HttpResponse response = http.send(request);
        
        //System.debug('HTTP REQUEST SENT');
        //System.debug(jsonMessage);
        
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug(LoggingLevel.Error, '[ResourceScheduling - PartnerByLocation] Error HTTP response code: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            // message sent successfully
            System.debug('[ResourceScheduling - PartnerByLocation] - HTTP response code: 200');
        }
        
        return response;
    }
    
    // intern class request
    public class GSCVDetails {
        public String CountryCode;
        public String State;
        public String City;
        public String PostalCode;
        public String ServiceType;
        public String Region;
            
        //public GetProvidersByCoverage GetProvidersByCoverage;
    }
    
    public class GetProvidersByCoverage {
        public Request request;
    }
    
    public class Request {
        public List<Address> Address;
        public List<ServiceTypeCodes> ServiceTypeCode;
        public string PeriodCode;
    }
    
    public class Address {
        public string CountryCode;
        public string StateCode;
        public string CityName;
        public string Postcode;
    }
    
    public class ServiceTypeCodes {
        public string ServiceTypeCode;
    }
 
    // intern class response
    public class GetProvidersByCoverageResponseDetails {
        public GetProvidersByCoverageResponse GetProvidersByCoverageResponse;
    }    
    
    public class GetProvidersByCoverageResponse {
        public GetProvidersByCoverageResult GetProvidersByCoverageResult;
    }
    
    public class GetProvidersByCoverageResult {
        //public string ErrorId;
        //public string ErrorText;
        public Providers Providers;
    }
    
    public class Providers {
        public List<Provider> Provider;
    }
    
    public class Provider {
        public string Code;
        //public string Description;
        //public string ServiceTypeCode;
    }
    
    public class PartnerDetails {
        public String PartnerName;
        public String PartnerCode;
        public String DPSType;
        public String CallType;
    }
}