@isTest
private class SKUEffortMappingTest {

    @isTest 
    static void Should_CreateProjectTaskBySkuEffortMap() {
        
        // Arrange 
        
            //create Project
            string taskName = 'Planning';
            pse__Proj__c project = SKUEffortMappingTestDataFactory.createProjectWithTask(taskName);
        
            //create Effort Map Entry
            decimal orderItemQtd = 1;
        	OrderItem orderItem = SKUEffortMappingTestDataFactory.createOrderAndOrderItems(orderItemQtd);
        
        	decimal estimatedHours = 4;
            SKU_Effort_Map_Entry__c effortMapEntry = SKUEffortMappingTestDataFactory.createEffortMapEntry('Planning','Configuration', estimatedHours, true);
        
        // Act
        
        	SKUEffortAutomator skuEffortAutomator = new SKUEffortAutomator();
        	skuEffortAutomator.ManageTasksCreation(orderItem.OrderId, project.Id);
        
        // Assert
        
        	Test.startTest();
        
        	string phaseName = [SELECT Name From pse__Project_Task__c WHERE Id = :effortMapEntry.Phase__c LIMIT 1].Name;        
        	pse__Project_Task__c parentTask = [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND Name = :phaseName LIMIT 1];                
        	pse__Project_Task__c taskCreated = [SELECT Id, Name, pse__Estimated_Hours__c FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND pse__Parent_Task__c = :parentTask.Id LIMIT 1];

            System.assertEquals(taskCreated.Name, effortMapEntry.Name__c);
            System.assertEquals(taskCreated.pse__Estimated_Hours__c, effortMapEntry.Estimated_Hours__c);
        
        	Test.stopTest();
    }
    
    @isTest 
    static void Should_CreateProjectTaskBySkuEffortMap_With_EffortMultiplyingBySKUQty() {
        
        // Arrange
        
            //create Project
            string taskName = 'Planning';
            pse__Proj__c project = SKUEffortMappingTestDataFactory.createProjectWithTask(taskName);
        
            //create Effort Map Entry
            decimal orderItemQtd = 2;
        	OrderItem orderItem = SKUEffortMappingTestDataFactory.createOrderAndOrderItems(orderItemQtd);
        
        	decimal estimatedHours = 4;
            SKU_Effort_Map_Entry__c effortMapEntry = SKUEffortMappingTestDataFactory.createEffortMapEntry('Planning','Configuration', estimatedHours, true);
        
        // Act
        	SKUEffortAutomator skuEffortAutomator = new SKUEffortAutomator();
        	skuEffortAutomator.ManageTasksCreation(orderItem.OrderId, project.Id);
        
        // Assert 
        
            Test.startTest();
            
            string phaseName = [SELECT Name From pse__Project_Task__c WHERE Id = :effortMapEntry.Phase__c LIMIT 1].Name;        
            pse__Project_Task__c parentTask = [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND Name = :phaseName LIMIT 1];                
            pse__Project_Task__c taskCreated = [SELECT Id, Name, pse__Estimated_Hours__c FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND pse__Parent_Task__c = :parentTask.Id LIMIT 1];
    
            System.assertEquals(taskCreated.Name, effortMapEntry.Name__c);
            System.assertEquals(taskCreated.pse__Estimated_Hours__c, (effortMapEntry.Estimated_Hours__c * orderItemQtd));
            
            Test.stopTest();
    }
   /* @isTest
    static void Should_CreateProjectWithCustomSKU(){


        //create Project
        string taskName = 'Planning';

        //create Effort Map Entry
        decimal orderItemQtd = 2;
        List<OrderItem> orderItem = SKUEffortMappingTestDataFactory.createCustomOrderAndOrderItems(orderItemQtd);
        pse__Proj__c project = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Project'];
        decimal estimatedHours = 4;

        SKU_Effort_Map_Entry__c effortMapEntry = SKUEffortMappingTestDataFactory.createEffortMapEntryCustom('Planning','Configuration', estimatedHours, true);
        // Act
        SKUEffortAutomator skuEffortAutomator = new SKUEffortAutomator();
        skuEffortAutomator.ManageTasksCreation(orderItem[0].OrderId, project.Id);
        skuEffortAutomator.ManageTasksCreation(orderItem[1].OrderId, project.Id);
        skuEffortAutomator.ManageTasksRemoval(orderItem[0].OrderId, project.Id);

        string phaseName = [SELECT Name From pse__Project_Task__c WHERE Id = :effortMapEntry.Phase__c LIMIT 1].Name;
        pse__Project_Task__c parentTask = [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND Name = :phaseName LIMIT 1];
        pse__Project_Task__c taskCreated = [SELECT Id, Name, pse__Estimated_Hours__c FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND pse__Parent_Task__c = :parentTask.Id LIMIT 1];

        System.assertEquals(taskCreated.Name, effortMapEntry.Name__c,'Correct Assert');
    }*/
    
