// TODO: We should filter the SKU Effort Mappings by template. 
public class SKUEffortAutomator {
    private class ProjectTaskSkuEffortMappingEntry {
        public String TaskName { get; set; }    
        public Id SKU_Effort_Mapping_Entry { get; set; }
        public Id ParentTask { get; set; }
        public Decimal SKU_Quantity { get; set; }
    }
    
    private class TaskSkuEffortMapEntry {
        public Id SkuEffortMapEntryId { get; set; }
        public String TaskName { get; set; }
    }
    
    private class TaskSkuEffortMap {
        public Id SkuEffortMapId { get; set; }
        public pse__Project_Task__c ProjectTask { get; set; }
    }
   
	private static List<string> IdsSkuValues;
    private static final String CUSTOM_SKU_NUMBER = 'CUSTOM SKU';
    
    public SKUEffortAutomator(){
        IdsSkuValues = new List<string>{ 'SVC EDT INSTLN', 'SVC EDT CNSLT', 'SVC CLNT INSTLN', 'SVC CLNT INSTLN' };
    }
    
    public void ManageTasksCreation(Id orderId , Id ProjectId) {
      
        // Get the OrderItems 
        OrderItem[] items = [SELECT Id, OrderId, Quantity, SKU_Number__c, Item_Class_Description__c, Order.Project__r.pse__Practice__c FROM OrderItem WHERE OrderId = :orderId AND Order.Status != :'CL'];
        system.debug('items ' + items);
        // Get the SKUs from order Items
        Set<String> SKUs = new Set<String>();
        for (OrderItem item : items) 
            SKUs.add(item.SKU_Number__c); 
        
        // Get the mappings with the mapp entries
        List<Sku_Effort_Map__c> mapps = 
        [
            SELECT Id , Name, SKU_Number__c, Description__c,
        		(SELECT Name__c, Project__c, Phase__r.Name, Role__c, SKU_Effort_Map__c, Estimated_Hours__c, toLabel(Project_Complexity_Tier__c) FROM SKU_Effort_Map_Entries__r)  // HERE WE CAN FILTER BY TEMPLATE ID IN THE FUTURE
        	FROM Sku_Effort_Map__c 
            WHERE 
            	SKU_Number__c IN :SKUs and 
            	active__c = true
        ];
        
        Set<Id> customSvcItems = new Set<Id>();
        
        if (items.size() > 0) {
            Id practiceId = items[0].Order.Project__r.pse__Practice__c;

            customSvcItems = getCustomSvcItems(items, mapps, practiceId);

            // Custom SKU config
            if (customSvcItems.size() > 0) {
                Id projectPracticeId = items[0].Order.Project__r.pse__Practice__c;

                Sku_Effort_Map__c customSkuEffortMap = getCustomSkuEffortMap(projectPracticeId);

                if (customSkuEffortMap != null) {
                	mapps.add(customSkuEffortMap);
                }
            }
        }

        SKU_Effort_Map_Entry__c[] mappEntries = getEntriesFromSKUEffortMappList(mapps);

        // Get the existing top tasks for the project
        pse__Project_Task__c[] existingParentTasks = [SELECT Name From pse__Project_Task__c WHERE pse__Project__c = :ProjectId  and pse__Parent_Task__c = null];

        // Find which parents tasks needs to be created
        Set<string> newParentTaskNames = new Set<string>();

        pse__Proj__c project = [SELECT PM_Complexity__c, pse__Project_Type__c FROM pse__Proj__c WHERE Id = :ProjectId LIMIT 1];

        for (SKU_Effort_Map_Entry__c  entry : mappEntries) {
            newParentTaskNames.add(entry.Phase__r.Name);
        }

        for (pse__Project_Task__c  t : existingParentTasks) {
            newParentTaskNames.remove(t.Name);
        }

        // Create the required tasks
        pse__Project_Task__c[] tasks = new pse__Project_Task__c[]{};
        for(string taskName : newParentTaskNames) {

            pse__Project_Task__c t = new pse__Project_Task__c();
            t.Name = taskName;
            t.pse__project__c = projectId;
            tasks.add(t);
		}

        // Persist the Top tasks in the Database
        upsert(tasks);

        Set<pse__Project_Task__c> topTasks = new Set<pse__Project_Task__c>();
        topTasks.addAll(existingParentTasks);
        topTasks.addAll(tasks);

        Set<Id> topTaskIds = new Set<Id>();

        for (pse__Project_Task__c  t : topTasks) {
            topTaskIds.add(t.Id);
        }

        // Get the existing child Tasks
       	pse__Project_Task__c[] childTasks = [SELECT Name , pse__Estimated_Hours__c, pse__Parent_Task__c From pse__Project_Task__c WHERE pse__Project__c =: ProjectId and pse__Parent_Task__c != null];

        Boolean shouldUpdateProjectType = false;

        List<ProjectTaskSkuEffortMappingEntry> projectTaskSkuEffortMappingEntries = new List<ProjectTaskSkuEffortMappingEntry>();
        List<TaskSkuEffortMapEntry> taskSkuEffortMapEntries = new List<TaskSkuEffortMapEntry>();
        
        Map<Id, List<TaskSkuEffortMap>> orderItemTaskMap = new Map<Id, List<TaskSkuEffortMap>>();
        
        //Foreach SKU Effort Entry we create a child task if needed and add hours
        for (OrderItem item : items)
        {
            // Get The mapp for this specific order item
            Sku_Effort_Map__c SKUEquivalentMap = new Sku_Effort_Map__c();

            for(Sku_Effort_Map__c m : mapps)
            {
                if(m.SKU_Number__c == item.SKU_Number__c) {
                    SKUEquivalentMap = m;

                    break;
                }
                // Custom SKU
                else if (m.SKU_Number__c.equalsIgnoreCase(CUSTOM_SKU_NUMBER) && customSvcItems.contains(item.Id)) {
                    SKUEquivalentMap = m;
                    
					shouldUpdateProjectType = true;

                    break;
                }
            }

            if (string.isNotEmpty(SKUEquivalentMap.SKU_Number__c))
            {
                SKU_Effort_Map_Entry__c[] SKUEquivalentMapEntries = SKUEquivalentMap.SKU_Effort_Map_Entries__r;

                if(SKUEquivalentMapEntries != null)
                {
                    List<TaskSkuEffortMap> taskSkuEffortMaps = new List<TaskSkuEffortMap>();
                    
                    for ( SKU_Effort_Map_Entry__c  entry : SKUEquivalentMapEntries )
                    {
                        // Get the top task for for this entrie
                        string topTaskName = entry.Phase__r.Name;
                        pse__project_task__c parentTask = GetFirstTaskByName(entry.Phase__r.Name, new List<pse__project_task__c>(topTasks));
                        pse__project_task__c existingChildTask = GetFirstChildTaskByName(entry.Name__c , parentTask.Id , new List<pse__project_task__c>(childTasks));

                        ProjectTaskSkuEffortMappingEntry projTaskSkuEffEntry = new ProjectTaskSkuEffortMappingEntry();
                        projTaskSkuEffEntry.SKU_Effort_Mapping_Entry = entry.Id;
                        projTaskSkuEffEntry.SKU_Quantity = item.Quantity;

                        TaskSkuEffortMap taskSkuEffortMap = new TaskSkuEffortMap();
                        taskSkuEffortMap.SkuEffortMapId = entry.SKU_Effort_Map__c;



                        // if task child task exist, sdd hours to existing child task
                        if(existingChildTask != null)
                        {
                            if(existingChildTask.pse__Estimated_Hours__c == null) { existingChildTask.pse__Estimated_Hours__c = 0; }
                            if(entry.Estimated_Hours__c == null) { entry.Estimated_Hours__c = 0; }

                            existingChildTask.pse__Estimated_Hours__c += ( entry.Estimated_Hours__c * item.Quantity) ;

                            projTaskSkuEffEntry.TaskName = existingChildTask.Name;
                            projTaskSkuEffEntry.ParentTask = existingChildTask.pse__Parent_Task__c;

                            taskSkuEffortMap.ProjectTask = existingChildTask;
                        }
                        // otherwise add a new childTask
                        else
                        {
                            pse__Project_Task__c t = new pse__Project_Task__c();

                            t.Name = entry.Name__c;
                            t.pse__project__c = projectId;
                            t.pse__Parent_Task__c = parentTask.Id;
                            t.pse__Estimated_Hours__c = ( entry.Estimated_Hours__c * item.Quantity);

                            childTasks.add(t);

                            projTaskSkuEffEntry.TaskName = t.Name;
                            projTaskSkuEffEntry.ParentTask = t.pse__Parent_Task__c;

                            taskSkuEffortMap.ProjectTask = t;
                        }
                        taskSkuEffortMaps.add(taskSkuEffortMap);

                        projectTaskSkuEffortMappingEntries.add(projTaskSkuEffEntry);

                        TaskSkuEffortMapEntry taskSkuEffortMapEntry = new TaskSkuEffortMapEntry();

                        taskSkuEffortMapEntry.SkuEffortMapEntryId = entry.Id;
                        taskSkuEffortMapEntry.TaskName = projTaskSkuEffEntry.TaskName;

                        taskSkuEffortMapEntries.add(taskSkuEffortMapEntry);
                    }
                    
                    if (!taskSkuEffortMaps.isEmpty()) {
                    	orderItemTaskMap.put(item.Id, taskSkuEffortMaps);
                    }
                }
            }
            else
            {
                //Checks if the item has an IDS Sku
            	if(IdsSkuValues.contains(item.Item_Class_Description__c))
            	{
                	shouldUpdateProjectType = true;
            	}
            }
        }

        upsert(childTasks);

        List<Project_Task_SKU_Effort_Mapping_Entry__c> projectTaskSkuEffortMappingEntriesC = new List<Project_Task_SKU_Effort_Mapping_Entry__c>();

        List<Project_Task_Skill__c> projectTaskSkills = getExistingProjectTaskSkills(childTasks);
        List<Skill_SKU_Effort_Map_Entry__c> skills = getSkillsBySkuEffortMapEntries(mappEntries);

        for (pse__project_task__c task : childTasks) {
            for (ProjectTaskSkuEffortMappingEntry projTaskEntry : projectTaskSkuEffortMappingEntries) {
                if (task.Name == projTaskEntry.TaskName && task.pse__Parent_Task__c == projTaskEntry.ParentTask) {

					Project_Task_SKU_Effort_Mapping_Entry__c projTaskMapEntry = new Project_Task_SKU_Effort_Mapping_Entry__c(
						SKU_Effort_Mapping_Entry__c = projTaskEntry.SKU_Effort_Mapping_Entry,
                        Project_Task__c = task.Id,
                       	SKU_Quantity__c = projTaskEntry.SKU_Quantity
                    );

                    projectTaskSkuEffortMappingEntriesC.add(projTaskMapEntry);
                }
            }

            for (TaskSkuEffortMapEntry taskSkuEffortMapEntry : taskSkuEffortMapEntries) {
                if (task.Name == taskSkuEffortMapEntry.TaskName) {
                	List<Project_Task_Skill__c> taskSkills = addProjectTaskSkillsBySkuEffortMapEntryId(task.Id, taskSkuEffortMapEntry.SkuEffortMapEntryId, projectTaskSkills, skills);
                    projectTaskSkills.addAll(taskSkills);
                }
            }
        }

        insert(projectTaskSkuEffortMappingEntriesC);
        upsert(projectTaskSkills);
        
        List<Order_Item_Sku_Effort_Map__c> orderItemsSkuEffortMaps = new List<Order_Item_Sku_Effort_Map__c>();
        system.debug('orderItemTaskMap ' + orderItemTaskMap);
        for (Id orderItemId : orderItemTaskMap.keySet()) {
            List<TaskSkuEffortMap> taskSkuEffortMaps = orderItemTaskMap.get(orderItemId);
            
            for (TaskSkuEffortMap taskSkuEffortMap : taskSkuEffortMaps) {
                Order_Item_Sku_Effort_Map__c orderItemSkuEffortMap = new Order_Item_Sku_Effort_Map__c(
                    Order_Product__c = orderItemId, 
                    SKU_to_Effort_Mapping__c = taskSkuEffortMap.SkuEffortMapId, 
                    Project_Task__c = taskSkuEffortMap.ProjectTask.Id
                );
                
            	orderItemsSkuEffortMaps.add(orderItemSkuEffortMap);        
            }
        }
        
        insert(orderItemsSkuEffortMaps);

        //If there is any OrderItem that doesn't have an IDS mapping on SkuEfforMap and the ProjectType isn't Custom already
        //Then we should update the ProjectType to custom
        Boolean isProjectTypeCustom = project.pse__Project_Type__c == 'Custom';
		if(shouldUpdateProjectType && !isProjectTypeCustom)
        {
            project.pse__Project_Type__c = 'Custom';
            update(project);
        }

        RemoveDuplicatedTasks(ProjectId);
        setPMComplexity(ProjectId);
    }

