/**********************************************************************
 Name:  Einstein_CaseClassificAdminController()
  ======================================================
======================================================
Purpose: Controller to support Case Classification Admin page
-------                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL            Description
   1.0   Rodrigo Parizotto       2018-10-05      INITIAL DEVELOPMENT          CSR: 
***********************************************************************/

public class Einstein_CaseClassificAdminController {
    
    public static Einstein_PredictionService service;
    
    public static void InitService()
    {
        if (service==null) {
            service = new Einstein_PredictionService(Einstein_PredictionService.Types.INTENT);
        }        
    }
    
    @AuraEnabled
    public static String getEinsteinApiToken() {
        System.debug('Starting getEinsteinApiToken');
        InitService();
        if (service.httpStatusCode>200) {            throw new AuraHandledException(service.httpErrorMessage);
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
                        datasetsReturn.add(dataset);                    }                }                 catch (Exception e)                {
                    //ignore the dataset in case of error like 'Unable to start training for dataset 1080864 that is not yet available or failed to upload'
                }
            }
        }
        if (service.httpStatusCode>200) {            throw new AuraHandledException(service.httpErrorMessage);
        }
        return datasetsReturn;
    }
    
    @AuraEnabled
    public static List<Einstein_Model> getModels(Long datasetId) {
        System.debug('Starting getModels');
        InitService(); 
        Einstein_Model[] models = service.getModels(datasetId);
        System.debug('Models count:' + models.size());
        if (service.httpStatusCode>200) {            throw new AuraHandledException(service.httpErrorMessage);
        }
        return models;
    }
    
    @AuraEnabled
    public static String updateModelId(String newModelID) {
        System.debug('Starting updateModelId');
        if (newModelID.length() < 5) { throw new AuraHandledException('Confusion Matrix refresh error'); }
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        settings.CCModel_ID__c = newModelID;
        settings.CCModelLastUpdate__c = Datetime.now();
        settings.CCModelUpdatedBy__C = UserInfo.getName();        
        upsert settings;
        return newModelID;
    }
    
    @AuraEnabled
    public static Einstein_CaseClassificAdminSettings getAdminSettings()
    {
        System.debug('Starting getAdminSettings');
        Einstein_CaseClassificAdminSettings admsettings = new Einstein_CaseClassificAdminSettings();
        Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        admsettings.CCModel_ID = settings.CCModel_ID__c;
        admsettings.CCModelLastUpdate = settings.CCModelLastUpdate__c;
        admsettings.CCModelUpdatedBy = settings.CCModelUpdatedBy__C;
        return admsettings;
    }
    
    @AuraEnabled
    public static List<Einstein_ApiUsage> getUsage() {
        System.debug('Starting getUsage');
        InitService();         
        List<Einstein_ApiUsage> usage = service.getApiUsage();
        if (service.httpStatusCode>200) {            throw new AuraHandledException(service.httpErrorMessage);
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