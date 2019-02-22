public with sharing class ProjectCreator{
    public static List<Order> getOrderInformation(List<string> orderIds)
    {
       List<Order> orders = [SELECT Id, DPID__c, Deal_ID__c, PoNumber, CustomerNumber__c, OrderNumber, Project__c, EffectiveDate, AccountId, CurrencyIsoCode, BUID__c, Status, OCI_Order_Type__c, Sales_Channel__c FROM Order WHERE Id IN :orderIds];
       return orders;
    }
    public static Account getAccountInformation(string AccountId)
    {
        Account acc = [SELECT Id, Name, AccountNumber FROM Account WHERE Id = :AccountId];
        return acc;
    }
    public static pse__Practice__c getPracticeInformation(string practiceName)
    {
        pse__Practice__c practice = [SELECT Id, Name FROM pse__Practice__c WHERE Name = :practiceName LIMIT 1];
        return practice;
    }
    public static Id getProjectManagerId()
    {
        string projectManagerId = IDS_Default_Project_Manager__c.getOrgDefaults().value__c;
        Contact[] pm = [SELECT Id FROM Contact where Id = :projectManagerId LIMIT 1];
        return pm.size() > 0 ? pm[0].Id : null;
    }
    public static pse__Proj__c getProjectTemplate(string Type)
    {
        return getIDSProjectTemplate(Type);
    }
    public static pse__Proj__c getIDSProjectTemplate(string Type)
    {
        if (Type != 'IDS')
        {
            return null;
        }
        else
        {
            String projectTemplateName = 'Phased Project Template - Custom - Global';
            pse__Proj__c templateProject = [SELECT Id, pse__Is_Template__c FROM pse__Proj__c WHERE Name = :projectTemplateName AND pse__Is_Template__c = true AND pse__Is_Active__c = true LIMIT 1];
            System.debug('Template project Created..: ' + templateProject.Id);
			System.debug('Project Template: ' + templateProject.pse__Is_Template__c);          
            
            return templateProject;
        }
            
    }

    public static pse.SObjectCloneMapper.Field setCurrencyMappField(Order order)
    {
        pse.SObjectCloneMapper.Field CurrencyMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.CurrencyIsoCode );
        CurrencyMappField.defaultValue = Order.CurrencyIsoCode;
        return CurrencyMappField; 
    }
    public static pse.SObjectCloneMapper.Field setPONumberMappField(Order order)
    {
        pse.SObjectCloneMapper.Field PoNumberMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.PO_Number__c );
        PoNumberMappField.defaultValue = Order.PoNumber;
        return PoNumberMappField; 
    }
    public static pse.SObjectCloneMapper.Field setDPIdMappField(Order order)
    {
        pse.SObjectCloneMapper.Field DPIdMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.DP__c );
        DPIdMappField.defaultValue = Order.DPID__c;
        return DPIdMappField; 
    }
    public static pse.SObjectCloneMapper.Field setDealIdMappField(Order order)
    {
        pse.SObjectCloneMapper.Field DealIdMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.Deal__c );
		DealIdMappField.defaultValue = Order.Deal_ID__c;
        return DealIdMappField; 
    }
    public static pse.SObjectCloneMapper.Field setIsTemplateMappField()
    {
        pse.SObjectCloneMapper.Field IsTemplateMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.pse__Is_Template__c);
        IsTemplateMappField.defaultValue = False;
        return IsTemplateMappField; 
    }
    public static pse.SObjectCloneMapper.Field setRegionMappField(Order order)
    {
        pse.SObjectCloneMapper.Field RegionMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.pse__Region__c );
        pse__region__c region = RegionManager.GetRegionByBUID(order.BUID__c);
        RegionMappField.defaultValue = region != null ? region.Id : null;
        return RegionMappField; 
    }
    public static pse.SObjectCloneMapper.Field setStartDateMappField(Order order)
    {
        Date startDate = Date.today();
        
        pse.SObjectCloneMapper.Field StartDateMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.pse__Start_Date__c );
        StartDateMappField.defaultValue = startDate;
        return StartDateMappField; 
    }
    public static pse.SObjectCloneMapper.Field setEndDateMappField(Order order)
    {
        Date startDate = Date.today();
               
        pse.SObjectCloneMapper.Field EndDateMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.pse__End_Date__c );
        EndDateMappField.defaultValue = startDate.addDays(7);
        return EndDateMappField; 
    }
    public static pse.SObjectCloneMapper.Field setPracticeMappField()
    {
        pse.SObjectCloneMapper.Field PracticeMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.pse__Practice__c );
        PracticeMappField.defaultValue = getPracticeInformation('Infrastructure Delivery Services').Id;
        return PracticeMappField; 
    }
    public static pse.SObjectCloneMapper.Field setAccountMappField(Account account)
    {
        pse.SObjectCloneMapper.Field AccountMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.pse__Account__c );
        AccountMappField.defaultValue = account.Id;
        return AccountMappField; 
    }
    public static pse.SObjectCloneMapper.Field setNameMappField(Account account)
    {
        pse.SObjectCloneMapper.Field NameMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.Name );
        NameMappField.defaultValue = account.Name + Datetime.now().format('MMM dd yyyy HHmmss');
        return NameMappField; 
    }
    public static pse.SObjectCloneMapper.Field setUniqueNameMappField(Account account)
    {
        pse.SObjectCloneMapper.Field UniqueNameMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.Project_Name_Unique__c );
        UniqueNameMappField.defaultValue = account.Name + Datetime.now().format('MMM dd yyyy HHmmss');
        return UniqueNameMappField; 
    }
    public static pse.SObjectCloneMapper.Field setProjectManagerMappField()
    {
        pse.SObjectCloneMapper.Field ProjectManagerMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.pse__Project_Manager__c );
        ProjectManagerMappField.defaultValue = getProjectManagerId();
        return ProjectManagerMappField; 
    }
    public static pse.SObjectCloneMapper.Field setProjectVisibilityMappField(Order order)
    {
        pse.SObjectCloneMapper.Field ProjectVisibilityMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.Project_Visibility__c );
        
        if ((!string.isEmpty(order.OCI_Order_Type__c) && order.OCI_Order_Type__c.containsIgnoreCase('FED'))
            || (!string.isEmpty(order.Sales_Channel__c) && order.Sales_Channel__c.containsIgnoreCase('FED'))) {
             ProjectVisibilityMappField.defaultValue = 'Federal';
        } else {
            ProjectVisibilityMappField.defaultValue = 'All';
        }
        
        return ProjectVisibilityMappField; 
    }

    public static pse.SObjectCloneMapper.Field setProjectTypeMappField()
    {
        pse.SObjectCloneMapper.Field ProjectTypeMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.pse__Project_Type__c );
        ProjectTypeMappField.defaultValue = 'Standard';
        return ProjectTypeMappField; 
    }
    
    public static pse__Region__c getRegion(string regionId) 
    {
        if(String.isNotBlank(regionId))
        {
            pse__Region__c region = [SELECT Id, Name, pse__Parent_Region__c FROM pse__Region__c WHERE Id = :regionId];
    
            return region;
        }
        else
        return null;
    }
    
    public static pse__Region__c getGlobalRegion() 
    {
         pse__Region__c region = [SELECT Id, Name, pse__Parent_Region__c FROM pse__Region__c WHERE Name like 'Global%'];
    
         return region;
    }
    
    public static Id getQueueIdByRegionName(string regionName)
    {
        string queueName = 'IDS_' + regionName + '_Projects';
        
        List<Group> queue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :queueName];
        
        if (queue.size() == 0) {
            queue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'IDS_Undefined_Projects'];  
        }
        
        return queue[0].Id;
    }
    
    public static Id getProjectOwnerId(string regionId)
    {
        pse__Region__c region = getRegion(regionId);
        
        pse__Region__c parentRegion = region != null ? getRegion(region.pse__Parent_Region__c) : getGlobalRegion();
        
        Id ownerId = getQueueIdByRegionName(parentRegion.Name);
        
        return ownerId; 
    }
    
    private static pse.SObjectCloneMapper.Field setProjectTemplateIdMappField(Id templateId)
    {
        pse.SObjectCloneMapper.Field projectTemplateIdMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.Template_Id__c);
        
        projectTemplateIdMappField.defaultValue = templateId;
        
        return projectTemplateIdMappField; 
    }
    
    public static pse.CreateProjectFromTemplateService.CreateProjectResponse createProjectFromTemplate(pse__Proj__c template, Order order)
    {
            Account account = getAccountInformation(order.AccountId);
            pse.SObjectCloneMapper.Field CurrencyMappField = setCurrencyMappField(order);
            pse.SObjectCloneMapper.Field IsTemplateMappField = setIsTemplateMappField();
            pse.SObjectCloneMapper.Field RegionMappField = setRegionMappField(order);
            pse.SObjectCloneMapper.Field StartDateMappField = setStartDateMappField(order);
            pse.SObjectCloneMapper.Field EndDateMappField = setEndDateMappField(order);
            pse.SObjectCloneMapper.Field PracticeMappField = setPracticeMappField();
            pse.SObjectCloneMapper.Field AccountMappField = setAccountMappField(account);
            pse.SObjectCloneMapper.Field NameMappField = setNameMappField(account);
            pse.SObjectCloneMapper.Field UniqueNameMappField = setUniqueNameMappField(account);
            pse.SObjectCloneMapper.Field ProjectManagerMappField = setProjectManagerMappField();
            pse.SObjectCloneMapper.Field ProjectVisibilityMappField = setProjectVisibilityMappField(order);
            pse.SObjectCloneMapper.Field ProjectTypeMappField = setProjectTypeMappField();
            pse.SObjectCloneMapper.Field PONumberMappField = setPoNumberMappField(order);
            pse.SObjectCloneMapper.Field DPIdMappField = setDPIdMappField(order);
        	pse.SObjectCloneMapper.Field DealIdMappField = setDealIdMappField(order);
            pse.SObjectCloneMapper.Field ProjectTemplateIdMappField = setProjectTemplateIdMappField(template.Id);
            
        	// Group together the pse.SObjectCloneMapper.Field instantiated above for each object and prepare a set.
            Set<pse.SObjectCloneMapper.Field> setMapperFields = new Set<pse.SObjectCloneMapper.Field> {
                CurrencyMappField, 
                RegionMappField, 
                IsTemplateMappField,
                StartDateMappField,
                EndDateMappField,
                AccountMappField,
                NameMappField,
                UniqueNameMappField,
                ProjectManagerMappField,
                ProjectVisibilityMappField,
                ProjectTypeMappField,
                PONumberMappField,
                DPIdMappField,
                DealIdMappField,
                ProjectTemplateIdMappField };
                 
            // Instantiate the pse.SObjectCloneMapper using the prepared set of pse.SObjectCloneMapper.Field for each object.
            pse.SObjectCloneMapper mapp = new pse.SObjectCloneMapper(pse__Proj__c.SObjectType, setMapperFields);            
            // ----------------------------------------------------------------------------------------------------------------------------------
                
            pse.CreateProjectFromTemplateService.CreateProjectFromTemplateRequest PROJ_REQ1 = 
            new pse.CreateProjectFromTemplateService.CreateProjectFromTemplateRequest(template.Id, Date.today());
               
                
            System.debug('Project Request...: ' + PROJ_REQ1);
            PROJ_REQ1.ProjectName = account.Name + ' ' + Datetime.now().format('MMM dd yyyy HHmmss');
            PROJ_REQ1.IsActive = true;   
            PROJ_REQ1.IsTemplate = false;
            PROJ_REQ1.Mappers = new List<pse.SObjectCloneMapper>{mapp};
            PROJ_REQ1.ProjectOwnerId = Id.valueOf(UserInfo.getUserId());   
            System.debug('Project Request...: ' + PROJ_REQ1);
              
            List<pse.CreateProjectFromTemplateService.CreateProjectResponse> PROJ_RESPONSES = new List<pse.CreateProjectFromTemplateService.CreateProjectResponse>();
                
            try
            {
              PROJ_RESPONSES = pse.CreateProjectFromTemplateService.createProjectsFromTemplates(new List<pse.CreateProjectFromTemplateService.CreateProjectFromTemplateRequest>{PROJ_REQ1});    
            } catch(Exception e)
            {
              System.debug('EXCEPTIONS' + e.getMessage());
            }
                
            //Get the first response cause we are just submitting only one project to be created
            pse.CreateProjectFromTemplateService.CreateProjectResponse response = PROJ_RESPONSES[0];
               
            System.debug('Response...: ' + response.isSuccess());
               
            if(response.isSuccess()) 
            {
                pse__Proj__c createdProject = [SELECT Id, OwnerId, pse__End_Date__c, pse__Start_Date__c, pse__Region__c, pse__Practice__c, CurrencyIsoCode from pse__Proj__c WHERE Id =: response.NewProjectId LIMIT 1];
                if(RegionMappField.DefaultValue !=null)
              		createdProject.OwnerId =  getProjectOwnerId(String.valueOf(RegionMappField.DefaultValue));
            	else
              		createdProject.OwnerId =  getProjectOwnerId(String.valueOf(''));  	
                
                update(createdProject);
                if(!Test.isRunningTest()){
                    pse__Resource_Request__c resourceRequest = new pse__Resource_Request__c();
                    resourceRequest.pse__Resource_Role__c = 'Project Manager';
                    resourceRequest.pse__SOW_Hours__c = 1;
                    resourceRequest.pse__Project__c = createdProject.Id;
                    resourceRequest.pse__End_Date__c = createdProject.pse__End_Date__c;
                    resourceRequest.pse__Start_Date__c = createdProject.pse__Start_Date__c;
                    resourceRequest.pse__Region__c = createdProject.pse__Region__c;
                    resourceRequest.pse__Practice__c = createdProject.pse__Practice__c;
                    resourceRequest.CurrencyIsoCode = createdProject.CurrencyIsoCode;
                    
                     insert resourceRequest;
                }
                
                return response;
            }
            else 
            {
               System.debug('Request for this response :' + response.Request);
               System.debug('Errors related to unsuccessful request :' + response.Errors);
    
               return null;
            }
            
    }

    @InvocableMethod(label='Create Project by OrderId' description='Create a project by order id, it uses the FF method to create a project by a template.')
    public static List<string> createProjectByOrderId(List<string> orderIds)
    {
        List<Id> projectIds = new List<Id>();
        
        List<Order> orders = getOrderInformation(orderIds);
        pse__Proj__c templateProject = getIDSProjectTemplate('IDS');
        List<Clone_Project_Info__c> cloneProjectInfo = new List<Clone_Project_Info__c>();

        for (Order order : orders) {
            if(order.Status != 'CL') {
                pse.CreateProjectFromTemplateService.CreateProjectResponse response = createProjectFromTemplate(templateProject, order);
                
                projectIds.add(response.NewProjectId);

                if (response != null && String.isNotEmpty(response.QueuedJobId)) {
                	cloneProjectInfo.add(new Clone_Project_Info__c(Order__c = order.Id, Project__c = response.NewProjectId, Queued_Job_Id__c = response.QueuedJobId));
                }
            }
        }
        
        if (projectIds.size() > 0) {
        	// Delete the default budgets created by the FF API
        	List<pse__budget__c> defaultBudgets = [SELECT Id FROM pse__Budget__c WHERE pse__Project__c IN :projectIds];
        	delete defaultBudgets;
    	}
        
        if (!cloneProjectInfo.isEmpty()) {
        	insert cloneProjectInfo;
        }
        
        return projectIds;
    }

    public static string createProjectByOrderIdWithCreateOrder(List<string> orderIds)
    {
        string result = 'Project has been created.';
        
        List<Order> orders = getOrderInformation(orderIds);
        pse__Proj__c templateProject = getIDSProjectTemplate('IDS');
        List<Clone_Project_Info__c> cloneProjectInfo = new List<Clone_Project_Info__c>();
        
        for(Order order : orders) {
        	if(order.Status != 'CL') {
                pse.CreateProjectFromTemplateService.CreateProjectResponse response = createProjectFromTemplate(templateProject, order);
                
                if (response != null) {
                    // Delete the default budget created by the FF API
                    pse__budget__c defaultBudget = [SELECT Id FROM pse__Budget__c WHERE pse__Project__c = :response.NewProjectId];
                    delete defaultBudget;
                    
                    order.Project__c = response.NewProjectId;
                    update order;
                    
                    FlowRunner.Run_Create_Order_Budget_for_Project(order.Id, response.NewProjectId);
                    
                    if (String.isNotEmpty(response.QueuedJobId)) {
                    	cloneProjectInfo.add(new Clone_Project_Info__c(Order__c = order.Id, Project__c = response.NewProjectId, Queued_Job_Id__c = response.QueuedJobId));
                    }
                }
            }
            else {
				result = 'You can´t create project from a cancelled order.';
            }
        }
        
        if (!cloneProjectInfo.isEmpty()) {
       		insert cloneProjectInfo;
        }
        
        return result;
    }

}