    @isTest 
    static void Should_CreateProjectTaskWithSubtaskBySkuEffortMap() {
        
        // Arrange
         
        	//create Project
            string taskName = 'Planning';
        	string subTaskName = 'Configuration';
        	decimal subTaskEstimatedhours = 4;
            pse__Proj__c project = SKUEffortMappingTestDataFactory.createProjectWithTaskAndSubTask(taskName, subTaskName, subTaskEstimatedhours);
        
            //create Effort Map Entry
            decimal orderItemQtd = 1;
        	OrderItem orderItem = SKUEffortMappingTestDataFactory.createOrderAndOrderItems(orderItemQtd);
        
        	decimal estimatedHours = 4;
            SKU_Effort_Map_Entry__c effortMapEntry = SKUEffortMappingTestDataFactory.createEffortMapEntry(taskName, subTaskName, estimatedHours, true);
             
        // Act
        	SKUEffortAutomator skuEffortAutomator = new SKUEffortAutomator();
        	skuEffortAutomator.ManageTasksCreation(orderItem.OrderId, project.Id);
        
        // Assert
       
            Test.startTest();
            
            string phaseName = [SELECT Name From pse__Project_Task__c WHERE Id = :effortMapEntry.Phase__c LIMIT 1].Name;        
            pse__Project_Task__c parentTask = [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND Name = :phaseName LIMIT 1];                
            pse__Project_Task__c taskCreated = [SELECT Id, Name, pse__Estimated_Hours__c FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND pse__Parent_Task__c = :parentTask.Id LIMIT 1]; 
    
            System.assertEquals(taskCreated.Name, effortMapEntry.Name__c);
            System.assertEquals(taskCreated.pse__Estimated_Hours__c, (effortMapEntry.Estimated_Hours__c + subTaskEstimatedhours));
            
            Test.stopTest();
    }
    
    @isTest 
    static void Should_CreateProjectTaskWithSubtaskBySkuEffortMap_With_EffortMultiplyingBySKUQty() {
        
        // Arrange
         
        	//create Project
            string taskName = 'Planning';
        	string subTaskName = 'Configuration';
        	decimal subTaskEstimatedhours = 4;
            pse__Proj__c project = SKUEffortMappingTestDataFactory.createProjectWithTaskAndSubTask(taskName, subTaskName, subTaskEstimatedhours);
        
            //create Effort Map Entry
            decimal orderItemQtd = 2;
        	OrderItem orderItem = SKUEffortMappingTestDataFactory.createOrderAndOrderItems(orderItemQtd);
        
        	decimal estimatedHours = 4;
            SKU_Effort_Map_Entry__c effortMapEntry = SKUEffortMappingTestDataFactory.createEffortMapEntry(taskName, subTaskName, estimatedHours, true);     
        
        // Act
        	SKUEffortAutomator skuEffortAutomator = new SKUEffortAutomator();
        	skuEffortAutomator.ManageTasksCreation(orderItem.OrderId, project.Id);
        
        // Assert
        
            Test.startTest();
            
            string phaseName = [SELECT Name From pse__Project_Task__c WHERE Id = :effortMapEntry.Phase__c LIMIT 1].Name;        
            pse__Project_Task__c parentTask = [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND Name = :phaseName LIMIT 1];                
            pse__Project_Task__c taskCreated = [SELECT Id, Name, pse__Estimated_Hours__c FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND pse__Parent_Task__c = :parentTask.Id LIMIT 1];
    
            System.assertEquals(taskCreated.Name, effortMapEntry.Name__c);
            System.assertEquals(taskCreated.pse__Estimated_Hours__c, ((effortMapEntry.Estimated_Hours__c * orderItemQtd) + subTaskEstimatedhours));
            
            Test.stopTest();
    }
    
