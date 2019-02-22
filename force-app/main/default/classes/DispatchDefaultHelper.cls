/*======================================================================================================================+
|  HISTORY                                                                  
|                                                                           
|  DATE            DEVELOPER         WR/DEFECT        DESCRIPTION                               
|  ====            =========         =========        =========== 
| 25/07/2018       Megha Bhardwaj    4965602          Helper class for DispatchDefaultsTrigger trigger, Insert Dispatch Alert and Customer Reminder based on AD entitlement as per history of an Asset on before insert of Dispatch Default records
| 05/04/2018                         4905886          
+======================================================================================================================*/
/*======================================================================================================================+
|  Test Class Covering this class                                                                  
|      DispatchDefaultHelper_Test                                                                         
+======================================================================================================================*/
public class DispatchDefaultHelper{

    
     /* -----------------------------------------------------------------------------------------------------------------------
    Name:       ADdispatchValidation
    Description:  this method is called on before insert event of the DispatchDefaults__c trigger named DispatchDefaultsTrigger to insert dispatch alert and customer reminder
    Input: recordId - list of DispatchDefaults__c records
    recordId - list of DispatchDefaults__c records          
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    24/07/2018     1.0     Megha Bhardwaj     Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */    
    public static void ADdispatchValidation(List<DispatchDefaults__c> newList){
    
        try{

            List<String> woIdList = new List<String>();
            List<Asset> assetList = new List<Asset>();
            Set<String> assetIdSet = new Set<String>();
            Boolean AlertFlag=false;
            Boolean ServiceCompFlag=false;
            Boolean CustomerRemFlag=false;
            List<Dispatch_Alert__c> DALst = new List<Dispatch_Alert__c>();
            List<Customer_Reminder__c> CRLst = new List<Customer_Reminder__c>();
            Map<String,String> ddIdWOIdMap = new Map<String,String>();
            Map<String,workOrder> woIdWOMap = new Map<String,workOrder>();
            
            
            for(DispatchDefaults__c dispatchDefault : newList){
                woIdList.add(dispatchDefault.work_order__c);
                ddIdWOIdMap.put(dispatchDefault.Id,dispatchDefault.work_order__c);
            } 
            
            if(woIdList.size() > 0){
                
                List<WorkOrder> WOLst = [select Id, AssetId, Status from WorkOrder WHERE Id IN : woIdList LIMIT 50000];
                
                if(null != WOLst && WOLst.size()>0){
                
                    for(workorder wo : WOLst){
                        assetIdSet.add(wo.AssetId); 
                        woIdWOMap.put(wo.Id,wo);
                        
                    }
                    map<String,List<WorkOrder>> assetIdWOMap = new map<String,List<WorkOrder>>();
                    List<WorkOrder> workOrderList = new List<WorkOrder>();
                    
                    if(assetIdSet.size() > 0){
                        
                        assetList = [select Id,(select Id,Status,Complete_Care_Option__c, AssetId FROM WorkOrders WHERE  Work_Order_Age__c < 365 and status != 'Cancelled') 
                                FROM Asset WHERE ID IN: assetIdSet LIMIT 50000];
                   
                       List<WorkOrder> woListTemp;
                        for(Asset asset : assetList){
                        
                            for(workorder wo : asset.WorkOrders){
                            
                                if(wo.Complete_Care_Option__c){
                                    woListTemp= new List<WorkOrder>();
                                    
                                    if(!assetIdWOMap.containsKey(wo.AssetId)){
                                        
                                        woListTemp.add(wo);
                                        assetIdWOMap.put(wo.AssetId,woListTemp);
                                    }
                                    else{
                                    
                                        woListTemp = assetIdWOMap.get(wo.AssetId);
                                        woListTemp.add(wo);
                                        assetIdWOMap.put(wo.AssetId,woListTemp);
                                    }
                                    
                                }
                            }
                        }
                        if(assetIdWOMap != null && !assetIdWOMap.isEmpty()){
    
                            for(List<WorkOrder> woList : assetIdWOMap.values()){
    
                                workOrderList.addAll(woList);
                            }
                        }
                     }
               
                    if(newList.size() > 0 && !workOrderList.isEmpty() && !assetIdWOMap.isEmpty()){
                         
                            for(DispatchDefaults__c dispatchDefault : newList){
    
                                
                                for(workOrder workOrder : workOrderList){
                                    
                                    String woIdInContext = ddIdWOIdMap.get(dispatchDefault.Id);
                                    workOrder workOrderInContext = woIdWOMap.get(woIdInContext);
                                    if(assetIdWOMap.containsKey(workOrderInContext.AssetId)){
                                        dispatchDefault.AD_Coverage_Flag__c = true;
                                    }
                                    if(workOrder.status != 'Cancelled' && !AlertFlag){
                                        
                                        Dispatch_Alert__c DAlert = new Dispatch_Alert__c(Name='Already AD has been provided for Asset',Work_Order__c=workOrderInContext.Id);
                                        DALst.add(DAlert);
                                        AlertFlag = true;
                                    }
                                    if((workOrder.status != 'Cancelled' || workOrder.status != 'Service Complete') && !CustomerRemFlag){
                                        Customer_Reminder__c cr = new Customer_Reminder__c(name='Accidental Damage Coverage',Reminder__c='An Accidental Damage dispatch is already in progress. To continue, select an Override Reason. This dispatch will be put on hold for review.',Work_Order__c=workOrderInContext.Id,Type__c='Accidental Damage');
                                        CRLst.add(cr);
                                        CustomerRemFlag = true;
                                    }
                                    if(workOrder.status == 'Service Complete' && !ServiceCompFlag){
                                        Customer_Reminder__c cr = new Customer_Reminder__c(name='Accidental Damage Coverage',Reminder__c='The Accidental Damage limit has been reached for this contractual year. To continue, select an Override Reason. This dispatch will be put on hold for review.',Work_Order__c = workOrderInContext.Id,Type__c='Accidental Damage');
                                        CRLst.add(cr);
                                        ServiceCompFlag = true;
                                    }
                                }
                            }
                            if(DALst.size()>0){
                                insert DALst;
                            }
                            if(CRLst.size()>0){
                                insert CRLst;
                            }
                         
                       }
                       
                  }
              }
         }
        catch (exception ex) {
            ExceptionHandler.logHandledExceptions(ex, 'DispatchDefaultsConfiguration', 'performCallToDelta', 'Dispatch Management');
        }
    }
      /*
    This Method Will Update the WorkOrder with Entitlement Details and Insert Customer Reminder If Required
    */
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       addEntitlementDetails
    Description:  this method is used to add entitlements details and insertingg customer reminders and updating the respective work order
    Input: ServiceCloudEntitlmentDetails- list of ServiceCloudEntitlmentDetails__x records
    WorkOrderId - work order record Id          
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    24/04/2018     1.0     Datta1            Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */    
   