    public void ManageTasksRemoval(Id orderId , Id ProjectId)
    {
        // Get the OrderItems
        OrderItem[] items = [SELECT Id , OrderId , Quantity , SKU_Number__c, Item_Class_Description__c FROM OrderItem WHERE OrderId =: orderId ];

        // Get the SKUs from order Items
        Set<String> SKUs = new Set<String>();
        for (OrderItem item : items) SKUs.add(item.SKU_Number__c);

        // Get the mappings with the mapp entries
        Sku_Effort_Map__c[] mapps =
        [
            SELECT Id , Name, SKU_Number__c,
        		(SELECT Name__c, Project__c, Phase__r.Name, Role__c, SKU_Effort_Map__c, Estimated_Hours__c, Project_Complexity_Tier__c FROM SKU_Effort_Map_Entries__r)  // HERE WE CAN FILTER BY TEMPLATE ID IN THE FUTURE
        	FROM Sku_Effort_Map__c
            WHERE
            	SKU_Number__c IN :SKUs and
            	active__c = true
        ];

        Sku_Effort_Map__c customSkuEffortMap = null;

        // Custom SKU Config
		Id projectPracticeId = [SELECT pse__Practice__c FROM pse__Proj__c WHERE Id = :projectId].pse__Practice__c;

		Boolean hasCustomSvcItems = hasCustomSvcItems(projectId, orderId, projectPracticeId);

        Set<Id> customSvcItems = getCustomSvcItems(items, mapps, projectPracticeId);

        if (hasCustomSvcItems || customSvcItems.size() > 0) {
            customSkuEffortMap = getCustomSkuEffortMap(projectPracticeId);

            if (customSkuEffortMap != null) {
            	mapps.add(customSkuEffortMap);
            }
        }

        // Get the existing child Tasks
       	pse__Project_Task__c[] childTasks = [SELECT Name , pse__Estimated_Hours__c, pse__Parent_Task__c , pse__Parent_Task__r.Name From pse__Project_Task__c WHERE pse__Project__c =: ProjectId and pse__Parent_Task__c != null];

        //Foreach SKU Effort Entry we create a child task if needed and add hours
        for (OrderItem item : items)
        {
            // Get The mapp for this specific order item
            Sku_Effort_Map__c SKUEquivalentMap = null;

            for(Sku_Effort_Map__c m : mapps)
            {
                if(m.SKU_Number__c == item.SKU_Number__c ){
                    SKUEquivalentMap = m ;
                	break;
                }
 				// Custom SKU
                else if (m.SKU_Number__c.equalsIgnoreCase(CUSTOM_SKU_NUMBER) && customSvcItems.contains(item.Id)) {
                    SKUEquivalentMap = m;

                    break;
                }
            }

            if(SKUEquivalentMap != null)
            {
                SKU_Effort_Map_Entry__c[] SKUEquivalentMapEntries = SKUEquivalentMap.SKU_Effort_Map_Entries__r;

                if(SKUEquivalentMapEntries != null)
                {
                    for ( SKU_Effort_Map_Entry__c  entry : SKUEquivalentMapEntries )
                    {
                        // Get The mapp for this specific order item
            			pse__Project_Task__c existingChildTask = null;

                        for(pse__Project_Task__c ct2 : childTasks)
                        {
                            if(ct2.Name == entry.Name__c && ct2.pse__parent_task__r.Name == entry.Phase__r.Name)
                            {
                                existingChildTask = ct2 ;
                                break;
                            }
                        }

                        if(existingChildTask != null)
                        {
                            double hoursQuantity = existingChildTask.pse__estimated_hours__c - (entry.estimated_hours__c * item.quantity);
                            existingChildTask.pse__estimated_hours__c = hoursQuantity;
                        }
                    }
                }
            }
        }

        update(childTasks);

        pse__Project_Task__c[] childTasksToBeDeleted = new pse__Project_Task__c[]{};

        for(pse__Project_Task__c t : childTasks) {
            Boolean canRemoveTask = true;

            if (hasCustomSvcItems && customSkuEffortMap != null) {
				SKU_Effort_Map_Entry__c[] customSkuEffortMapentries = customSkuEffortMap.SKU_Effort_Map_Entries__r;

                for (SKU_Effort_Map_Entry__c entry : customSkuEffortMapentries) {
                    if (entry.Name__c == t.Name && entry.Phase__r.Name == t.pse__parent_task__r.Name) {
                        canRemoveTask = false;

                        break;
                    }
                }
            }

            if (canRemoveTask && t.pse__Estimated_Hours__c <= 0) {
                childTasksToBeDeleted.add(t);
            }
        }

        Set<Id> taskIdsToDelete = new Set<Id>();
        
        for(pse__Project_Task__c t : childTasksToBeDeleted )  {
            childTasks.remove(childTasks.indexOf(t));
            taskIdsToDelete.add(t.Id);
        }
        
        List<Order_Item_Sku_Effort_Map__c> orderItemSkuEffortMap = [SELECT Id FROM Order_Item_Sku_Effort_Map__c WHERE Project_Task__c IN :taskIdsToDelete];
        
        delete(orderItemSkuEffortMap);
        
        delete(childTasksToBeDeleted);
        
        setPMComplexity(ProjectId);
    }

