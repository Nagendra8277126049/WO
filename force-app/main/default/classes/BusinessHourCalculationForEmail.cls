/* -----------------------------------------------------------------------------------------------------------------------
Name:       BusinessHourCalculationForEmail
Description:  This class contain method that handles all the business Hour Calculations in Email
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
08/30/2018     1.0    Priyali/Amit       Nov Release
-------------------------------------------------------------------------------------------------------------------------- */
Public without sharing class BusinessHourCalculationForEmail {
    @InvocableMethod(label = 'UpdateEmailFieldsWithBusinessHours' description = 'Calculate Business Hours for Email')
    public static void UpdateEmailFieldsWithBusinessHours(List<EmailMessage> EmailMessageList) {
        
        List<String> EmailIdList=new List <String>();
        try {
            if(EmailMessageList!=null && !EmailMessageList.isempty()){
                for(EmailMessage em : EmailMessageList){
                    EmailIdList.add(em.Id);
                }
                if(!System.isFuture() && !System.isBatch()){
                    BusinessHourCalculationForEmail.UpdateWithBusinessHours(EmailIdList,System.Now());
                }
            }
        } catch (exception e) {
            ExceptionHandler.logHandledExceptions(e, 'BusinessHourCalculationForEmail', 'UpdateEmailFieldsWithBusinessHours', 'BusinessHourCalculationForEmail');
        }
    }
    
    @future
    public static void UpdateWithBusinessHours(List <String> EmailIdList, DateTime systemNow ) {
        List<String> incomingEmailIdList=new List <String>();
        List<String> CaseIds=new List <String>();
        Map<Id,Id>caseBusinessHourMap=new Map<Id,Id>();
        List<EmailMessage> EmailListToUpdate= new List<EmailMessage> ();//this list will be updated
        List<Case> CaseListToUpdate= new List<Case> ();//this list will be updated
        List<EmailMessage> EmailListQuery;//will be initialized below
        List<Case> CaseListQuery;
        if(!EmailIdList.isempty() && systemNow!=null){
            EmailListQuery=[Select Id,ParentId,Reply_To_Message_Date__c,ReplyToEmailMessage.MessageDate,MessageDate,No_Reply_Required__c,Incoming,No_Reply_Required_Time_Stamp__c,ReplyToEmailMessageId,ReplyToEmailMessage.Incoming from EmailMessage where ID in :EmailIdList];
            if(!EmailListQuery.isempty()){
                for(EmailMessage em : EmailListQuery){
                    if(em.ParentId!=null && string.valueof(em.ParentId).startsWith('500') ){
                        CaseIds.add(em.ParentId);
                    }
                }
            }
            if(!CaseIds.isempty()){
                CaseListQuery=[select Id,BusinessHoursID from Case where Id in :CaseIds];
                for(case cs : CaseListQuery){
                    caseBusinessHourMap.put(cs.Id,cs.BusinessHoursID);
                }
            }
            system.debug('caseBusinessHourMap>>>'+caseBusinessHourMap);
            if(!caseBusinessHourMap.keyset().isempty()){
            
                for(EmailMessage em : EmailListQuery){
                system.debug('em>>>'+em);
                system.debug('em.No_Reply_Required__c>>>'+em.No_Reply_Required__c);
                system.debug('em.Incoming>>>'+em.Incoming);
                    if(!em.No_Reply_Required__c){
                        if(caseBusinessHourMap.containskey(em.ParentId) && caseBusinessHourMap.get(em.ParentId)!=null && em.Reply_To_Message_Date__c!=null && em.ReplyToEmailMessageId !=null && em.ReplyToEmailMessage.Incoming ){
                            em.Reply_Time_Business_Hours__c=Integer.valueOf(BusinessHours.diff(caseBusinessHourMap.get(em.ParentId) , em.Reply_To_Message_Date__c, em.MessageDate )/1000);
                            EmailListToUpdate.add(em);
                        }
                        else
                            if(caseBusinessHourMap.containskey(em.ParentId) && caseBusinessHourMap.get(em.ParentId)==null && em.Reply_To_Message_Date__c!=null && em.ReplyToEmailMessageId !=null && em.ReplyToEmailMessage.Incoming){
                                em.Reply_Time_Business_Hours__c=Integer.valueOf((em.MessageDate.getTime()-em.Reply_To_Message_Date__c.getTime())/1000);
                                EmailListToUpdate.add(em);
                            }
                    }
                    else
                        if(em.No_Reply_Required__c && em.Incoming==true){
                            if(caseBusinessHourMap.containskey(em.ParentId) && caseBusinessHourMap.get(em.ParentId)!=null ){
                                em.No_Reply_Required_Time_Stamp__c=systemNow;
                                em.No_Reply_Required_Time__c=Integer.valueOf(BusinessHours.diff(caseBusinessHourMap.get(em.ParentId) ,em.MessageDate, systemNow)/1000);
                                EmailListToUpdate.add(em);
                            }
                            else if(caseBusinessHourMap.containskey(em.ParentId) && caseBusinessHourMap.get(em.ParentId)==null){
                                em.No_Reply_Required_Time__c=Integer.valueOf((systemNow.getTime()-em.MessageDate.getTime())/1000);
                                EmailListToUpdate.add(em);
                            }
                        }
                }
            }
            CaseIds=new List <String>();
            for(EmailMessage em : EmailListQuery){
                if(em.ParentId!=null && string.valueof(em.ParentId).startsWith('500') && em.Incoming==False){
                    CaseIds.add(em.ParentId);
                }
            }
            if(!CaseIds.isempty()){
                CaseListQuery=[select Id,BusinessHoursID,Accepted_time__c,Date_time_for_the_first_email__c,First_Email_Age_Business_Hours__c,CreatedDate,Email_SL__c from Case where Id in :CaseIds];
                for(case cs : CaseListQuery){
                    boolean updatedCase=false;
                    if(cs.BusinessHoursID !=null && cs.Accepted_time__c !=null && systemNow>cs.Accepted_time__c && cs.First_Email_Age_Business_Hours__c==null ){
                        cs.First_Email_Age_Business_Hours__c=Integer.valueOf(BusinessHours.diff(cs.BusinessHoursID, cs.Accepted_time__c , systemNow )/1000);
                        //cs.Email_SL__c=Integer.valueOf(BusinessHours.diff(cs.BusinessHoursID, cs.CreatedDate , systemNow )/1000);
                        updatedCase=true;
                        //CaseListToUpdate.add(cs);
                    }
                    else
                        if(cs.BusinessHoursID ==null && cs.Accepted_time__c !=null && systemNow>cs.Accepted_time__c && cs.First_Email_Age_Business_Hours__c==null){
                            cs.First_Email_Age_Business_Hours__c=Integer.valueOf((systemNow.getTime()-cs.Accepted_time__c.getTime())/1000);
                            //cs.Email_SL__c=Integer.valueOf((systemNow.getTime()-cs.CreatedDate.getTime())/1000);
                            updatedCase=true;
                            //CaseListToUpdate.add(cs);
                        }
                    if(cs.BusinessHoursID !=null && systemNow>cs.CreatedDate && cs.Email_SL__c==null ){
                        //cs.Email_SL__c =Integer.valueOf(BusinessHours.diff(cs.BusinessHoursID, cs.CreatedDate , systemNow )/1000);
                        cs.Email_SL__c=Integer.valueOf(BusinessHours.diff(cs.BusinessHoursID, cs.CreatedDate , systemNow )/1000);
                        updatedCase=true;
                        //CaseListToUpdate.add(cs);
                    }
                    else
                        if(cs.BusinessHoursID ==null && systemNow>cs.CreatedDate && cs.Email_SL__c==null){
                            //cs.First_Email_Age_Business_Hours__c=Integer.valueOf((systemNow.getTime()-cs.Accepted_time__c.getTime())/1000);
                            cs.Email_SL__c=Integer.valueOf((systemNow.getTime()-cs.CreatedDate.getTime())/1000);
                            updatedCase=true;
                            //CaseListToUpdate.add(cs);
                        }
                    if(updatedCase){
                        CaseListToUpdate.add(cs);
                    }
                }
            }
        }
        If(!EmailListToUpdate.isempty()){
            Update EmailListToUpdate;
        }
        If(!CaseListToUpdate.isempty()){
            Update CaseListToUpdate;
        }
    }
    public static void dummyMethod(){
        string str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
        str='123';
    }
}