    public static void addEntitlementDetails(List<ServiceCloudEntitlmentDetails__x> ServiceCloudEntitlmentDetails,Id WorkOrderId){
        try{
            String entitlementDetails = '';
            Boolean adCoverage=false;
            Boolean dataRecovery=false;
            Boolean dataDestruction=false;
            Boolean keepYourHardDrive=false;
            Boolean keepYourComponent=false;
            Boolean ischangedWOrkOrder=false;
            List<Customer_Reminder__c> ExistingCustomerReminder;
            set<String>ExistingCustomerReminderSet= new set<String>();
            List<Customer_Reminder__c> newCustomerReminder= new List<Customer_Reminder__c>();
            entitlementDetails=[Select Id,Entitlement_Details__c from WorkOrder where id=:WorkOrderId limit 1].Entitlement_Details__c;
            if(entitlementDetails!=null){
                return;
            }
            else{
                for(ServiceCloudEntitlmentDetails__x sce : ServiceCloudEntitlmentDetails){
                    if(sce.name__C!=null && sce.name__C!='' && sce.name__C.containsIgnoreCase('Accidental Damage') && sce.ExpiryDate__c>system.today()){
                        if(entitlementDetails!=null && entitlementDetails!='' && !entitlementDetails.containsIgnoreCase('Accidental Damage') ){
                            entitlementDetails=entitlementDetails+'|Accidental Damage|';
                            ischangedWOrkOrder=true;
                        }
                        if(entitlementDetails==null){
                            entitlementDetails='|Accidental Damage|';
                            ischangedWOrkOrder=true;
                        }
                        adCoverage=true;
                    }else
                        if(sce.name__C!=null && sce.name__C!='' && sce.name__C.containsIgnoreCase('Keep Your Hard Drive') && sce.ExpiryDate__c>system.today()){
                            if(entitlementDetails!=null && entitlementDetails!='' && !entitlementDetails.containsIgnoreCase('Keep Your Hard Drive') ){                        
                                entitlementDetails=entitlementDetails+'|Keep Your Hard Drive|';
                                ischangedWOrkOrder=true;
                            }
                            if(entitlementDetails==null){
                                entitlementDetails='|Keep Your Hard Drive|';
                                ischangedWOrkOrder=true;
                            }
                            keepYourHardDrive=true;
                        }else
                            if(sce.name__C!=null && sce.name__C!='' && sce.name__C.containsIgnoreCase('Data Recovery') && sce.ExpiryDate__c>system.today()){
                                if(entitlementDetails!=null && entitlementDetails!='' && !entitlementDetails.containsIgnoreCase('Data Recovery') ){                                                    
                                    entitlementDetails=entitlementDetails+'|Data Recovery|';
                                    ischangedWOrkOrder=true;
                                }
                                if(entitlementDetails==null){
                                    entitlementDetails='|Data Recovery|';
                                    ischangedWOrkOrder=true;
                                }
                                dataRecovery=true;
                            }else
                                if(sce.name__C!=null && sce.name__C!='' && sce.name__C.containsIgnoreCase('Data Destruction') && sce.ExpiryDate__c>system.today()){
                                    if(entitlementDetails!=null && entitlementDetails!='' && !entitlementDetails.containsIgnoreCase('Data Destruction') ){                                                                                       
                                        entitlementDetails=entitlementDetails+'|Data Destruction|';
                                        ischangedWOrkOrder=true;
                                    }
                                    if(entitlementDetails==null){
                                        entitlementDetails='|Data Destruction|';
                                        ischangedWOrkOrder=true;
                                    }
                                    dataDestruction=true;
                                }else
                                    if(sce.name__C!=null && sce.name__C!='' && sce.name__C.containsIgnoreCase('Keep Your Component') && sce.ExpiryDate__c>system.today()){
                                        if(entitlementDetails!=null && entitlementDetails!='' && !entitlementDetails.containsIgnoreCase('Keep Your Component') ){                                                                                       
                                            entitlementDetails=entitlementDetails+'|Keep Your Component|';
                                            ischangedWOrkOrder=true;
                                        }
                                        if(entitlementDetails==null){
                                            entitlementDetails='|Keep Your Component|';
                                            ischangedWOrkOrder=true;
                                        }
                                        keepYourComponent=true;
                                    }
                }
            }
            ExistingCustomerReminder=[Select Id, name from Customer_Reminder__c where Work_Order__c=:WorkOrderId LIMIT 50000];
            if(!ExistingCustomerReminder.isempty()){
                for(Customer_Reminder__c cr : ExistingCustomerReminder){
                    ExistingCustomerReminderSet.add(cr.name);
                }
            }
            /*if(dataDestruction && !ExistingCustomerReminderSet.contains('Data Destruction')){
                Customer_Reminder__c dataDestructionReminder=new Customer_Reminder__c();
                dataDestructionReminder.Link__c='https://kb.dell.com/infocenter/index?page=content&id=PNP12908&actp=SEARCH&viewlocale=en_US&searchid=1523859634795#Table%20of%20Contents';
                dataDestructionReminder.Name='Data Destruction';
                dataDestructionReminder.Reminder__c='The hard drive I’m sending you is eligible for data destruction as part of your ProSupport service.';
                dataDestructionReminder.Work_Order__c=WorkOrderId;
                newCustomerReminder.add(dataDestructionReminder);
            }*/
            if(dataRecovery && !ExistingCustomerReminderSet.contains('Data Recovery')){
                Customer_Reminder__c dataRecoveryReminder=new Customer_Reminder__c();
                dataRecoveryReminder.Link__c='https://kb.dell.com/infocenter/index?page=content&id=PNP12603&actp=SEARCH&viewlocale=en_US&searchid=1523860373647';
                dataRecoveryReminder.Name='Data Recovery';
                dataRecoveryReminder.Reminder__c='The hard drive I’m sending you is eligible for data recovery as part of your Pro-Support service.';
                dataRecoveryReminder.Work_Order__c=WorkOrderId;
                newCustomerReminder.add(dataRecoveryReminder);
            }
            if(!newCustomerReminder.isempty()){
                insert newCustomerReminder;
            }
            if(ischangedWOrkOrder){
                if(entitlementDetails!=null && entitlementDetails.length()>254){
                    entitlementDetails=entitlementDetails.substring(0,254);
                }
                WorkOrder workOrderToUpdate=new WorkOrder(Id=WorkOrderId,Entitlement_Details__c=entitlementDetails);
                update workOrderToUpdate;
            }
        }
        
        Catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'EntitlementDashboardController','getEntDetails','EntitlementManagement');
            return;
        }
    }
    /* This method is to delete the customer reminders when KYC/KYHD/AD Entitlement is unchecked*/
     /* -----------------------------------------------------------------------------------------------------------------------
    Name:       deleteCustomerReminders
    Description:  this method is written for "If the work order has KYHD or AD checked and the agent deselects any of these entitlements, then the corresponding Alert/Reminder from the Alert or Customer reminder section should be removed and should not be displayed"
    Input: ddId - list of DispatchDefaults__c record Ids
    ddId - list of DispatchDefaults__c record Ids         
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    17/07/2018     1.0     Prakhar Sinha     Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */    
   
    @InvocableMethod(label='Delete Customer Reminder' description='Delete the customer Reminders')
    public static void deleteCustomerReminders (List<Id> ddId)
    {
        try{
        
          List<Customer_Reminder__c> crlistforKYC  = new List<Customer_Reminder__c>();
          List<Customer_Reminder__c> crlistforKYHD = new List<Customer_Reminder__c>();
      
          Set<Id> delcrlistIDs = new Set<Id>();
      
            Set<Id> workOrderIds= new Set<Id>();
            Set<Id> KYCbooleanIds = new Set<Id>();
            Set<Id> KYHDbooleanIDs = new Set<Id>();
            Set<Id> ADbooleanIds = new Set<Id>();
            List<Customer_Reminder__c> crlistdel = new List<Customer_Reminder__c>();
            List<DispatchInstruction__c> instrdel= new List<DispatchInstruction__c>();
            List<WorkOrderLineItem> partsList = new List<WorkorderLineItem>();
            List<WorkOrderLineItem> partsListtoDelete = new List<WorkorderLineItem>();
            List<DispatchInstruction__c> instrCompleteCareOption =  new List<DispatchInstruction__c>();
            List<DispatchDefaults__c> ddlist= new List<DispatchDefaults__c>();
            ddlist=[Select Id,Work_order__c,KYHDOption__c,Keep_Your_Components__c,Complete_Care_Option__c from DispatchDefaults__c where Id in : ddId limit 50000];
            
            for(DispatchDefaults__c dd : ddlist)
            {
                    workOrderIds.add(dd.Work_Order__c);
                    if(!dd.KYHDOption__c)
                    {
                     KYHDbooleanIDs.add(dd.Work_Order__c);
                    }
                    
                    if(!dd.Keep_Your_Components__c)
                    {
                     KYCbooleanIds.add(dd.Work_Order__c);
                    }
                    
                    if(!dd.Complete_Care_Option__c)
                    {
                     ADbooleanIds.add(dd.Work_Order__c);
                    }
                    
            }
            if(KYHDbooleanIDs.size()>0)
            {
               crlistforKYHD=[Select Id from Customer_Reminder__c where Work_Order__c in : KYHDbooleanIDs and Type__c='KYHD' limit 50000];
               if(!crlistforKYHD.isEmpty())
               {
               crlistdel.addall(crlistforKYHD);
               }
               partsList =[Select Id from WorkOrderLineItem where WorkOrderId in :KYHDbooleanIDs and Line_Item_Type__c Like '%Info Parts-Hard Drive%' limit 50000];
               if(!partsList.isEmpty())
               {
               partsListtoDelete.addall(partsList);
               }
             }  
             if(KYCbooleanIds.size()>0)
              {
                   crlistforKYC=[Select Id from Customer_Reminder__c where Work_Order__c in : KYCbooleanIds and Type__c='KYC' limit 50000];
                   if(!crlistforKYC.isEmpty())
                   {
                    crlistdel.addall(crlistforKYC);
                   }
              }
          
              if(ADbooleanIds.size()>0)
              {
               crlistforKYC=[Select Id from Customer_Reminder__c where Work_Order__c in : ADbooleanIds and Type__c='Accidental Damage' limit 50000];
               instrCompleteCareOption=[Select Id from DispatchInstruction__c where Work_Order__c in : ADbooleanIds and Is_Type_CompleteCareOption__c=true limit 50000];
                   if(!crlistforKYC.isEmpty())
                   {
                    crlistdel.addall(crlistforKYC);
                   }
                   if(!instrCompleteCareOption.isEmpty())
                   {
                   instrdel.addall(instrCompleteCareOption);
                   }
              }
               
              if(!crlistdel.isEmpty())
              {
                 delete crlistdel;
              }
          
              if(!instrdel.isEmpty())
              {
                delete instrdel;
              }
          
              if(!partsListtoDelete.isEmpty())
              {
                  delete partsListtoDelete;
              }
      }catch(exception e){
          ExceptionHandler.logHandledExceptions(e,'DispatchDefaultHelper','deleteCustomerReminders','EntitlementManagement');
          return;
      }
      
    }
    
     /* -----------------------------------------------------------------------------------------------------------------------
    Name:       InsertCustomerReminders
    Description:  this method is written for "If the work order has KYHD or AD checked and the agent deselects any of these entitlements, then the corresponding Alert/Reminder from the Alert or Customer reminder section should be removed and should not be displayed"
    Input: WoId - set of workorder record Ids
    WoId - set of workorder record Ids         
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    17/07/2018     1.0     Prakhar Sinha     Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */    
   
    public static void InsertCustomerReminders(Set<Id> WoId)
    {
    
    try{
        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId() limit 1].Profile.Name;
        if(usrProfileName!='Service Integration Profile')
        {
        List<DispatchDefaults__c> ddlist = new List<DispatchDefaults__c>([SELECT AD_Coverage_Flag__c,CompleteCareOption__c,Work_Order__c,Complete_Care_Option__c FROM DispatchDefaults__c where Work_Order__c in :WoId limit 50000]);
        List<Customer_Reminder__c> crListToInsert = new List<Customer_Reminder__c>();
        
        
        Map<Id,Customer_Reminder__c> mapofWoandCr= new Map<Id,Customer_Reminder__c>();
        List<Customer_Reminder__c> crList = new List<Customer_Reminder__c>([SELECT Id,Reminder__c,Type__c,Work_Order__c FROM Customer_Reminder__c where Work_Order__c in :WoId and Type__c='Accidental Damage' limit 50000]);
        for(Customer_Reminder__c cr : crList )
        {
            mapofWoandCr.put(cr.Work_Order__c,cr);
        }
        
        for(DispatchDefaults__c dd : ddlist)
        {
             if(dd.AD_Coverage_Flag__c && dd.Complete_Care_Option__c && dd.CompleteCareOption__c && ((!mapofWoandCr.keyset().isempty() && !mapofWoandCr.containskey(dd.Work_Order__c )) || mapofWoandCr.keyset().isempty()) )
             {
             Customer_Reminder__c cr = new Customer_Reminder__c(name='Accidental Damage Coverage',Reminder__c='An Accidental Damage dispatch is already in progress. To continue, select an Override Reason. This dispatch will be put on hold for review.',Type__c='Accidental Damage',Work_Order__c=dd.Work_Order__c);
             crListToInsert.add(cr);
             }
         }
                if(!crListToInsert.isEmpty())
                {
                  insert crListToInsert;
                }
        
        }
     }catch(exception e){
          ExceptionHandler.logHandledExceptions(e,'DispatchDefaultHelper','InsertCustomerReminders','InsertCustomerReminders');
          return;
      }
        
    }
    public static void populateCFINumCheckOnWO(Set<Id> WoIds){
        
        List<workOrder> workOrderList = [select id, CFINumber__c, CFINumCheck__c, Out_of_Warranty__c, Service_Option__c, AssetId  from workOrder where Id IN: WoIds];
        List<workOrder> workOrderToBeUpdated = new List<workOrder>();
        Map<String,WorkOrder_CFI__c> specialOptionsCFIMap  = new Map<String,WorkOrder_CFI__c>([select Name from WorkOrder_CFI__c LIMIT 49000]);
       
        Set<String> CFISpecialOptions = new Set<String>();
        
        if(specialOptionsCFIMap != null && specialOptionsCFIMap.values().size() > 0){
        for(WorkOrder_CFI__c spOptionCFI : specialOptionsCFIMap.Values())
            CFISpecialOptions.add(spOptionCFI.Name.Trim());
        }
        for(workOrder wo : workOrderList){
        
            if(String.isNotBlank(wo.CFINumber__c) && !wo.Out_of_Warranty__c && CFISpecialOptions.contains(wo.Service_Option__c)){
                
                wo.CFINumCheck__c = true;
                workOrderToBeUpdated.add(wo);
            }
        }
         if(workOrderToBeUpdated.size () > 0){
         
             List<Id> workOrderIdsToBeUpdated = new List<Id>();
            update workOrderToBeUpdated;
            for(workorder wo : workOrderToBeUpdated)
                workOrderIdsToBeUpdated.add(wo.Id);
            callAssetComponents(workOrderIdsToBeUpdated);
        }
    }
    @future (callout=true)
    public static void callAssetComponents(List<Id> workOrderIdsToBeUpdated){
    
       List<AssetComponentResponse__x> assetComponentsList = new List<AssetComponentResponse__x>();
       List<workOrder> workorderList = new List<workOrder>();
       
       try{
           if(null != workOrderIdsToBeUpdated && workOrderIdsToBeUpdated.size() > 0){
           
               workorderList = [select Id, ServiceTag__c, CFI_Exists__c from workOrder where Id 
               In: workOrderIdsToBeUpdated AND CFINumCheck__c = True ]; 
               
               Map<String,workOrder> serviceTagWorkOrderMap = new Map<String,workOrder>();
               Map<String,AssetComponentResponse__x> serviceTagAssetCompMap = new Map<String,AssetComponentResponse__x>();
               for(workOrder wo : workorderList){
                
                    if(String.isNotBlank(wo.ServiceTag__c)){
                    
                        serviceTagWorkOrderMap.put(wo.ServiceTag__c,wo);
                        if (!Test.isRunningTest()) {
                        
                            assetComponentsList = [SELECT serviceTag__c, CFI_Exists__c, ResponseMessage__c, ResponseCode__c FROM AssetComponentResponse__x
                                WHERE serviceTag__c =: wo.ServiceTag__c LIMIT 1
                            ];
                           
                        } else {
                            assetComponentsList.add(new AssetComponentResponse__x(ResponseCode__c = '100'));
                       }    
                   }  
               }
               
               List<WorkOrder> workOrderToBeUpdated = new List<WorkOrder>();
               if(assetComponentsList.size() >0){
                   for(AssetComponentResponse__x assetComp : assetComponentsList){
                   
                       if(!serviceTagWorkOrderMap.isEmpty() && serviceTagWorkOrderMap.containsKey(assetComp.serviceTag__c)){
                            workOrder wo = serviceTagWorkOrderMap.get(assetComp.serviceTag__c);
                            
                            if(null != assetComp.CFI_Exists__c && assetComp.CFI_Exists__c.containsIgnoreCase('Y')){
                                wo.CFI_Exists__c = true;
                                wo.CFIImage__c = true;
                            }
                            workOrderToBeUpdated.add(wo);
                       }
                   }
               }
               if(workOrderToBeUpdated.size() > 0)
                   update workOrderToBeUpdated;
           }
       }
       catch(Exception ex){
            ExceptionHandler.logHandledExceptions(ex, 'DispatchDefaultHelper', 'AssetComponentResponse', 'Dispatch Management');
            //return null;
       }
   }
}