    // Extract the SKU Effort Mapp Entries from a list of SKU Mapps Effort Mapps
    private SKU_Effort_Map_Entry__c[] getEntriesFromSKUEffortMappList( List<Sku_Effort_Map__c> SKUEffortMappList) {
        SKU_Effort_Map_Entry__c[] result = new SKU_Effort_Map_Entry__c[]{};

        for(Sku_Effort_Map__c mapp : SKUEffortMappList){
             for(SKU_Effort_Map_Entry__c entry : mapp.SKU_Effort_Map_Entries__r)
                 result.add(entry);
        }

        return result;
    }

    private pse__project_task__c GetFirstChildTaskByName(string name , Id parentId , pse__project_task__c[] tasks) {
        for(pse__project_task__c t : tasks) {
            if(t.Name == name && t.pse__Parent_Task__c == parentId) return t;
        }
        return null;
    }

    private pse__project_task__c GetFirstTaskByName(string name, pse__project_task__c[] tasks ) {
        for(pse__project_task__c t : tasks) {
            if(t.Name == name ) return t;
        }

        return null;
    }

    private void RemoveDuplicatedTasks(Id projectId) {
        List<pse__Project_Task__c> tasksToBeRemoved = new List<pse__Project_Task__c>();

        Set<string> duplicatedTaskNames = new Set<string>();
        AggregateResult[] duplicatedTaskNamesAggregate = [SELECT Name FROM pse__Project_Task__c WHERE pse__Project__c = :projectId AND pse__Parent_Task__c = NULL GROUP BY Name, pse__Parent_Task__c HAVING COUNT(Id) > 1];

        for (AggregateResult ar : duplicatedTaskNamesAggregate) {
            duplicatedTaskNames.add((string) ar.get('Name'));
		}

		pse__Project_Task__c[] allTasks = [SELECT Id, Name, pse__Parent_Task__c, (SELECT Id, Name from pse__Immediate_Sub_Tasks__r) FROM pse__Project_Task__c WHERE pse__Project__c = :projectId];

        for (pse__Project_Task__c task : allTasks) {
            if (duplicatedTaskNames.Contains(task.Name) && task.pse__Immediate_Sub_Tasks__r.isEmpty()) {
            	tasksToBeRemoved.add(task);
            }
        }

        delete(tasksToBeRemoved);
    }