    @isTest 
    static void Should_CreateProjectTaskBySkuEffortMap_When_ParentTaksDoesNotExist() {
        
        // Arrange
        
            //create Project without task
            pse__Proj__c project = new pse__Proj__c(Name='Test Project', Project_Visibility__c='All', pse__Is_Active__c = true);
        	insert project;
        
            //create Effort Map Entry
            decimal orderItemQtd = 1;
        	OrderItem orderItem = SKUEffortMappingTestDataFactory.createOrderAndOrderItems(orderItemQtd);
        
        	decimal estimatedHours = 4;
            SKU_Effort_Map_Entry__c effortMapEntry = SKUEffortMappingTestDataFactory.createEffortMapEntry('Planning','Configuration', estimatedHours, true);
        
        // Act
        
        	SKUEffortAutomator skuEffortAutomator = new SKUEffortAutomator();
        	skuEffortAutomator.ManageTasksCreation(orderItem.OrderId, project.Id);
        
        // Assert
        
        	Test.startTest();

        
        	string phaseName = [SELECT Name From pse__Project_Task__c WHERE Id = :effortMapEntry.Phase__c LIMIT 1].Name;        
        	pse__Project_Task__c parentTask = [SELECT Id, Name FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND Name = :phaseName LIMIT 1];                
        	pse__Project_Task__c taskCreated = [SELECT Id, Name, pse__Estimated_Hours__c FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND pse__Parent_Task__c = :parentTask.Id LIMIT 1];

        	System.assert(parentTask != null);
        	System.assertEquals(parentTask.Name, 'Planning');
            System.assertEquals(taskCreated.Name, effortMapEntry.Name__c);
            System.assertEquals(taskCreated.pse__Estimated_Hours__c, effortMapEntry.Estimated_Hours__c);
        
        	Test.stopTest();
    }
    
    @isTest 
    static void Should_Not_CreateProjectTaskBySkuEffortMap_When_SkuEffortMapIsInactive() {
        
        // Arrange
        
            //create Project
            string taskName = 'Planning';
            pse__Proj__c project = SKUEffortMappingTestDataFactory.createProjectWithTask(taskName);
        
            //create Effort Map Entry
            decimal orderItemQtd = 1;
        	OrderItem orderItem = SKUEffortMappingTestDataFactory.createOrderAndOrderItems(orderItemQtd);
        
        	decimal estimatedHours = 4;
            SKU_Effort_Map_Entry__c effortMapEntry = SKUEffortMappingTestDataFactory.createEffortMapEntry('Planning','Configuration', estimatedHours, false);
        
        // Act
        
        	SKUEffortAutomator skuEffortAutomator = new SKUEffortAutomator();
        	skuEffortAutomator.ManageTasksCreation(orderItem.OrderId, project.Id);
        
        // Assert
        
        	Test.startTest();
        
        	string phaseName = [SELECT Name From pse__Project_Task__c WHERE Id = :effortMapEntry.Phase__c LIMIT 1].Name;        
        	pse__Project_Task__c parentTask = [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND Name = :phaseName LIMIT 1];                
        	List<pse__Project_Task__c> tasksCreated = [SELECT Id, Name, pse__Estimated_Hours__c FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND pse__Parent_Task__c = :parentTask.Id];

            System.assertEquals(tasksCreated.size(), 0);
        
        	Test.stopTest();
    }
    
