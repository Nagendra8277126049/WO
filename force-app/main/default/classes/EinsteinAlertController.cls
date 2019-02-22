/**
*  ---------------------------------------------------------------------------------------------------------------------------
* Name: 	 	EinsteinAlertController
* Description: This Class is responsible to create Alert related to workOrder
* ---------------------------------------------------------------------------------------------------------------------------
* Date         Version          Author             Summary of Changes 
* -----------  -------  ------------------------  ---------------------------------------------------------------------------
* 01/10/2019     1.0    	Rayana Alencar           Initial Release

***/

public class EinsteinAlertController {
    
    //method to create alert based on AD entitlement and Case classification
    public static Dispatch_Alert__c createADAlert(Id workOrderId,Boolean adEntitlement, Boolean isAccidentalDamage, String einsteinClassification ){
        Dispatch_Alert__c adAlert;
        //Taking the values from custom settings
        Einstein_Message_Alerts__c messagesAlert = Einstein_Message_Alerts__c.getOrgDefaults();
        String messageName = messagesAlert.Alert_Name__c;
        String messageactiveAD = messagesAlert.activeAD_EinsteinAD__c;
        String messageexpiredAD = messagesAlert.expiredAD_EinsteinAD__c;
        if(adEntitlement && isAccidentalDamage){
            adAlert = new Dispatch_Alert__c(Name= messageName,
                                            Alert_Details__c= messageactiveAD,
                                            Einstein_AD_Classification__c = True,
                                            Work_Order__c=workOrderId,
                                            Alert_Reason__c= 'customer has active AD and Einstein says it is AD'); 
        }else if(!adEntitlement && isAccidentalDamage){
            adAlert = new Dispatch_Alert__c(Name= messageName,
                                            Alert_Details__c= messageexpiredAD,
                                            Einstein_AD_Classification__c = True,
                                            Work_Order__c=workOrderId,
                                            Alert_Reason__c= 'customer has expired AD and Einstein says it is not AD');   
            
        }
        
        return adAlert;
    }
    