    private List<String> getProjectComplexityTierValuesIntoList() {
       	List<String> pickListValuesList= new List<String>();
       	Schema.DescribeFieldResult fieldResult = Sku_Effort_Map_Entry__c.Project_Complexity_Tier__c.getDescribe();

      	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       	for(Schema.PicklistEntry pickListVal : ple){
           pickListValuesList.add(pickListVal.getLabel());
       	}
       	return pickListValuesList;
    }

    private List<Id> getOrdersIdFromProject(Id ProjectId)
    {
        Order[] ordersFromProject = [select Id from order Where project__c = :ProjectId];
        List<Id> orderIds = new List<Id>();
        for (Order item : ordersFromProject)
            orderIds.add(item.Id);
        return orderIds;
    }

    private List<String> GetSKUsFromOrders(List<Id> orderIds)
    {
        OrderItem[] items = [
            SELECT
              Id,
              OrderId,
              Quantity,
              SKU_Number__c
            FROM OrderItem
            WHERE OrderId in :orderIds
            AND Order.Status != :'CL'];

        // Get the SKUs from order Items
        Set<String> SKUs = new Set<String>();
        for (OrderItem item : items)
            SKUs.add(item.SKU_Number__c);
        List<string> result = new List<String>();
        result.addAll(SKUs);

        return result;
    }

