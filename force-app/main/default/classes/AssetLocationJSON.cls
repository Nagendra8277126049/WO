/*
 * This class is used to define the structure for Asset Detail Response
 */
public with sharing class AssetLocationJSON {

    public AssetDetailsResponse AssetDetailsResponse;
    public MessageHeader MessageHeader;
    
	public with sharing class AssetDetailsResponse {
        public String AddressLine3;  //ABC
        public String AddressLine2;  //AP
        public String AddressLine1;  //TEST
        public String ServiceTag;  //APNONT1
        public String State;  //Karnataka
        public String AddressLine4;  //TEST
        public String Country;  //KTK:BANGALORE
        public String PostalCode;  //560066
        public String City;  //WHITE FIELD
    }  
    
	public with sharing class MessageHeader {
   		public ReturnMessaging ReturnMessaging;
  	}
    
  	public with sharing class ReturnMessaging {
    	public String Type;  //SUCCESS
    	public String Details;  //100000, Operation successful. 
    	public String Message;  //Operation completed successfully
    	public String Code;  //100
	}
    
    public static AssetLocationJSON parse(String json){
        try {
            return (AssetLocationJSON) System.JSON.deserialize(json, AssetLocationJSON.class);
		}catch(exception e){
        	ExceptionHandler.logHandledExceptions(e,'AssetLocationJSON','parse','AssetManagement');             
            return null;
        }
  	}
}