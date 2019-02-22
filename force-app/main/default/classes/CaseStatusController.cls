/*
*******************************************************************************************************
Name:         CaseStatusContoller
Description:  This Apex Class is a contoller for CaseStatusPanel component for Story #5820178 & 5820681        
*******************************************************************************************************
Date         Version    Author             Summary of Changes 
*******************************************************************************************************
12/31/2018     1.0     Brundha Rajkumar        Initial Release
*******************************************************************************************************
*/
public class CaseStatusController {
    
    /*Method To Submit The Case To Queue */  
    @AuraEnabled
    public static case SubmitToQueue(Id Cid) {
        try{

            if(Cid != null) {
                case caseRec =new case();
                Group caseQueue=new Group();
                caseRec=[SELECT status,case_Queue__C,ownerId,owner.Id,recordtypeId FROM case WHERE Id = :Cid Limit 1]; 
                if(caseRec.Id!=null){
                    if(caseRec.case_Queue__c!=''){
                        caseQueue=[select Id from Group where  Type = 'Queue' AND NAME = :caseRec.case_Queue__c Limit 1];
                    }
                    caseRec.status ='Unassigned';
                    if(caseQueue.Id!=null){
                        caseRec.OwnerId =caseQueue.Id;
                    }
                    update caseRec;                
                    return caseRec;
                }
            }
        }
        catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'CaseStatusController','SubmitToQueue','CaseManagement'); 
        }
        return null;
    }
    
    /*Method To Cancel The Case */
    @AuraEnabled
    public static case StatusUpdateCancel(Id Cid) {
        try{
            if(Cid != null) {
                case caseRec = [SELECT status,case_Queue__C FROM case WHERE Id = :Cid Limit 1];
                if(caseRec.Id!=null){
                    caseRec.status ='Cancelled';
                    caseRec.recordTypeId=SYSTEM.LABEL.InternalCaseReadOnly;
                    update caseRec;
                    return caseRec;
                }
            }
        }
        catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'CaseStatusController','StatusUpdateCancel','CaseManagement'); 
        }
        return null; 
    }
}