    private List<SKU_Effort_Map_Entry__c> getEntriesFromSKUS(List<string> SKUs)
    {
        Sku_Effort_Map__c[] mapps =
        [
            SELECT Id , Name, SKU_Number__c,
        		(SELECT Name__c, Project__c, Phase__r.Name, Role__c, SKU_Effort_Map__c, Estimated_Hours__c, Project_Complexity_Tier__c FROM SKU_Effort_Map_Entries__r)  // HERE WE CAN FILTER BY TEMPLATE ID IN THE FUTURE
        	FROM Sku_Effort_Map__c
            WHERE
            	SKU_Number__c IN :SKUs and
            	active__c = true
        ];
        return getEntriesFromSKUEffortMappList(mapps);

    }

    private String getMaxPMComplexity(Id ProjectId)
    {
        List<Id> orders = getOrdersIdFromProject(ProjectId);
        List<String> SKUs = GetSKUsFromOrders(orders);
        List<SKU_Effort_Map_Entry__c> entries = getEntriesFromSKUS(SKUs);
        Integer maxPMComplexity = 0;
        List<String> pickListValues = getProjectComplexityTierValuesIntoList();
        for(SKU_Effort_Map_Entry__c entry:entries)
        {
            if(maxPMComplexity < pickListValues.indexOf(entry.Project_Complexity_Tier__c))
                maxPMComplexity = pickListValues.indexOf(entry.Project_Complexity_Tier__c);
        }
        return pickListValues[maxPMComplexity];
    }