    //create/remove/update alert in work ordes related to a Case
    public static void adAlertByCase(Id caseID){

        Case caseObj          = [SELECT Id, ADClassification__c, Accidental_Damage_probability__c, Accidental_Damage__c 
                                 FROM Case
                                 WHERE id =:caseID];
        
        List<WorkOrder> workOrders = [SELECT Id, Complete_Care_Option__c FROM WorkOrder WHERE CaseId = :caseID];

        //CompleteCareOption__c is related with adEntitlement
        List<DispatchDefaults__c> dispatchDefaults = [SELECT Id, CompleteCareOption__c, Work_Order__c FROM DispatchDefaults__c
                                                      WHERE Work_Order__r.CaseID = :caseID ORDER BY CreatedDate DESC];

        List<Dispatch_Alert__c> alerts = [SELECT Id,Name,Work_Order__c, Work_Order__r.CaseID, Alert_Details__c, Alert_Reason__c, Alerts_Id__c
                                          FROM Dispatch_Alert__c 
                                          WHERE Work_Order__r.CaseID = :caseID and Einstein_AD_Classification__c = True];
        
        Map<ID,List<Dispatch_Alert__c>> workOrderAlerts = new Map<ID,List<Dispatch_Alert__c>>();
        Map<ID,Boolean> workOrderDispatch = new Map<ID,Boolean>();
        
        for(Dispatch_Alert__c alert: alerts) {
            List<Dispatch_Alert__c> adAlerts = null;
            if(workOrderAlerts.containsKey(alert.Work_Order__c)) {
                adAlerts = workOrderAlerts.get(alert.Work_Order__c);
                adAlerts.add(alert);
                workOrderAlerts.put(alert.Work_Order__c,adAlerts);
            } else {
                adAlerts = new List<Dispatch_Alert__c>();
                adAlerts.add(alert);
                workOrderAlerts.put(alert.Work_Order__c,adAlerts);
            }
        }
        
        for(DispatchDefaults__c dispatch: dispatchDefaults) {
            if(!workOrderDispatch.containsKey(dispatch.Work_Order__c)) {
                Boolean adEntitlement = dispatch.CompleteCareOption__c;
                workOrderDispatch.put(dispatch.Work_Order__c,adEntitlement);
            }
        }
        
        String einteinClassification = caseObj.ADClassification__c;
        Double classificationProb = caseObj.Accidental_Damage_probability__c;
        Boolean isAccidentalDamage = caseObj.Accidental_Damage__c;
        List<Dispatch_Alert__c> createAlerts = new List<Dispatch_Alert__c>();
        List<Dispatch_Alert__c> deleteAlerts = new List<Dispatch_Alert__c>();
        
        //for each work order of a case
        for(WorkOrder workOrderObj: workOrders){
            Boolean adEntitlement = False;
            Boolean alertAlreadyExists = False;
            
            //there is CompleteCareOption__c related with this workOrder
            if(workOrderDispatch.containsKey(workOrderObj.Id)) {
                adEntitlement = workOrderDispatch.get(workOrderObj.Id);
            }
            List<Dispatch_Alert__c> workAlerts = new List<Dispatch_Alert__c>();
            
            if(workOrderAlerts.containsKey(workOrderObj.Id)) {   
                workAlerts = workOrderAlerts.get(workOrderObj.Id);
            } 
            
            // alert based on Einstein classification and AD entitlement
            Dispatch_Alert__c adAlert = createADAlert(workOrderObj.Id,adEntitlement,isAccidentalDamage,einteinClassification); 
            
            //if there is no CompleteCareOption__c related with this workOrder all AD alert should be deleted		
            if(!workOrderDispatch.containsKey(workOrderObj.Id)) {
                adAlert = null;
            }
            
            // delete currently alert on this work order if any and create one if its alert message does not exists
            if(adAlert != null){
                for(Dispatch_Alert__c alert: workAlerts){
                    if(!((alert.Alert_Details__c.equals(adAlert.Alert_Details__c)) && 
                         (alert.Name.equals(adAlert.Name)) && (alert.Alert_Reason__c.equals(adAlert.Alert_Reason__c)))){
                             // remove previous AD alert related to this work order
                             deleteAlerts.add(alert);
                         }else{
                             alertAlreadyExists = True;
                         }
                }
            }else{
                deleteAlerts.addAll(workAlerts);
            }
            
            if(adAlert != null && !alertAlreadyExists){
                createAlerts.add(adAlert);
            }
            
        } 
        
        //Add AD alerts 
        insert createAlerts;
        //Remove AD alerts
        delete deleteAlerts;
        
    }
    
