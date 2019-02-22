public class CallTransferHandler {
        @AuraEnabled 
    public static String GetTransferCount(id ctId, String Agent_Id, String IVR_Input)
    {
        try{            
            String status;
            String transferCount='';
 	        Integer statusCode;
            List<Call_Transfer_Attributes__c> cta= [Select Call_Transcript__c, Transfer_Count__c, Updated_Transfer_Count__c, Get_TC_Context_Store__c from Call_Transfer_Attributes__c where Call_Transcript__c=:ctId Limit 1];
            if(!cta.isEmpty()){
                transferCount = cta[0].Transfer_Count__c;
                if (transferCount == '' || transferCount == null)
                {
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    String AgentName= UserInfo.getFirstName()+'_'+UserInfo.getLastName();
                    System.debug('agent id: ' + Agent_Id);
                    String AgentId=Agent_Id;
                    System.debug('putUrl: ' + label.voiceContextStorePath);
                    request.setEndpoint(label.voiceContextStorePath +IVR_Input +'/answer?touchpoint=VoiceSFDCAgent.' +AgentName +'.' +AgentId + '&apikey='+label.VoiceContextStoreApiKey);     
                    request.setHeader('Content-Type','application/json');
                    request.setMethod('GET');
                    System.debug('Request: ' + request);
                    HttpResponse response = http.send(request);
                    System.debug('======response======'+response);
                    System.debug('======responsebody======'+response.getBody());              
                    statusCode=response.getStatusCode();
                    if (statusCode == 200) 
                    {          
                        System.debug('200======response======'+response);
                        // If the request is successful, parse the JSON response.
                        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 
                        Map<String, Object> dataObj = (Map<String, Object>)results.get('data');
                        System.debug('data--' +results.get('data'));
                        transferCount=(String)dataObj.get('Transfer_Count');              
                        status = statusCode+'-Success';
                        System.debug('======count======'+transferCount);
                    }
                    else if(statusCode == 400)
                        status=statusCode+'-Invalid aliasId and touchpoint';
                    else if(statusCode == 404)
                        status=statusCode+'-No data found for the specified aliasId';
                    else if(statusCode == 500)
                        status=statusCode+'-Internal Server error';
                    else
                        status = statusCode+'Response Error';
               
                   cta[0].Transfer_Count__c = transferCount;
                   cta[0].Updated_Transfer_Count__c = transferCount;
                   cta[0].Get_TC_Context_Store__c=status;
                   update cta;
                }
            }
           	 
            
            return transferCount;
        }
        catch(Exception ex)
        { system.debug('=======Exception====='+ex); ExceptionHandler.logHandledExceptions(ex,'CallTransferHandler','GetTransferDetails','Voice'); return null;
        }                         
    }
        @AuraEnabled 
        public static String getCallTransferAttrId(Id CallTranscriptId){
            try{
                String sRecId = '';           
                List<Call_Transfer_Attributes__c> lstCallTransferRec = [Select Id from Call_Transfer_Attributes__c where Call_Transcript__c =:CallTranscriptId limit 1];            
                if(!lstCallTransferRec.isEmpty())
                {
                    sRecId = lstCallTransferRec[0].Id;              
                    System.debug('sRecId >>>'+sRecId);
                }   
                return sRecId;
            }
            catch(Exception e){
                System.debug('Exception occurred'+e.getMessage());
                return null;
            }       
        }
        // BRE CALL to get destination VDN for transfer
        @AuraEnabled
        public static String CallBRE_API(Id RecordId)
        {
            try
            {
                Call_Transfer_Attributes__c callTransferRec = 
                    [Select Customer_BUID__c, Customer_Type__c, Customer_Entitlement_Type_Group__c, Caller_Location__c, Product_Item_Class__c,
                     Product_Line__c, Product_Shipped_Date__c, ServiceTag_Entitlement_Type_Group__c, Updated_Transfer_Count__c, Transfer_Reason__c, 
                     Call_UCID__c,  Language__c, ANI__c, DNIS__c, Override_Asset_Entitlement__c, Override_Customer_Entitlement__c, Service_Tag__c
                     from Call_Transfer_Attributes__c where Id =: RecordId limit 1];
                System.debug('Call Transfer Attributes: '+ callTransferRec);
                String requestURL, requestBody, strResponse;
                String destVDN='';
                String IPAddress, envType, status, putCTStatus;
                Boolean isSandBox;
                Integer statusCode;
                BRERequest BRE_req = new BRERequest();
                BREResponse BRE_resp = new BREResponse();
                PageReference currPage = ApexPages.currentPage();
                if(currPage != null)
                {
                    IPAddress = currPage.getHeaders().get('True-Client-IP');
                    if (IPAddress == '' || IPAddress == null) {
                        IPAddress = currPage.getHeaders().get('X-Salesforce-SIP');
                    } // get IP address when no caching (sandbox, dev, secure urls)
                    if (IPAddress == '' || IPAddress == null) {
                        IPAddress = currPage.getHeaders().get('X-Forwarded-For');
                    }
                }
                if (!Test.isRunningTest() && (IPAddress == '' || IPAddress == null))
                    IPAddress = Auth.SessionManagement.getCurrentSession().get('SourceIp');
                isSandbox = [Select IsSandbox FROM Organization limit 1].IsSandbox;
                System.debug('IP Address = ' + IPAddress);
                System.debug('Is Sandbox = ' + isSandbox);
                if(isSandbox)
                    envType = 'NON_PROD';
                else
                    envType = 'PROD';
                if(callTransferRec != null)
                {
                    Date shipDt = callTransferRec.Product_Shipped_Date__c;
                    System.debug('Product Ship Date:' + shipDt);
                    Integer shipYr, shipMonth, shipDay;
                    String sShipDay, sShipMonth, shipDtString;
                    String sTagEntl = '', sCustEntl = '';
                    if(shipDt != null)
                    {
                        shipYr = shipDt.year();
                        shipMonth = shipDt.month();
                        shipDay = shipDt.day();
                        sShipDay = string.valueOf(shipDay);
                        sShipMonth = string.valueOf(shipMonth);
                        if(shipDay < 10)
                            sShipDay = '0'+ sShipDay;
                        if(shipMonth < 10)
                            sShipMonth = '0' + sShipMonth;
                        shipDtString = sShipMonth + '/' + sShipDay + '/' + string.valueOf(shipYr);
                    }
                    sTagEntl = callTransferRec.Override_Asset_Entitlement__c;
                    if(sTagEntl == '' || sTagEntl == 'None' || sTagEntl == null)
                        sTagEntl = callTransferRec.ServiceTag_Entitlement_Type_Group__c;
                    else
                         sTagEntl = callTransferRec.Customer_BUID__c+'_'+callTransferRec.Override_Asset_Entitlement__c;
                    sCustEntl = callTransferRec.Override_Customer_Entitlement__c;
                    if(sCustEntl == '' || sCustEntl == 'None' || sCustEntl == null)
                        sCustEntl = callTransferRec.Customer_Entitlement_Type_Group__c;
                    else
                        sCustEntl = callTransferRec.Customer_BUID__c+'_'+callTransferRec.Override_Customer_Entitlement__c;
                    System.debug('callTransferRec.ServiceTag_Entitlement_Type_Group__c: ' + callTransferRec.ServiceTag_Entitlement_Type_Group__c);
                    System.debug('callTransferRec.Override_Asset_Entitlement__c: '+ callTransferRec.Override_Asset_Entitlement__c);
    
                    BRE_req.interactionId = callTransferRec.Call_UCID__c;
                    BRE_req.to = callTransferRec.DNIS__c;
                    BRE_req.fromNum = callTransferRec.ANI__c;
                    BRE_req.channel = 'VOICE';
                    BRE_req.decisionFunctionName = 'Lex_Interaction_Controller';           
                    BRE_req.segAttributes.DNIS_Country_Code = callTransferRec.Caller_Location__c;
                    BRE_req.segAttributes.Customer_Type_Group = callTransferRec.Customer_Type__c;
                    BRE_req.segAttributes.ServiceTag_Entitlement_Type_Group = sTagEntl;
                    BRE_req.segAttributes.Customer_Entitlement_Type_Group = sCustEntl; 
                    BRE_req.segAttributes.Product_Line_Group = callTransferRec.Product_Line__c;
                    BRE_req.segAttributes.Product_Item_Class = callTransferRec.Product_Item_Class__c;
                    BRE_req.segAttributes.Product_Shipped_Date = shipDtString; //string.valueof(shipDtString);
                    BRE_req.segAttributes.SDS_Transfer_Reason_Group = callTransferRec.Transfer_Reason__c;
                    BRE_req.segAttributes.Transfer_Count = string.valueOf(callTransferRec.Updated_Transfer_Count__c);
                    
                    BRE_req.customParameters.Interaction_Type = 'Service_Tag';
                    BRE_req.customParameters.Client_IP = IPAddress;
                    BRE_req.customParameters.Client_App = 'VOICE.SFDC.Service_Tag';
                    BRE_req.customParameters.Interaction_ID = callTransferRec.Service_Tag__c;//Changed the value callTransferRec.Call_UCID__c for defect 5990424;
                    BRE_req.customParameters.Language = callTransferRec.Language__c;
                    BRE_req.customParameters.Request_Type = envType;
                    
                    requestBody = JSON.serialize(BRE_req);
                    System.debug(requestBody);
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    HttpResponse response = new HttpResponse();
                    requestURL = Label.BRE_CallTransfer + '?apikey=' + Label.BRE_CallTransferAPIKey;
                    request.setEndpoint(requestURL);
                    request.setHeader('Content-Type', 'application/json');
                    request.setHeader('Accept','application/json');
                    request.setBody(requestBody);
                    request.setMethod('GET');
                    request.setTimeout(10000);
                    response = http.send(request);
                    System.debug(response);
                    strResponse = response.getBody();
                    System.debug('response:--> ' + strResponse); 
                    statusCode=response.getStatusCode();
                    if (statusCode == 200)
                    {
                        System.debug('Inside response code 200');
                        BRE_resp = (BREResponse) JSON.deserialize(strResponse, BREResponse.class); 
                        System.debug('BRE_resp = ' + BRE_resp);
                        destVDN = BRE_resp.selectedDestAddress;
                        status = statusCode+'Success-Destination VDN:'+destVDN;
                        System.debug('Transfer to VDN: ' + destVDN);
                    }
                    else
                        status = statusCode+'-Error from BRE';
                    callTransferRec.BRE_Response__c=status;
                    callTransferRec.Transferred_To_Queue__c=destVDN;
                    update callTransferRec;
                }
                return destVDN;
            }
            catch(Exception ex)
            { 
                system.debug('=======Exception====='+ex); ExceptionHandler.logHandledExceptions(ex,'CallTransferHandler','CallBRE_API','Voice'); 
                return null;
            }
        } 
        @AuraEnabled
        public static void UpdateTransferCount(Id ctaId)
        {
            try{           
                jsonWrapper wrap = new jsonWrapper();
                String aliasId;
                String transfer_count;
                Integer transfer_count_update;
                Call_Transfer_Attributes__c transferAttr = [Select Transfer_Count__c, Updated_Transfer_Count__c, Transfer_Reason__c,Call_Transcript__r.Agent_ID__c,Call_Transcript__r.IVR_Input__c from Call_Transfer_Attributes__c where id=:ctaId LIMIT 1];       
                if(transferAttr!=null)
                {
                aliasId = transferAttr.Call_Transcript__r.IVR_Input__c;                     
                if((transferAttr.Transfer_Count__c!='' && transferAttr.Transfer_Count__c != null) && (transferAttr.Updated_Transfer_Count__c != null && transferAttr.Updated_Transfer_Count__c != ''))
                { 
                    if(transferAttr.Updated_Transfer_Count__c >=transferAttr.Transfer_Count__c)
                        transfer_count=transferAttr.Updated_Transfer_Count__c;                   
                    else
                        transfer_count=transferAttr.Transfer_Count__c;                 
                      transfer_count_update= Integer.valueOf(transfer_count);
                      transfer_count_update = transfer_count_update+1;                
                      wrap.data.Transfer_Count = String.valueOf(transfer_count_update);
                }
                else
                   wrap.data.Transfer_Count = '1';
                wrap.data.Transfer_Reason= transferAttr.Transfer_Reason__c;
                
                String jsonBody = json.serialize(wrap); 
                System.debug('JSON Request for TC Put >>>>>>>'+jsonBody);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                String AgentName= UserInfo.getFirstName()+'_'+UserInfo.getLastName();
                String AgentId=transferAttr.Call_Transcript__r.Agent_ID__c;
                String putUrl=label.voiceContextStorePath +'Service_Tag/' +aliasId +'/transfer?touchpoint=VoiceSFDCAgent.'+AgentName+'.'+AgentId +'&apikey='+label.VoiceContextStoreApiKey;
                request.setEndpoint(putUrl);
                request.setMethod('PUT');
                request.setHeader('Content-Type', 'application/json');
                
                // Set the body as a JSON object
                request.setBody(jsonBody );
                HttpResponse response = http.send(request);
                System.debug('Request for TC Put >>>>>>>'+request);
                Integer statusCode=response.getStatusCode();
                System.debug('Resosonse for TC Put >>>>>>>'+response);
                String status='';
                if (statusCode == 200) {          
                    status = statusCode+'-Success';
                    transferAttr.Updated_Transfer_Count__c = wrap.data.Transfer_Count;
                }
                else if(statusCode == 400)
                    status = statusCode+'-Invalid interaction type,aliasId,touchpoint,KVPs';
                else if(statusCode == 404)
                    status = statusCode+'-No data and group id found for the specified aliasId';
                else if(statusCode == 500)
                    status = statusCode+'-Internal Server error';
                else
                    status = statusCode+'-Response Error';
                transferAttr.Update_TC_Context_Store__c=status;
                update transferAttr;  
                }
            }
            catch(Exception ex)
            { 
                system.debug('=======Exception====='+ex);
                ExceptionHandler.logHandledExceptions(ex,'CallTransferHandler','UpdateTransferDetails','Voice');
            }                                
        }
        public class jsonWrapper{
            public updateTCReq data;
            public jsonWrapper(){
                data = new updateTCReq();
            }
        }
        public class updateTCReq{
            public String Transfer_Count{get;set;}
            public String Transfer_Reason {get;set;}
        }
    }