@isTest
private class ValidateDSPinGSCVTest {
    @isTest private static void unitTest(){
        Test.startTest(); 
        ValidateDSPinGSCV.GSCVInputs Inp		= 	new ValidateDSPinGSCV.GSCVInputs();
        List<ValidateDSPinGSCV.GSCVInputs> I	=	new List<ValidateDSPinGSCV.GSCVInputs>();
        GetBestFitDSP__x mockRequest = new GetBestFitDSP__x();
            mockRequest.DSP__c='XYZ';
            mockRequest.ResponseCode__c='100';
            mockRequest.ISPDSPScheduleEnabled__c='Y';
            mockRequest.CommunicationChannel__c = 'B2B';
            mockRequest.DSPSchedulingURL__c = 'xyc';
        ValidateDSPinGSCV.mockrequestGetBestFitDSP.add(mockRequest);
        Inp.BatteryShipFlag = 	'N';
        Inp.Billable		=	'N';
        Inp.BUID			=	'11';
        Inp.CCN				=	 '';
        Inp.City			=	'New York';
        Inp.ISOCountryCode	=	'US';
        Inp.ItemClass		=	'';
        Inp.LOB				=	'4IN';
        Inp.OOWFlag			=	'N';
        Inp.PostalCode		=	'10928';
        Inp.PreferedDSP		=	'';
        Inp.PreferenceType	=	'EXCLUSION';
        Inp.RegionId		=	'1';
        Inp.ServiceHour		=	'10x5';
        Inp.ServiceLevel	=	'Next Business Day';
        Inp.ServiceSubType	=	'Parts and Labor';
        Inp.ServiceTag		=	'';
        Inp.ServiceProviderCode	=	'';
        Inp.State			=	'NY';
        I.add(Inp);
		ValidateDSPinGSCV.GetDSP(I);
        Test.stopTest();
    }
}