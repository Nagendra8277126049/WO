/* -----------------------------------------------------------------------------------------------------------------------
Name:       ReletadDispatchController
Description:  This class contains the operation to read Dispatch information from external object - story# 4150193
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
12/04/2017     1.0     Rodrigo Carpio      Initial Release
12/27/2017     1.1     Rodrigo Carpio      Added the code to retrieve dispatch by user
-------------------------------------------------------------------------------------------------------------------------- */
public with sharing class ReletadDispatchController {
    
    public with sharing class RelatedPagerWrapper{
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Boolean next {get;set;}
        @AuraEnabled public Boolean previous {get;set;}
        @AuraEnabled public List<ReletadDispatchWrapper> rltdDispatch {get;set;}
    }
    
    public with sharing class ReletadDispatchWrapper{
        @AuraEnabled public string dispatchNumber {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String option {get;set;}
        @AuraEnabled public String eTA {get;set;}
        @AuraEnabled public String trackingNumber {get;set;}  
        @AuraEnabled public String trackingNumberReturn {get;set;} 
        @AuraEnabled public String dateCreated {get;set;} 
        @AuraEnabled public String laborStatus {get;set;} 
        @AuraEnabled public String partsStatus {get;set;} 
        @AuraEnabled public String caseNumber {get;set;} 
    }
    
    @AuraEnabled
    public static RelatedPagerWrapper getUserSRDispatches (Decimal PageKey, String PageSize)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getUserSRDispatches
    Description:  This method reads User SR-Dispatches dashboard information from external object - story# 4419724
    ---------------------------------------------------------------------------------------------------------------------------
    Date         Version      Author             Summary of Changes 
    -----------  -------  -----------------  ----------------------------------------------------------------------------------
    12/27/2017     1.0     Rodrigo Carpio        Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    { 
        try
        {
            string lastPage='';
            string responseCode = '';
            Integer page = (Integer) PageKey;
            String sInteger = String.valueOf(page);

            string userName = userinfo.getUserName();
            integer indexStr = userName.indexOf('@');
            
            userName = userName.substring(0, indexStr);
            
            List<ReletadDispatchWrapper> dispatches = new List<ReletadDispatchWrapper>();
            
            // check for object to get the dispatch information              
            List<DispatchDashboardListByOwner__x> dispListbySR = new List<DispatchDashboardListByOwner__x>();
            	
            RelatedPagerWrapper objDispatch =  new RelatedPagerWrapper();
           
            if(!Test.isRunningTest() ){
         
                dispListbySR = [select ExternalId, DPSNumber__c, Status__c, SFDCCaseNumber__c, LastPage__c, PageKey__c,PageSize__c FROM DispatchDashboardListByOwner__x 
                                WHERE Owner__c =:userName.toUpperCase() AND PageKey__c=:sInteger AND PageSize__c=:PageSize LIMIT 200 ];
                
            }
            else{
            	dispListbySR.add(new DispatchDashboardListByOwner__x(ExternalId = 'ssss', DPSNumber__c = '1234567', LastPage__c = 'false',
                                                                     	 PageKey__c='1', PageSize__c='10', Option__c = 'Sample Option', 
                                                                         Status__c = 'Sample Status'));
                dispListbySR.add(new DispatchDashboardListByOwner__x(ExternalId = 'sses', DPSNumber__c = '123452307', LastPage__c = 'false',
                                                                         Option__c = 'Sample Option', Status__c = 'Sample Status',
                                                                         PageKey__c='1', PageSize__c='10'));
                dispListbySR.add(new DispatchDashboardListByOwner__x(ExternalId = 'test', DPSNumber__c = '12345290807', LastPage__c = 'false', 
                                                                         Option__c = 'Sample Option', Status__c = 'Sample Status',
																		 PageKey__c='1', PageSize__c='10'));
                dispListbySR.add(new DispatchDashboardListByOwner__x(ExternalId = 'Testing', DPSNumber__c = '456789', LastPage__c = 'false',
                                                                         Option__c = 'Sample Option', Status__c = 'Sample Status',
                                                                         PageKey__c='1', PageSize__c='10'));
            }      
                
            if (dispListbySR.size()>0 ) {
                             
            	lastPage = dispListbySR[0].LastPage__c;
                objDispatch.page = page;
                        
                if (lastPage!=null && page!=null){
                	if (lastPage.equalsIgnoreCase('false') && page == 1){
                      	objDispatch.next = true;
                        objDispatch.previous = false;
                    }
                    else if (lastPage.equalsIgnoreCase('true') && page > 1){
                      	objDispatch.next = false;
                        objDispatch.previous = true;
                    }
                    else if (lastPage.equalsIgnoreCase('false') && page > 1){
                      	objDispatch.next = true;
                        objDispatch.previous = true;
                    }
                }
                      
                for(DispatchDashboardListByOwner__x disp : dispListbySR)
                {
                  	ReletadDispatchWrapper dpstch = new ReletadDispatchWrapper();
                     
                    dpstch.DispatchNumber = disp.DPSNumber__c;
                    dpstch.Status = disp.Status__c;
                    dpstch.caseNumber = disp.SFDCCaseNumber__c;
                    dispatches.add(dpstch);                      
                }  
                    
                objDispatch.rltdDispatch = dispatches;
            }
            return objDispatch;
        }catch(exception e){
          	ExceptionHandler.logHandledExceptions(e,'ReletadDispatchController','getUserSRDispatches','CaseManagement');
            return null;
        } 
    }
    
    @AuraEnabled
    public static RelatedPagerWrapper getRelatedDispatchDetails (Id recordId, Decimal PageKey, String PageSize)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getRelatedDispatchDetails
    Description:  This method reads Dispatch details information from external object - story# 4150193
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    12/04/2017     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {  
        try
        { 
            Integer page = (Integer) PageKey;
            String sInteger = String.valueOf(page);
            string assetName = '';
            string deltaSRNumber = '';
            string lastPage='';
          
            List<ReletadDispatchWrapper> dispatches = new List<ReletadDispatchWrapper>();
            RelatedPagerWrapper objDispatch =  new RelatedPagerWrapper();
            
            // check for object to get the dispatch information  
            if(recordId.getsobjecttype().getDescribe().getName().equalsIgnoreCase(Label.ObjectNameAsset)) 
            {
                List<DispatchDetailsListByTag__x> dispListbyTag = new List<DispatchDetailsListByTag__x>();
                //query Asset Name
                assetName = [SELECT Name FROM Asset WHERE Id = :recordId limit 1].Name;
                
                if(!Test.isRunningTest() )
                {
                    dispListbyTag = [SELECT ExternalId, ServiceTag__c,  DateCreated__c, DPSNumber__c, ETA__c, LaborStatus__c, LastPage__c,
              						        Option__c, PartsStatus__c, ReturnTrackingNumber__c, ReturnTrackingNumberCarrier__c,
                                            Status__c, TrackingNumber__c, TrackingNumberCarrier__c FROM DispatchDetailsListByTag__x 
                                            WHERE ServiceTag__c=:assetName AND PageKey__c=:sInteger AND PageSize__c=:PageSize LIMIT 200 ];
                }
                else{
                    dispListbyTag.add(new DispatchDetailsListByTag__x(ExternalId = '1234543',TrackingNumber__c = '124312', TrackingNumberCarrier__c ='12344',
                                                                      Option__c = 'sample', Status__c = 'Delivered', PartsStatus__c = 'Shipped', 
																	  ReturnTrackingNumber__c ='12244', ReturnTrackingNumberCarrier__c = '1234', 
																	  ServiceTag__c ='ABC123',  DateCreated__c = '01/01/2017', DPSNumber__c ='899', 
																	  ETA__c = 'TestETA', LaborStatus__c = 'Shipped', LastPage__c = 'false'	));
                    dispListbyTag.add(new DispatchDetailsListByTag__x(ExternalId = '77777',TrackingNumber__c = '69798695', TrackingNumberCarrier__c ='12344',
                                                                      Option__c = 'sample', Status__c = 'Delivered', PartsStatus__c = 'Shipped', 
																	  ReturnTrackingNumber__c ='12244', ReturnTrackingNumberCarrier__c = '1234', 
																	  ServiceTag__c ='ABC123',  DateCreated__c = '01/01/2017', DPSNumber__c ='899', 
																	  ETA__c = 'Test1', LaborStatus__c = 'Shipped', LastPage__c = 'true'	));
                    dispListbyTag.add(new DispatchDetailsListByTag__x(ExternalId = '88888',TrackingNumber__c = '096479', TrackingNumberCarrier__c ='12344',
                                                                      Option__c = 'sample', Status__c = 'Delivered', PartsStatus__c = 'Shipped', 
																	  ReturnTrackingNumber__c ='12244', ReturnTrackingNumberCarrier__c = '1234', 
																	  ServiceTag__c ='ABC123',  DateCreated__c = '01/01/2017', DPSNumber__c ='899', 
																	  ETA__c = 'Test3', LaborStatus__c = 'Shipped', LastPage__c = 'false'	));
                    dispListbyTag.add(new DispatchDetailsListByTag__x(ExternalId = '999999',TrackingNumber__c = '998987', TrackingNumberCarrier__c ='12344',
                                                                      Option__c = 'sample', Status__c = 'Delivered', PartsStatus__c = 'Shipped', 
																	  ReturnTrackingNumber__c ='12244', ReturnTrackingNumberCarrier__c = '1234', 
																	  ServiceTag__c ='ABC123',  DateCreated__c = '01/01/2017', DPSNumber__c ='899', 
																	  ETA__c = 'Test2', LaborStatus__c = 'Shipped', LastPage__c = 'false'	));
                }
                if (dispListbyTag.size()>0) 
                {      
                    lastPage = dispListbyTag[0].LastPage__c;
                	objDispatch.page = page;
                        
                	if (lastPage!=null && page!=null){
                		if (lastPage.equalsIgnoreCase('false') && page == 1){
                      		objDispatch.next = true;
                        	objDispatch.previous = false;
                    	}
                    	else if (lastPage.equalsIgnoreCase('true') && page > 1){
                      		objDispatch.next = false;
                        	objDispatch.previous = true;
                    	}
                    	else if (lastPage.equalsIgnoreCase('false') && page > 1){
                      		objDispatch.next = true;
                        	objDispatch.previous = true;
                    	}
                	}
                    for(DispatchDetailsListByTag__x disp : dispListbyTag)
                    {
                        ReletadDispatchWrapper dpstch = new ReletadDispatchWrapper();
                        
                        dpstch.DispatchNumber = disp.DPSNumber__c;
                        dpstch.Status = disp.Status__c;
                        dpstch.Option = disp.Option__c;
                        dpstch.eTA = disp.ETA__c;
                        dpstch.trackingNumber = disp.TrackingNumber__c;
                        dpstch.trackingNumberReturn = disp.ReturnTrackingNumber__c;
                        dpstch.dateCreated = disp.DateCreated__c;
                        dpstch.laborStatus = disp.LaborStatus__c;
                        dpstch.partsStatus = disp.PartsStatus__c;
                        
                        dispatches.add(dpstch);                      
                    }
                	objDispatch.rltdDispatch = dispatches;     
                } 
                
            }
            else if(recordId.getsobjecttype().getDescribe().getName().equalsIgnoreCase(Label.ObjectNameCase))
            {
                List<DispatchDetailsListBySr__x> dispListbySR = new List<DispatchDetailsListBySr__x>();
                deltaSRNumber = [SELECT Delta_SR__c FROM Case WHERE Id = :recordId LIMIT 1].Delta_SR__c;
                if(!Test.isRunningTest() )
                {
                    dispListbySR = [SELECT ExternalId,SRNumber__c,DateCreated__c,DPSNumber__c,ETA__c,LaborStatus__c,Option__c,PartsStatus__c,ReturnTrackingNumber__c,
                                   Status__c,ReturnTrackingNumberCarrier__c,TrackingNumber__c,TrackingNumberCarrier__c,LastPage__c,PageKey__c,PageSize__c FROM
                    			   DispatchDetailsListBySr__x where SRNumber__c = :deltaSRNumber AND PageKey__c=:sInteger AND PageSize__c=:PageSize LIMIT 200 ];   
                }
                else{
                    dispListbySR.add(new DispatchDetailsListBySr__x(ExternalId = 'ssss',SRNumber__c = '12345', ETA__c = 'Tomorrow', 
																	LaborStatus__c = 'shipped', PartsStatus__c = 'delivered', Status__c = 'Sample Status',
																	ReturnTrackingNumber__c = '1234', ReturnTrackingNumberCarrier__c ='355',
																	TrackingNumber__c = '99900', TrackingNumberCarrier__c ='9097',
                                                                    DPSNumber__c = '1234567', Option__c = 'Sample Option', LastPage__c = 'false'));
				    dispListbySR.add(new DispatchDetailsListBySr__x(ExternalId = 'ssss',SRNumber__c = '12345', ETA__c = 'Tomorrow', 
																	LaborStatus__c = 'shipped', PartsStatus__c = 'delivered', Status__c = 'Sample Status',
																	ReturnTrackingNumber__c = '123994', ReturnTrackingNumberCarrier__c ='3f55',
																	TrackingNumber__c = '99900', TrackingNumberCarrier__c ='9097',
                                                                    DPSNumber__c = '1234567', Option__c = 'Sample Option', LastPage__c = 'false'));
					dispListbySR.add(new DispatchDetailsListBySr__x(ExternalId = 'ssss',SRNumber__c = '12345', ETA__c = 'Tomorrow', 
																	LaborStatus__c = 'shipped', PartsStatus__c = 'delivered', Status__c = 'Sample Status',
																	ReturnTrackingNumber__c = '1234', ReturnTrackingNumberCarrier__c ='355',
																	TrackingNumber__c = '99900', TrackingNumberCarrier__c ='9097',
                                                                    DPSNumber__c = '1234567', Option__c = 'Sample Option', LastPage__c = 'false'));
					dispListbySR.add(new DispatchDetailsListBySr__x(ExternalId = 'ssss',SRNumber__c = '12345', ETA__c = 'Tomorrow', 
																	LaborStatus__c = 'shipped', PartsStatus__c = 'delivered', Status__c = 'Sample Status',
																	ReturnTrackingNumber__c = '1234', ReturnTrackingNumberCarrier__c ='999',
																	TrackingNumber__c = '99900', TrackingNumberCarrier__c ='9097',
                                                                    DPSNumber__c = '1234567', Option__c = 'Sample Option', LastPage__c = 'true'));
                }      
                
                if (dispListbySR.size()>0) 
                {    
                    lastPage = dispListbySR[0].LastPage__c;
                    objDispatch.page = page;
                            
                    if (lastPage!=null && page!=null)
                    {
                        if (lastPage.equalsIgnoreCase('false') && page == 1)
                        {
                            objDispatch.next = true;
                            objDispatch.previous = false;
                        }
                        else if (lastPage.equalsIgnoreCase('true') && page > 1)
                        {
                            objDispatch.next = false;
                            objDispatch.previous = true;
                        }
                        else if (lastPage.equalsIgnoreCase('false') && page > 1)
                        {
                            objDispatch.next = true;
                            objDispatch.previous = true;
                        }
                    }
                    
                    for(DispatchDetailsListBySr__x disp : dispListbySR)
                    {
                        ReletadDispatchWrapper dpstch = new ReletadDispatchWrapper();
                        
                        dpstch.DispatchNumber = disp.DPSNumber__c;
                        dpstch.Status = disp.Status__c;
                        dpstch.Option = disp.Option__c;
                        dpstch.eTA = disp.ETA__c;
                        dpstch.trackingNumber = disp.TrackingNumber__c;
                        dpstch.trackingNumberReturn = disp.ReturnTrackingNumber__c;
                        dpstch.dateCreated = disp.DateCreated__c;
                        dpstch.laborStatus = disp.LaborStatus__c;
                        dpstch.partsStatus = disp.PartsStatus__c;
                        dispatches.add(dpstch);                      
                    } 
                    objDispatch.rltdDispatch = dispatches;
                }                
            }
            return objDispatch;
        }  
        catch(exception e){
           	ExceptionHandler.logHandledExceptions(e, 'ReletadDispatchController','getRelatedDispatchDetails', 'CaseManagement');
            return null;
        } 
    }
    
    @AuraEnabled
    public static RelatedPagerWrapper getRelatedDispatches (Id recordId, Decimal PageKey, String PageSize)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getRelatedDispatches
    Description:  This method reads Dispatch dashboard information from external object - story# 4150193
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    11/02/2017     1.0     Rodrigo Carpio      Initial Release
    10/30/2018     1.1     Rajesh Guru           Nov Release story-Story 5086637 & 5150078 (added for Live chat transcript)
    -------------------------------------------------------------------------------------------------------------------------- */
    { 
        try
        {
            string lastPage='';
            string responseCode = '';
            Integer page = (Integer)PageKey;
            String sInteger = String.valueOf(page);
            string assetName = '';
            string deltaSRNumber = '';
            
            List<ReletadDispatchWrapper> dispatches = new List<ReletadDispatchWrapper>();
            RelatedPagerWrapper objDispatch =  new RelatedPagerWrapper();
            
            // check for object to get the dispatch information  
            if(recordId.getsobjecttype().getDescribe().getName().equalsIgnoreCase(Label.ObjectNameAsset)) 
            {
                List<DispatchDashboardListByTag__x> dispListbyTag = new List<DispatchDashboardListByTag__x>() ;
                assetName = [SELECT Name FROM Asset WHERE Id = :recordID limit 1].Name;
                
                if(!Test.isRunningTest() ){
                    dispListbyTag = [select ExternalId, TrackingNumber__c,  DPSNumber__c, Option__c, Status__c, LastPage__c
                                     from DispatchDashboardListByTag__x where ServiceTag__c=:assetName AND PageKey__c=:sInteger 
                                     AND PageSize__c=:PageSize LIMIT 200 ];
                }
                else{
                    dispListbyTag.add(new DispatchDashboardListByTag__x(ExternalId = 'ssss', Status__c = 'Sample Status', 
                                                                        TrackingNumber__c = '99900', DPSNumber__c = '1234567', 
                                                                        Option__c = 'Sample Option', LastPage__c = 'false'));
				    dispListbyTag.add(new DispatchDashboardListByTag__x(ExternalId = 'ssss', Status__c = 'Sample Status', 
                                                                        TrackingNumber__c = '99900', DPSNumber__c = '1234567', 
                                                                        Option__c = 'Sample Option', LastPage__c = 'false'));
					dispListbyTag.add(new DispatchDashboardListByTag__x(ExternalId = 'ssss', Status__c = 'Sample Status', 
                                                                        TrackingNumber__c = '99900', DPSNumber__c = '1234567', 
                                                                        Option__c = 'Sample Option', LastPage__c = 'false'));
					dispListbyTag.add(new DispatchDashboardListByTag__x(ExternalId = 'ssss', Status__c = 'Sample Status', 
                                                                        TrackingNumber__c = '99900', DPSNumber__c = '1234567', 
                                                                        Option__c = 'Sample Option', LastPage__c = 'false')); 
                }
           
                if (dispListbyTag.size()>0) 
                {                            
                    for(DispatchDashboardListByTag__x disp : dispListbyTag)
                    {
                        ReletadDispatchWrapper dpstch = new ReletadDispatchWrapper();
                        
                        dpstch.DispatchNumber = disp.DPSNumber__c;
                        dpstch.Status = disp.Status__c;
                        dpstch.Option = disp.Option__c;
                        dpstch.trackingNumber = disp.TrackingNumber__c;
                        dispatches.add(dpstch);                      
                    }  
                    
                    objDispatch.rltdDispatch = dispatches;  
                }
            }
            else if(recordId.getsobjecttype().getDescribe().getName().equalsIgnoreCase(Label.ObjectNameCase))
            {
                List<DispatchDashboardListBySr__x> dispListbySR = new List<DispatchDashboardListBySr__x>();
                deltaSRNumber = [SELECT Delta_SR__c FROM Case WHERE Id = :recordId LIMIT 1].Delta_SR__c;
                if(!Test.isRunningTest() )
                {
                    dispListbySR = [select ExternalId, SRNumber__c,  DPSNumber__c, Option__c, Status__c, TrackingNumber__c,LastPage__c from
                                    DispatchDashboardListBySr__x where SRNumber__c = :deltaSRNumber AND PageKey__c=:sInteger AND PageSize__c=:PageSize LIMIT 200 ];   
                }else
                {
                    dispListbySR.add(new DispatchDashboardListBySr__x(ExternalId = 'ssss',SRNumber__c = '12345', DPSNumber__c = '1234567', 
                                                                      Option__c = 'Sample Option', Status__c = 'Sample Status', 
                                                                      LastPage__c='false' ));
                    dispListbySR.add(new DispatchDashboardListBySr__x(ExternalId = 'sses',SRNumber__c = '123457', DPSNumber__c = '123452307', 
                                                                      Option__c = 'Sample Option', Status__c = 'Sample Status',
                                                                     LastPage__c='false' ));
                    dispListbySR.add(new DispatchDashboardListBySr__x(ExternalId = 'sses',SRNumber__c = '123457', DPSNumber__c = '123452307', 
                                                                      Option__c = 'Sample Option', Status__c = 'Sample Status',
                                                                     LastPage__c='false' ));
                    dispListbySR.add(new DispatchDashboardListBySr__x(ExternalId = 'sses',SRNumber__c = '123457', DPSNumber__c = '123452307', 
                                                                      Option__c = 'Sample Option', Status__c = 'Sample Status',
                                                                     LastPage__c='true' ));
                }      
                
                if (dispListbySR.size()>0)
                {    
                    for(DispatchDashboardListBySr__x disp : dispListbySR)
                    {
                        ReletadDispatchWrapper dpstch = new ReletadDispatchWrapper();
                        
                        dpstch.DispatchNumber = disp.DPSNumber__c;
                        dpstch.Status = disp.Status__c;
                        dpstch.Option = disp.Option__c;
                        dpstch.trackingNumber = disp.TrackingNumber__c;
                        dispatches.add(dpstch);
                       
                    }   
                    objDispatch.rltdDispatch = dispatches;  
                }               
            }
            else if(recordId.getsobjecttype().getDescribe().getName().equalsIgnoreCase(Label.objectNameLiveChatTranscript))
                {
                List<DispatchDashboardListBySr__x> dispListbySR = new List<DispatchDashboardListBySr__x>();
                deltaSRNumber = [SELECT Case.Delta_SR__c FROM LiveChatTranscript WHERE Id = :recordId LIMIT 1].Case.Delta_SR__c;
                if(!Test.isRunningTest() )
                {
                    dispListbySR = [select ExternalId, SRNumber__c,  DPSNumber__c, Option__c, Status__c, TrackingNumber__c,LastPage__c from
                                    DispatchDashboardListBySr__x where SRNumber__c = :deltaSRNumber AND PageKey__c=:sInteger AND PageSize__c=:PageSize LIMIT 200 ];   
                }else
                {
                    dispListbySR.add(new DispatchDashboardListBySr__x(ExternalId = 'ssss',SRNumber__c = '12345', DPSNumber__c = '1234567', 
                                                                      Option__c = 'Sample Option', Status__c = 'Sample Status', 
                                                                      LastPage__c='false' ));
                    dispListbySR.add(new DispatchDashboardListBySr__x(ExternalId = 'sses',SRNumber__c = '123457', DPSNumber__c = '123452307', 
                                                                      Option__c = 'Sample Option', Status__c = 'Sample Status',
                                                                     LastPage__c='false' ));
                    dispListbySR.add(new DispatchDashboardListBySr__x(ExternalId = 'sses',SRNumber__c = '123457', DPSNumber__c = '123452307', 
                                                                      Option__c = 'Sample Option', Status__c = 'Sample Status',
                                                                     LastPage__c='false' ));
                    dispListbySR.add(new DispatchDashboardListBySr__x(ExternalId = 'sses',SRNumber__c = '123457', DPSNumber__c = '123452307', 
                                                                      Option__c = 'Sample Option', Status__c = 'Sample Status',
                                                                     LastPage__c='true' ));
                }      
                
                if (dispListbySR.size()>0)
                {    
                    for(DispatchDashboardListBySr__x disp : dispListbySR)
                    {
                        ReletadDispatchWrapper dpstch = new ReletadDispatchWrapper();
                        
                        dpstch.DispatchNumber = disp.DPSNumber__c;
                        dpstch.Status = disp.Status__c;
                        dpstch.Option = disp.Option__c;
                        dpstch.trackingNumber = disp.TrackingNumber__c;
                        dispatches.add(dpstch);
                       
                    }   
                    objDispatch.rltdDispatch = dispatches;  
                }               
            }
            
            return objDispatch;
        }
        catch(exception e){
          	ExceptionHandler.logHandledExceptions(e, 'ReletadDispatchController','getRelatedDispatches', 'CaseManagement');
            return null;
        } 
    }
}