    //create/update/delete AD Alert related to workOrder
    public static void adAlertByWorkOrder(List<WorkOrder> orders) {
        // get relation between case and work orders
        Set<ID> workOrdersID = new Set<ID>();      
        Map<ID,List<WorkOrder>> caseWorkOrders     = new Map<ID,List<WorkOrder>>();
        
        for(WorkOrder order: orders) {            
            List<WorkOrder> workOrders = null;
            if(caseWorkOrders.containsKey(order.CaseId)) {
                workOrders = caseWorkOrders.get(order.CaseId);
                workOrders.add(order);
            } else {
                workOrders = new List<WorkOrder>();
                workOrders.add(order);
                caseWorkOrders.put(order.CaseId,workOrders);
            }
            workOrdersID.add(order.Id);
        }
        
        //get relation between work ordes and alerts
        Map<ID,List<Dispatch_Alert__c>> workOrderAlerts = new Map<ID,List<Dispatch_Alert__c>>();
        List<Dispatch_Alert__c> alerts = [SELECT Id,Name,Work_Order__c, Work_Order__r.CaseID, Alert_Details__c, Alert_Reason__c, Alerts_Id__c
                                          FROM Dispatch_Alert__c 
                                          WHERE Work_Order__c in :workOrdersID and Einstein_AD_Classification__c = True];
        
        //CompleteCareOption__c is related with adEntitlement
        Map<ID,Boolean> workOrderDispatch = new Map<ID,Boolean>();
        List<DispatchDefaults__c> dispatchDefaults = [SELECT Id, CompleteCareOption__c, Work_Order__c FROM DispatchDefaults__c
                                                      WHERE Work_Order__c in :workOrdersID ORDER BY CreatedDate DESC];
        
        
        for(Dispatch_Alert__c alert: alerts) {
            List<Dispatch_Alert__c> adAlerts = null;
            if(workOrderAlerts.containsKey(alert.Work_Order__c)) {
                adAlerts = workOrderAlerts.get(alert.Work_Order__c);
                adAlerts.add(alert);
            } else {
                adAlerts = new List<Dispatch_Alert__c>();
                adAlerts.add(alert);
                workOrderAlerts.put(alert.Work_Order__c,adAlerts);
            }
        }
        
        for(DispatchDefaults__c dispatch: dispatchDefaults) {
            if(!workOrderDispatch.containsKey(dispatch.Work_Order__c)) {
                Boolean adEntitlement = dispatch.CompleteCareOption__c;
                workOrderDispatch.put(dispatch.Work_Order__c,adEntitlement);
            }
        }
        
        //get Einstein Intent information from each case        
        List<Case> cases = [SELECT Id, ADClassification__c, Accidental_Damage_probability__c, Accidental_Damage__c 
                            FROM Case
                            WHERE ID In :caseWorkOrders.keySet()]; 
        
        List<Dispatch_Alert__c> createAlerts = new List<Dispatch_Alert__c>();
        List<Dispatch_Alert__c> deleteAlerts = new List<Dispatch_Alert__c>();
        
        for(Case caseObj: cases){
            List<WorkOrder> workOrders = caseWorkOrders.get(caseObj.id);
            String einteinClassification = caseObj.ADClassification__c;
            Double classificationProb = caseObj.Accidental_Damage_probability__c;
            Boolean isAccidentalDamage = caseObj.Accidental_Damage__c;
            
            //for each work order of a case
            for(WorkOrder workOrderObj: workOrders){
                Boolean alertAlreadyExists = False;
                Boolean adEntitlement = False;
                
                //there is CompleteCareOption__c related with this workOrder
                if(workOrderDispatch.containsKey(workOrderObj.Id)) {
                    adEntitlement = workOrderDispatch.get(workOrderObj.Id);
                }
                
                List<Dispatch_Alert__c> workAlerts = new List<Dispatch_Alert__c>();
                
                if(workOrderAlerts.containsKey(workOrderObj.Id)) {   
                    workAlerts = workOrderAlerts.get(workOrderObj.Id);
                } 
                
                // alert based on Einstein classification and AD entitlement
                Dispatch_Alert__c adAlert = createADAlert(workOrderObj.Id,adEntitlement,isAccidentalDamage,einteinClassification); 
                
                //if there is no CompleteCareOption__c related with this workOrder all AD alert should be deleted		
                if(!workOrderDispatch.containsKey(workOrderObj.Id)) {
                    adAlert = null;
                }
                // delete currently alert on this work order if any and create one if its alert message does not exists
                if(adAlert != null){
                    for(Dispatch_Alert__c alert: workAlerts){
                        if(!((alert.Alert_Details__c.equals(adAlert.Alert_Details__c)) && 
                             (alert.Name.equals(adAlert.Name)) && (alert.Alert_Reason__c.equals(adAlert.Alert_Reason__c)))){
                                 // remove previous AD alert related to this work order
                                 deleteAlerts.add(alert);
                             }else{
                                 alertAlreadyExists = True;
                             }
                    }
                }else{
                    deleteAlerts.addAll(workAlerts);
                }
                
                if(adAlert != null && !alertAlreadyExists){
                    createAlerts.add(adAlert);
                }
                
            } 
            
            //Add AD alerts 
            insert createAlerts;
            //Remove AD alerts
            delete deleteAlerts;
            
        }
    }
    
    //create/update/delete AD Alert related to DispatchDefaults
    public static void adAlertByDispatch(List<DispatchDefaults__c> dispatches){
        Set<Id> ordersIds = new Set<Id>();
        
        for(DispatchDefaults__c dispatch : dispatches){
            ordersIds.add(dispatch.Work_Order__c);
        }
        
        List<WorkOrder> orders = [Select  CaseId from WorkOrder where id in : ordersIds];
        
        adAlertByWorkOrder(orders);
    }
}