/* -----------------------------------------------------------------------------------------------------------------------
Name:         ChatRouting
Description:  Rest class to check the Routing rule and Business Hours for Chat routing
----------------------------------------------------------------------------------------------------------------------------
Date          Version        Author               Summary of Changes 
---------------------------------------------------------------------------------------------------------------------------
06/28/2018     1.0        	Pavan Samanthapudi			August Release
04/29/2018     1.1          Sunil Neelam				November Release:US# 5412135 Added code to insert a record in Chat Routing Object for Reporting purpose
-------------------------------------------------------------------------------------------------------------------------- */

@RestResource(urlMapping='/ChatRouting/*')
Global class ChatRouting {
    @HttpPost
    global static void PerformChatRouting()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        // Instantiate the flow:Perform Chat Routing and pass the input arguments.
        
        ChatRoutingRequest chatReq=(ChatRoutingRequest) Json.deserialize(req.requestBody.toString(), ChatRoutingRequest.class);
        CheckAvailabilityUtility.ResponseWrapper resWrap = new CheckAvailabilityUtility.ResponseWrapper();
        
        Id PM_Chat_RecTypeId = Schema.SObjectType.Priority_Mapping__c.getRecordTypeInfosByName().get('Chat').getRecordTypeId();
        Id RR_Chat_RecTypeId = Schema.SObjectType.Routing_Rules__c.getRecordTypeInfosByName().get('Chat').getRecordTypeId();        
        Map<String, Object> params = new Map<String, Object>();
        params.put('Flow_Region', chatReq.Region);
        params.put('Flow_BUID', chatReq.BUID);
        params.put('Flow_Extra1', chatReq.Extra1);
        params.put('Flow_Language', chatReq.Language);
        if (chatReq.OOW == 'Y')
            chatReq.PremierType = System.Label.RR_PremierType_Expired_Label;
        params.put('Flow_PremierType', chatReq.PremierType);
        params.put('Flow_LocalChannel', chatReq.LocalChannel);
        params.put('Flow_CompanyNumber', chatReq.CompanyNumber);
        params.put('Flow_FamilyName', chatReq.FamilyName);
        params.put('Flow_ProductCode', chatReq.ProductCode);
        params.put('Flow_PM_RecordTypeId', PM_Chat_RecTypeId);
        params.put('Flow_RR_RecordTypeId', RR_Chat_RecTypeId);
        params.put('Flow_Offer', chatReq.Offer);
        
        Flow.Interview.Perform_Chat_Routing ChatRoutingFlow = new Flow.Interview.Perform_Chat_Routing(params);
        ChatRoutingFlow.start();
        
        // Obtain the results
        
        String RR_ChatbuttonId = (string)ChatRoutingFlow.getVariableValue('Flow_ChatButtonId');
        String RR_ResumeChatButtonId = (string)ChatRoutingFlow.getVariableValue('Flow_ResumeChatButtonId');
        String RR_RoutingFailedFlg = (string)ChatRoutingFlow.getVariableValue('Flow_RoutingFailed');
        String RR_QueueName = (string)ChatRoutingFlow.getVariableValue('Flow_QueueName');
        String PriorityMappingRuleName=(string)ChatRoutingFlow.getVariableValue('Flow_PriorityMappingName');
        String RoutingRuleRecordNumber=(string)ChatRoutingFlow.getVariableValue('RR_RecordNumber');
        String Offer=(string)ChatRoutingFlow.getVariableValue('Flow_Offer');
        
        String OOBFlg = 'N';
        String BusinessHours = '';
        Boolean isWithinBusHrs ;
        String[] BusHrs;
        if (RR_RoutingFailedFlg == 'N'){
            //call business hours logic and set OOBFlg = Y if Queue is out of business hours
            resWrap = CheckAvailabilityUtility.checkWithInBusinessHours(RR_QueueName);
            if(resWrap!=null)
            {
                isWithinBusHrs = resWrap.isWithInBusinessHours;
                BusinessHours = resWrap.businessHoursTiming;
                if (isWithinBusHrs!=null && isWithinBusHrs == false)
                {
                    OOBFlg = 'Y';
                }
            }
        }
        else{
            RR_ChatbuttonId = '';
            RR_ResumeChatButtonId = '';
            OOBFlg = '';
        }
        
        Chat_Routing__c cr=new Chat_Routing__c();
        cr.BUID__c=chatReq.BUID;
        cr.Chat_Button_Id__c=RR_ChatbuttonId;
        cr.Extra1__c=chatReq.Extra1;
        cr.Language__c=chatReq.Language;
        cr.Line_Of_Business__c=chatReq.FamilyName;
        cr.Local_Channel__c=chatReq.LocalChannel;
        if(RR_RoutingFailedFlg == 'N' && isWithinBusHrs==false)
        {
            cr.Out_Of_Business_Hours__c=true;
            cr.Reason_for_Routing_Failure__c = 'Queue Business Hours Out Of Operation';   
        }
        else if(RR_RoutingFailedFlg == 'Y')
        {
            cr.Reason_for_Routing_Failure__c = 'No Matching Routing Rule Found';   
        }
        
        cr.Service_Tag__c =chatReq.ServiceTag;
        cr.Premier_Type__c=chatReq.PremierType;
        cr.Priority_Mapping_Rule_Name__c=PriorityMappingRuleName;
        cr.Product_Code__c=chatReq.ProductCode;
        cr.Queue_Name__c=RR_QueueName;
        cr.Region__c=chatReq.Region;
        cr.Routing_Rules_Record_Number__c=RoutingRuleRecordNumber;
        cr.Resume_Chat_Button_Id__c=RR_ResumeChatButtonId;
        cr.Company_Number__c=chatReq.CompanyNumber;
        cr.Offer__c=chatReq.Offer;
        insert cr;
        
        ChatRoutingResponse crr = New ChatRoutingResponse();
        crr.ChatButtonId = RR_ChatbuttonId;
        crr.ResumeChatButtonId = RR_ResumeChatButtonId;
        crr.RoutingFailedFlag = RR_RoutingFailedFlg;      
        crr.BusinessHoursTiming = BusinessHours;
        crr.OutOfBusinessHoursFlag = OOBFlg;
        crr.NextAvailShiftStart = resWrap.nextAvailableShiftStartTiming;
        crr.isStandardShift= resWrap.isStandardShift;
        crr.ExceptionHours = resWrap.exceptionHours;
        res.responseBody = blob.valueOf(JSON.serialize(crr));    
    }
    
    //Wrapper Class for Response
    Public Class ChatRoutingResponse{
        Public String ChatButtonId;
        Public String ResumeChatButtonId;
        Public String BusinessHoursTiming;
        public String RoutingFailedFlag;
        public String OutOfBusinessHoursFlag;
        Public String NextAvailShiftStart;
        Public String ExceptionHours;
        Public String isStandardShift;
    }
    
    //Wrapper Class for Request
    Public Class ChatRoutingRequest{
        Public String Region;
        Public String BUID;
        Public String Country;
        Public String Extra1;
        Public String Language;
        Public String PremierType;
        Public String OOW;
        Public String LocalChannel;
        Public String CompanyNumber;
        Public String FamilyName;
        Public String ProductCode;
        Public String ServiceTag;
        Public String Offer;
    }
    
    
}