    private void setPMComplexity(Id projectId)
    {
        pse__Proj__c project = [SELECT PM_Complexity__c FROM pse__Proj__c WHERE Id = :ProjectId LIMIT 1];
        project.PM_Complexity__c = getMaxPMComplexity(projectId);
        update project;
    }

    private void setProjectType(Id projectId)
    {
        pse__Proj__c project = [SELECT pse__Project_Type__c FROM pse__Proj__c WHERE Id = :ProjectId LIMIT 1];
        project.pse__Project_Type__c = 'Custom';
        update project;
    }

    private List<Skill_SKU_Effort_Map_Entry__c> getSkillsBySkuEffortMapEntries(SKU_Effort_Map_Entry__c[] skuEffortMapEntries) {
        Set<Id> ids = new Set<Id>();

        for (SKU_Effort_Map_Entry__c entry : skuEffortMapEntries) {
            ids.add(entry.id);
        }

        List<Skill_SKU_Effort_Map_Entry__c> skills = [
            SELECT SKU_Effort_Map_Entry__c, Skill_Certification__c
            FROM Skill_SKU_Effort_Map_Entry__c
            WHERE SKU_Effort_Map_Entry__c IN :ids
        ];

        return skills;
    }

    private List<Project_Task_Skill__c> addProjectTaskSkillsBySkuEffortMapEntryId(Id projectTaskId, Id skuEffortMapEntryId, List<Project_Task_Skill__c> existingProjectTaskSkills, List<Skill_SKU_Effort_Map_Entry__c> skills) {
        List<Project_Task_Skill__c> newProjectTaskSkills = new List<Project_Task_Skill__c>();

        for (Skill_SKU_Effort_Map_Entry__c skill : skills) {
            if (skill.SKU_Effort_Map_Entry__c == skuEffortMapEntryId) {
                Boolean exists = false;

                for (Project_Task_Skill__c projectTaskSkill : existingProjectTaskSkills) {
                    if (projectTaskSkill.Project_Task__c == projectTaskId && projectTaskSkill.Skill_Certification__c == skill.Skill_Certification__c) {
                        exists = true;
                        break;
                    }
                }

                if (!exists) {
                    Project_Task_Skill__c newProjectTaskSkill = new Project_Task_Skill__c(
                        Project_Task__c = projectTaskId,
                        Skill_Certification__c = skill.Skill_Certification__c
                    );

                    newProjectTaskSkills.add(newProjectTaskSkill);
                }
            }
        }

        return newProjectTaskSkills;
    }

