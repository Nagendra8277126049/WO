/* -----------------------------------------------------------------------------------------------------------------------
Name:       ValidateDSPinGSCV
Description:  This class contain method that handles validate DSP / Get bestfit DSP in GSCV - story #5677115/5181761 
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
09/27/2018     1.0    Archana Giliyar       Initial Release
01/18/2019	   1.1	  Rodrigo Carpio        DEFECT 6072406
-------------------------------------------------------------------*/


public class ValidateDSPinGSCV {
    @TestVisible public static List<GetBestFitDSP__x> mockrequestGetBestFitDSP= new List<GetBestFitDSP__x>();
    public class GSCVOutputs{
	
	@InvocableVariable
		public string ValidDSP;
		
	@InvocableVariable
		public string ResponseCode;
		
	@InvocableVariable
		public string DSPScheduleEnabled;

	@InvocableVariable
		public string CommunicationChannel;

	@InvocableVariable
		public string DSPSchedulingURL;			

	}
    
    public class GSCVInputs{
    @InvocableVariable
		public string ServiceTag;
	@InvocableVariable
		public string BUID;
    @InvocableVariable
		public string City;
	@InvocableVariable
		public string State;
    @InvocableVariable
		public string ItemClass;
	@InvocableVariable
		public string ISOCountryCode;
    @InvocableVariable
		public string RegionId;
	@InvocableVariable
		public string Billable;
    @InvocableVariable
		public string PostalCode;
	@InvocableVariable
		public string ServiceHour; 
    @InvocableVariable
		public string ServiceSubType;
	@InvocableVariable
		public string ServiceLevel;
    @InvocableVariable
		public string LOB;
	@InvocableVariable
		public string OOWFlag;
    @InvocableVariable
		public string ServiceProviderCode;
	@InvocableVariable
		public string PreferenceType;
     @InvocableVariable
		public string BatteryShipFlag;
      @InvocableVariable
		public string CCN;
      @InvocableVariable
		public string PreferedDSP;
      @InvocableVariable
		public string WorkOrderNumber; // added for DEFECT 6072406
    }
	@InvocableMethod(label = 'Invoke GSCV')
	public static List <GSCVOutputs> GetDSP (List<GSCVInputs> requests){
		try{           
			
            List<GetBestFitDSP__x> getBestFitRecord = new List<GetBestFitDSP__x>();
			getBestFitRecord 	= [SELECT DSP__c, ISPDSPScheduleEnabled__c, DSPSchedulingURL__c, CommunicationChannel__c,ResponseCode__c FROM GetBestFitDSP__x
                                WHERE ServiceTagId__c = :requests[0].ServiceTag AND BUID__c = :requests[0].BUID
                                AND City__c = :requests[0].City AND State__c = :requests[0].State AND ItemClass__c = :requests[0].ItemClass
                                AND ISOCountryCode__c = :requests[0].ISOCountryCode
                                AND Billable__c = :requests[0].Billable AND PostalCode__c = :requests[0].PostalCode AND ServiceHour__c = :requests[0].ServiceHour
                                AND ServiceSubType__c = :requests[0].ServiceSubType AND ServiceLevel__c = :requests[0].ServiceLevel AND RegionID__c = :requests[0].RegionID
                                AND LOB__c = :requests[0].LOB AND OOWFlag__c = :requests[0].OOWFlag
                                AND PreferenceType__c = :requests[0].PreferenceType
                                AND ServiceProviderCode__c = :requests[0].ServiceProviderCode AND PreferedDSP__c = :requests[0].PreferedDSP
                                AND WorkOrderNumber__c = :requests[0].WorkOrderNumber // added for DEFECT 6072406
                                LIMIT 1	
                            ];
            if(Test.isRunningTest())
            {
                getBestFitRecord.addAll(mockrequestGetBestFitDSP);
            }
			List < GSCVOutputs > Outputs = new List < GSCVOutputs > ();
			GSCVOutputs Op 	= 	new GSCVOutputs();
			if(!getBestFitRecord.isEmpty() && getBestFitRecord!=null && getBestFitRecord.size()>0){
                if(string.isNotBlank(getBestFitRecord[0].ResponseCode__c) && string.isNotEmpty(getBestFitRecord[0].ResponseCode__c)){
						Op.ValidDSP						=	getBestFitRecord[0].DSP__c;	
						Op.ResponseCode					=	getBestFitRecord[0].ResponseCode__c;
						Op.DSPScheduleEnabled			=	getBestFitRecord[0].ISPDSPScheduleEnabled__c;
						Op.CommunicationChannel			=	getBestFitRecord[0].CommunicationChannel__c;
						Op.DSPSchedulingURL				=	getBestFitRecord[0].DSPSchedulingURL__c;						
						Outputs.add(Op);
                }
			}
            return Outputs;
		}
		catch(exception e)
		{
			ExceptionHandler.logHandledExceptions(e,'ValidateDSPinGSCV','GetDSP','Dispatch Management');
			return null;
        }
	}
}