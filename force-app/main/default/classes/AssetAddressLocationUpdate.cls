/* -----------------------------------------------------------------------------------------------------------------------
Name:       AssetAddressLocationUpdate
Description:  This class contain method that handles asset address location update call - story #4316381 
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
03/30/2018     1.0     Rodrigo Carpio      Initial Release
06/11/2018     1.1     Sri Harsha G    
07/10/2018     1.2     Brundha Rajkumar    Task #5287232
01/28/2019     1.2     Sri Harsha G        DEFECT 6051876 - Updated Code to Split the new lines correctly
02/14/2019     1.3     Sri Harsha G        DEFECT 6215690
-------------------------------------------------------------------------------------------------------------------------- */
public class AssetAddressLocationUpdate {
    
    // Method to Invoke to Update Asset Address
    @InvocableMethod(label='Update Asset Address Location' description='Call Bill to update asset address location')
    public static List<String> updateAssetAddressLocation(list<string> workOrderIdList)
    /* ---------------/--------------------------------------------------------------------------------------------------------
    Name:       updateAssetAddressLocation
    Description:  this functions makes a call to BIL to update the asset address information 
    Input: servicetag - 
    Output: Address information wrapper
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    03/29/2018     1.0     Rodrigo Carpio      Initial Release
    06/11/2018     1.1     Sri Harsha G        Updated Code - DEFECT 5149770
	01/28/2019     1.2     Sri Harsha G        DEFECT 6051876 - Updated Code to Split the new lines correctly
	02/14/2019     1.3     Sri Harsha G        DEFECT 6215690
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        try
        {
            list<string> returnStr;
            list<string> streetAddress = new list<string>();
            
            list<WorkOrder> assetAddress = new list<WorkOrder>();
            List<UpdateAssetServiceAddress__x> assetLocationList = new List<UpdateAssetServiceAddress__x>();
    
            assetAddress = [SELECT ServiceTag__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,Address_Line_4__c,Street,City, City__c,Country,CountryCode,PostalCode,State,StateCode,AssetPartyLocationId__c,PartyLocationId__c,City_New__C,City_New__r.Name FROM WorkOrder WHERE Id IN:workOrderIdList LIMIT 1000];
            
            UpdateAssetServiceAddress__x assetLocation;
            
            for (WorkOrder itemWO: assetAddress)
            {
                assetLocation = new UpdateAssetServiceAddress__x();
                
                assetLocation.ServiceTagId__c= itemWO.ServiceTag__c;
                assetLocation.ResponseCode__c ='100';
                assetLocation.PostalCode__c = itemWO.PostalCode;
                if(String.isNotBlank(itemWO.CountryCode) &&	System.Label.LatamCountries.contains(itemWO.CountryCode)){
                    if (String.isNotBlank(itemWO.City_New__r.Name)){
                        assetLocation.City__c= itemWO.City_New__r.Name;
                    } else if(String.isNotBlank(itemWO.City__c)){
                        assetLocation.City__c= itemWO.City__c;
                    } else {
                        assetLocation.City__c= '';
                    }
                } else if (String.isNotBlank(itemWO.City)){
                    assetLocation.City__c= itemWO.City;
                } else{
                    assetLocation.City__c= '';
                }
                assetLocation.ResponseMessage__c='Operation Completed Successfully';
                assetLocation.AssetPartyLocationId__c = itemWO.AssetPartyLocationId__c;
                assetLocation.PartyLocationId__c= itemWO.PartyLocationId__c;
                assetLocation.uuid__c = '';
                assetLocation.State__c= itemWO.StateCode;            
                assetLocation.Country__c= itemWO.CountryCode;
                
                streetAddress.clear();
                //if(itemWO.CountryCode<>NULL && System.Label.LatamCountries.contains(itemWO.CountryCode)){
                if(string.isNOtBlank(itemWO.CountryCode) && System.Label.LatamCountries.contains(itemWO.CountryCode)){
                    //System.debug('Akhil++ Inside latamCountry AssetAddresUpdate');
                    //if(itemWO.Address_Line_1__c<>NULL){
                    if(string.isNOtBlank(itemWO.Address_Line_1__c)){
                    	assetLocation.AddressLine1__c=itemWO.Address_Line_1__c;
                    } 
                    //if(itemWO.Address_Line_2__c<>NULL){
                    if(string.isNOtBlank(itemWO.Address_Line_2__c)){
                    	assetLocation.AddressLine2__c=itemWO.Address_Line_2__c;
                    }
                    //if(itemWO.Address_Line_3__c<>NULL){
                    if(string.isNOtBlank(itemWO.Address_Line_3__c)){
                    	assetLocation.AddressLine3__c=itemWO.Address_Line_3__c;
                    } 
                    //if(itemWO.Address_Line_4__c<>NULL){
                    if(string.isNOtBlank(itemWO.Address_Line_4__c)){
                    	assetLocation.AddressLine4__c=itemWO.Address_Line_4__c;
                    } 
                }else{
                    //if(itemWO.Street!=null){ // Added if conditions for the task #5287232
                    //
                    if(String.isNotBlank(itemWO.Street)){
						//streetAddress = itemWO.Street.split('\n\r'); - Commented for DEFECT 6051876
                        // Added for DEFECT 6051876 - Starts Here
                        itemWO.Street.replace('\r\n', '\n').replace('\r', '\n').replace('\n\r', '\n');
                    	streetAddress = itemWO.Street.split('\n');
                        // Added for DEFECT 6051876 - Ends Here
                    }
                                    
                    if (String.isNotBlank(streetAddress[0])){
                        assetLocation.AddressLine1__c = streetAddress[0] ;
                    }
                    
                    if (streetAddress.size()>1) {
                        if (String.isNotBlank(streetAddress[1])){
                            assetLocation.AddressLine2__c= streetAddress[1];
                        }
                    }
                        
                    if (streetAddress.size()>2) {
                        if (String.isNotBlank(streetAddress[2])){
                            assetLocation.AddressLine3__c= streetAddress[2];
                        }
                    }
                    if (streetAddress.size()>3) {
                        if (String.isNotBlank(streetAddress[3])){          
                            assetLocation.AddressLine4__c= streetAddress[3];
                        }
                    }
                }
                /*
                System.debug('Akhil++ UpdAssAddress AddressLine1'+assetLocation.AddressLine1__c);
                System.debug('Akhil++ UpdAssAddress AddressLine2'+assetLocation.AddressLine2__c);
                System.debug('Akhil++ UpdAssAddress AddressLine3'+assetLocation.AddressLine3__c);
                System.debug('Akhil++ UpdAssAddress AddressLine4'+assetLocation.AddressLine4__c);
                */
				assetLocationList.add(assetLocation);
            }
            
            if(!assetLocationList.isEmpty() && assetLocationList!=null && assetLocationList.size()>0) {
                List<Database.SaveResult> sr = Database.updateAsync(assetLocationList);
            }
            
            return returnStr;
        }
        catch(exception e){            
            ExceptionHandler.logHandledExceptions(e,'AssetAddressLocationUpdate','updateAssetAddressLocation','Dispatch Management');
            return null;
        }
    }
}