    private List<Project_Task_Skill__c> getExistingProjectTaskSkills(pse__Project_Task__c[] childTasks) {
 		Set<Id> childTaskIds = new Set<Id>();

        for (pse__Project_Task__c task : childTasks) {
            childTaskIds.add(task.id);
        }

        List<Project_Task_Skill__c> projectTaskSkills = [SELECT Project_Task__c, Skill_Certification__c FROM Project_Task_Skill__c WHERE Project_Task__c IN :childTaskIds];

        return projectTaskSkills;
    }

    private Set<Id> getCustomSvcItems(OrderItem[] items, Sku_Effort_Map__c[] mapps, Id practiceId) {
        Set<Id> customSvcItems = new Set<Id>();

        if (items.size() > 0) {
            Item_Class__c[] itemClasses = [SELECT Id, Item_Class_Description__c FROM Item_Class__c WHERE Practice__c = :practiceId AND Key_Practice__c = true];

            for (OrderItem item : items) {
                Boolean found = false;

                for (Sku_Effort_Map__c skuEffortMap : mapps) {
                    if (item.SKU_Number__c == skuEffortMap.SKU_Number__c) {
                        found = true;
                        break;
                    }
                }

                if (!found) {
                    for (Item_Class__c itemClass : itemClasses) {
                        if (String.isNotBlank(item.Item_Class_Description__c) && String.isNotBlank(itemClass.Item_Class_Description__c) && item.Item_Class_Description__c.equalsIgnoreCase(itemClass.Item_Class_Description__c)) {
                            customSvcItems.add(item.Id);
                            break;
                        }
                    }
                }
            }
        }
        return customSvcItems;
    }

    private Boolean hasCustomSvcItems(Id projectId, Id excludedOrderId, Id practiceId) {
        Boolean hasCustomSvcItems = false;

		Item_Class__c[] itemClasses = [SELECT Id, Item_Class_Description__c FROM Item_Class__c WHERE Practice__c = :practiceId AND Key_Practice__c = true];
        AggregateResult[] orderItems = [SELECT SKU_Number__c, Item_Class_Description__c FROM OrderItem WHERE Order.Project__c = :projectId AND OrderId != :excludedOrderId GROUP BY Item_Class_Description__c, SKU_Number__c];

        Set<String> skus = new Set<String>();
        
		for (AggregateResult orderItem : orderItems) {
			String skuNumber = (String)orderItem.get('SKU_Number__c');
            skus.add(skuNumber);
        }
        
        Sku_Effort_Map__c[] mapps = [SELECT Id , Name, SKU_Number__c FROM Sku_Effort_Map__c WHERE SKU_Number__c IN :skus AND Active__c = true];

        for (AggregateResult item : orderItems) {
            Boolean found = false;
            
            String skuNumber = (String)item.get('SKU_Number__c');
            String itemClassDescription = (String)item.get('Item_Class_Description__c');
            
            for (Sku_Effort_Map__c skuEffortMap : mapps) {
                if (skuNumber == skuEffortMap.SKU_Number__c) {
                    found = true;
                    break;
                }
            }
            
            if (!found) {
                for (Item_Class__c itemClass : itemClasses) {
                    if (String.isNotBlank(itemClassDescription) && String.isNotBlank(itemClass.Item_Class_Description__c) && itemClassDescription.equalsIgnoreCase(itemClass.Item_Class_Description__c)) {
                        hasCustomSvcItems = true;
                        break;
                    }
                }
            }
            
            if (hasCustomSvcItems) {
                break;
            }
        }

        return hasCustomSvcItems;
    }

    private Sku_Effort_Map__c getCustomSkuEffortMap(Id practiceId) {
        Sku_Effort_Map__c customSkuEffortMap = null;
        
        Sku_Effort_Map__c[] skuEffortMaps = [
            SELECT Id, 
                   Name, 
                   SKU_Number__c,
                   Description__c,
                   (SELECT Name__c, Project__c, Phase__r.Name, Role__c, SKU_Effort_Map__c, Estimated_Hours__c, toLabel(Project_Complexity_Tier__c) FROM SKU_Effort_Map_Entries__r)
            FROM Sku_Effort_Map__c 
            WHERE SKU_Number__c = :CUSTOM_SKU_NUMBER
              AND Active__c = true
              AND Practice__c = :practiceId
        ];

        if (skuEffortMaps.size() == 1) {
            customSkuEffortMap = skuEffortMaps[0];
        }

        return customSkuEffortMap;
	}
}