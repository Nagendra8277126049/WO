/**********************************************************************
Name:  EinsteinIntent_AdminController
======================================================
======================================================
Purpose: Controller EinsteinIntent_AdminHome component
-------                                               
This class is an adaptation of the class Einstein_CaseClassificAdminController adding 
methods and configuration related with Accidental Damage
======================================================
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL            Description
1.0   Rayana Alencar   2018-12-10      INITIAL DEVELOPMENT          CSR: 
1.1   Rayana Alencar   2019-02-07	   Update for Code Coverage 
***********************************************************************/

public class EinsteinIntent_AdminController {
    
    public static Einstein_PredictionService service;
    public static Boolean   testServiceError = False;
    
    public static void InitService()
    {
        if (service==null) {
            service = new Einstein_PredictionService(Einstein_PredictionService.Types.INTENT);
        }    
        if(testServiceError && Test.isRunningTest()){
            service.httpStatusCode = 500;
        }
    }
    
    @AuraEnabled
    public static String getEinsteinApiToken() {
        System.debug('Starting getEinsteinApiToken');
        InitService();
        if (service.httpStatusCode>200) {           
            throw new AuraHandledException(service.httpErrorMessage);
        }       
        String token =  service.getBearerToken();   
        System.debug(token);
        //String tokenresponse = 'EinsteinApiToken is: ' + token;
        return token;        
    }
    
    @AuraEnabled
    public static List<Einstein_Dataset> getDatasets() {
        System.debug('Starting getDatasets');
        InitService();        
        List<Einstein_Dataset> datasets = service.getDatasets();
        List<Einstein_Dataset> datasetsReturn = new List<Einstein_Dataset>();
        for (Einstein_Dataset dataset : datasets) {
            if ((dataset.type=='text-intent') && (dataset.available)) {
                // filter with models - Defect 
                long datasetID = dataset.id;
                System.debug(datasetID);
                try
                {
                    List<Einstein_Model> models = getModels(datasetID);
                    if (models.size() > 0) 
                    {
                        datasetsReturn.add(dataset); 
                    }                
                }                 
                catch (Exception e) 
                {
                    //ignore the dataset in case of error like 'Unable to start training for dataset 1080864 that is not yet available or failed to upload'
                }
            }
        }
        if (service.httpStatusCode>200) {            
            throw new AuraHandledException(service.httpErrorMessage);
        }
        return datasetsReturn;
    }
    
    @AuraEnabled
    public static List<Einstein_Model> getModels(Long datasetId) {
        System.debug('Starting getModels');
        InitService(); 
        Einstein_Model[] models = service.getModels(datasetId);
        System.debug('Models count:' + models.size());
        if (service.httpStatusCode>200) {           
            throw new AuraHandledException(service.httpErrorMessage);
        }
        return models;
    }
    
    @AuraEnabled
    public static String updateCaseModelId(String newModelID) {
        System.debug('Starting updateModelId');
        if (newModelID.length() < 5) { 
            throw new AuraHandledException('Confusion Matrix refresh error');
        }
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.CCModel_ID__c = newModelID;
        settings.CCModelLastUpdate__c = Datetime.now();
        settings.CCModelUpdatedBy__C = UserInfo.getName();        
        upsert settings;
        return newModelID;
    }
    
    @AuraEnabled
    public static String updateAccDamageModelId(String newModelID) {
        System.debug('Starting updateModelId');
        if (newModelID.length() < 5) {
            throw new AuraHandledException('Confusion Matrix refresh error'); 
        }
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.ADModel_ID__c = newModelID;
        settings.ADModelLastUpdate__c = Datetime.now();
        settings.ADModelUpdatedBy__c = UserInfo.getName();        
        upsert settings;
        return newModelID;
    }
    
    @AuraEnabled
    public static EinsteinIntent_AdminSettings getAdminSettings()
    {
        System.debug('Starting getAdminSettings');
        EinsteinIntent_AdminSettings admsettings = new EinsteinIntent_AdminSettings();
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        //Case classification
        admsettings.CCModel_ID = settings.CCModel_ID__c;
        admsettings.CCModelLastUpdate = settings.CCModelLastUpdate__c;
        admsettings.CCModelUpdatedBy = settings.CCModelUpdatedBy__C;
        
        //AD classification
        admsettings.ADModel_ID = settings.ADModel_ID__c;
        admsettings.ADModelLastUpdate = settings.ADModelLastUpdate__c;
        admsettings.ADModelUpdatedBy = settings.ADModelUpdatedBy__C;
        
        return admsettings;
    }
    
    @AuraEnabled
    public static List<Einstein_ApiUsage> getUsage() {
        System.debug('Starting getUsage');
        InitService();         
        List<Einstein_ApiUsage> usage = service.getApiUsage();
        if (service.httpStatusCode>200) {            
            throw new AuraHandledException(service.httpErrorMessage);
        }
        return usage;
    }
    
    @AuraEnabled
    public static String refreshMetrics() {
        System.debug('Starting refreshMetrics');   
        try 
        {
            boolean r = EinsteinMetrics.refreshMetrics();
            if (r) {
                return 'Confusion Matrix refreshed successfully';
            }
            else {
                throw new AuraHandledException('Confusion Matrix refresh error');
            }
        }
        catch(exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}