    @isTest 
    static void Should_RemoveProjectTaskBySkuEffortMap_When_SkuEffortIsZero() {
        
        // Arrange
         
        	//create Project
            string taskName = 'Planning';
        	string subTaskName = 'Configuration';
        	decimal estimatedHours = 4;
            pse__Proj__c project = SKUEffortMappingTestDataFactory.createProjectWithTaskAndSubTask(taskName, subTaskName, estimatedHours);
        
            //create Effort Map Entry
            decimal orderItemQtd = 1;
        	OrderItem orderItem = SKUEffortMappingTestDataFactory.createOrderAndOrderItems(orderItemQtd);
        
        	
            SKU_Effort_Map_Entry__c effortMapEntry = SKUEffortMappingTestDataFactory.createEffortMapEntry(taskName, subTaskName, estimatedHours, true);
             
        // Act
        	SKUEffortAutomator skuEffortAutomator = new SKUEffortAutomator();
        	skuEffortAutomator.ManageTasksRemoval(orderItem.OrderId, project.Id);
        
        // Assert
       
            Test.startTest();
            
            string phaseName = [SELECT Name From pse__Project_Task__c WHERE Id = :effortMapEntry.Phase__c LIMIT 1].Name;        
            pse__Project_Task__c parentTask = [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND Name = :phaseName LIMIT 1];                
            List<pse__Project_Task__c> tasksCreated = [SELECT Id, Name, pse__Estimated_Hours__c FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND pse__Parent_Task__c = :parentTask.Id]; 
    
            System.assert(tasksCreated.isEmpty());
            
            Test.stopTest();
    }
    
    @isTest 
    static void Should_ReduceTheEffortHoursFromTask_When_SkuEffortMapAreLessThanTaskHours() {
        
        // Arrange
         
        	//create Project
            string taskName = 'Planning';
        	string subTaskName = 'Configuration';
        	decimal subTaskEstimatedHours = 6;
            pse__Proj__c project = SKUEffortMappingTestDataFactory.createProjectWithTaskAndSubTask(taskName, subTaskName, subTaskEstimatedHours);
        
            //create Effort Map Entry
            decimal orderItemQtd = 1;
        	OrderItem orderItem = SKUEffortMappingTestDataFactory.createOrderAndOrderItems(orderItemQtd);
        
        	decimal estimatedHours = 4;
            SKU_Effort_Map_Entry__c effortMapEntry = SKUEffortMappingTestDataFactory.createEffortMapEntry(taskName, subTaskName, estimatedHours, true);
             
        // Act
        	SKUEffortAutomator skuEffortAutomator = new SKUEffortAutomator();
        	skuEffortAutomator.ManageTasksRemoval(orderItem.OrderId, project.Id);
        
        // Assert
       
            Test.startTest();
            
            string phaseName = [SELECT Name From pse__Project_Task__c WHERE Id = :effortMapEntry.Phase__c LIMIT 1].Name;        
            pse__Project_Task__c parentTask = [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND Name = :phaseName LIMIT 1];                
            List<pse__Project_Task__c> tasksCreated = [SELECT Id, Name, pse__Estimated_Hours__c FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id AND pse__Parent_Task__c = :parentTask.Id]; 
			pse__Project_Task__c taskCreated = tasksCreated.get(0);
         
            System.assertEquals(taskCreated.Name, effortMapEntry.Name__c);
            System.assertEquals(taskCreated.pse__Estimated_Hours__c, 2);
            
            Test.stopTest();
    }
}