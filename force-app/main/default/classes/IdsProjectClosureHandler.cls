public class IdsProjectClosureHandler {
    
    private class OrderSupportInfo {
        public Boolean HasThirtyDaySupport { get; set; }
        public Order Order { get; set; }
    }
    
    public static void handleClosure(Map<Id, pse__Proj__c> oldProjsMap, Map<Id, pse__Proj__c> newProjsMap) {
        Map<Id, pse__Proj__c> projects = getPhaseChangedProjects(oldProjsMap, newProjsMap);
        
        if (projects.size() > 0) {
			Map<Id, List<OrderSupportInfo>> projectOrdersInfo = getOrdersSupportInfo(projects.keySet());
			
            for (pse__Proj__c proj : projects.values()) {
                List<OrderSupportInfo> ordersInfo = projectOrdersInfo.get(proj.Id);
                
                if (hasThirtyDaySupport(ordersInfo)) {
                    pse__Proj__c oldProj = oldProjsMap.get(proj.Id);
                    setProjectToOnHold(proj);
                    notifyProjectOwner(proj);
                }
            }
        }
    }
    
    public static void handleMilestones(Map<Id, pse__Proj__c> oldProjsMap, Map<Id, pse__Proj__c> newProjsMap){
        Map<Id, pse__Proj__c> projects = getPhaseChangedProjects(oldProjsMap, newProjsMap);
        if (projects.size() > 0) {
            Map<Id, List<OrderSupportInfo>> projectOrdersInfo = getOrdersSupportInfo(projects.keySet());
        	system.debug('IdsProjectClosureHandler - CHEGOU AQUI 1');
			updateMilestones(projects);
            system.debug('IdsProjectClosureHandler - CHEGOU AQUI 3');
            Map<Id, pse__Milestone__c> thirtyDaySupportMilestones = createThirtyDaySupportMilestones(projectOrdersInfo);
			associateThirtyDayMilestoneToOrders(projectOrdersInfo, thirtyDaySupportMilestones);
        }
    }
    
    private static Boolean hasThirtyDaySupport(List<OrderSupportInfo> ordersInfo) {
        Boolean hasThirtyDaySupport = false;
        
        if (ordersInfo != null) {            
            for (OrderSupportInfo orderSupportInfo : ordersInfo) {
                if (orderSupportInfo.HasThirtyDaySupport) {
                    hasThirtyDaySupport = true;
                    break;
                }
            }
        }
        
        return hasThirtyDaySupport;
    }
    
    private static Map<Id, pse__Proj__c> getPhaseChangedProjects(Map<Id, pse__Proj__c> oldProjs, Map<Id, pse__Proj__c> newProjs) {
        Map<Id, pse__Proj__c> projs = new Map<Id, pse__Proj__c>();

        for (pse__Proj__c oldProj : oldProjs.values()) {
            for (pse__Proj__c newProj : newProjs.values()) {
                if (oldProj.Id == newProj.Id && validatePhaseChange(oldProj.pse__Project_Phase__c, newProj.pse__Project_Phase__c) && validateStage(oldProj.pse__Stage__c)) {
                	projs.put(newProj.Id, newProj);
                }
            }
        }

        return projs;
    }
    
    private static Boolean validatePhaseChange(String oldPhase, String newPhase) {
        if (oldPhase != newPhase && newPhase == 'Close') {
            return true;
        }
        else {
            return false;
        }
    }
    
    private static Boolean validateStage(String stage) {
        if (stage != 'On Hold') {
            return true;
        }
        else {
            return false;
        }
    }
    
    private static void setProjectToOnHold(pse__Proj__c project){
        project.pse__Stage__c = 'On Hold';
        project.On_Hold_Reason__c = '30 Day Support';
		project.On_Hold_Date__c = Date.today().addDays(30);
    }
    
    private static void updateMilestones(Map<Id, pse__Proj__c> projects) {
		List<pse__Milestone__c> milestonesToUpdate = new List<pse__Milestone__c>();
            
        List<pse__Milestone__c> milestones = [
        	SELECT Id, Name, pse__Status__c, pse__Project__c
			FROM pse__Milestone__c
			WHERE pse__Project__c IN :projects.keySet()
			  AND (pse__Status__c = null or pse__Status__c in ('Planned', 'Open'))
        ];
         
        for (pse__Proj__c project : projects.values()) {
            for (pse__Milestone__c milestone : milestones) {
                if (project.Id == milestone.pse__Project__c) {
                    if (project.Closure_Reason__c == 'Services Delivered') {
                        milestone.pse__Status__c = 'Approved';
                    }
                    else if (project.Closure_Reason__c == 'Services Not Delivered') {
                        milestone.pse__Status__c = 'Canceled';
                    }
                    
                    milestonesToUpdate.add(milestone);
                }
            }
        }

        if (milestonesToUpdate.size() > 0) {
            system.debug('IdsProjectClosureHandler - CHEGOU AQUI 2 | milestonesToUpdate: ' + milestonesToUpdate);
            update(milestonesToUpdate);
        }
    }
    
    private static Map<Id, pse__Milestone__c> createThirtyDaySupportMilestones(Map<Id, List<OrderSupportInfo>> projectOrdersInfo) {
        Map<Id, pse__Milestone__c> projectMilestones = new Map<Id, pse__Milestone__c>();
            
        for (Id projectId : projectOrdersInfo.keySet()) {
            
            if (hasThirtyDaySupport(projectOrdersInfo.get(projectId))) {
                pse__Milestone__c milestone = new pse__Milestone__c(
                    Name = '30 Day Support',
                    pse__Status__c = 'Open',
                    pse__Target_Date__c = Date.today().addDays(30),
                    pse__Project__c = projectId
                );
                
                projectMilestones.put(projectId, milestone);
            }
        }
        
		if (projectMilestones.size() > 0) {
			insert(projectMilestones.values());
        }
        
        return projectMilestones;
    }
    
    private static void associateThirtyDayMilestoneToOrders(Map<Id, List<OrderSupportInfo>> projectOrdersInfo, Map<Id, pse__Milestone__c> thirtyDaySupportMilestones) {
        List<Order> ordersToUpdate = new List<Order>();
        
        for (Id projectId : projectOrdersInfo.keySet()) {
            List<OrderSupportInfo> ordersInfo = projectOrdersInfo.get(projectId);
            pse__Milestone__c thirtyDaySupportMilestone = thirtyDaySupportMilestones.get(projectId);
            
            for (OrderSupportInfo orderInfo : ordersInfo) {
                if (orderInfo.HasThirtyDaySupport) {
                    orderInfo.Order.Milestone__c = thirtyDaySupportMilestone.Id;
                    
                    ordersToUpdate.add(orderInfo.Order);
                }				                
            }
        }
        
        if (ordersToUpdate.size() > 0) {
            update (ordersToUpdate);
        }
    }
	
    private static void notifyProjectOwner(pse__Proj__c projectOnHold) {
		String projectName= projectOnHold.Name;
		String subjectId = projectOnHold.OwnerId; //TODO: issue when owner is a Group
        
		String textWithMentions = '{' + subjectId + '}, the project "' + projectName + '" has been put on hold for 30 days.';
       
        if (!Test.isRunningTest())
        {
			ConnectApiHelper.postFeedItemWithMentions('internal', projectOnHold.Id, textWithMentions);
        }
	}
    
    private static Map<Id, List<OrderSupportInfo>> getOrdersSupportInfo(Set<Id> projectIds) {
        Map<Id, OrderSupportInfo> ordersInfo = new Map<Id, OrderSupportInfo>();
        Map<Id, List<OrderSupportInfo>> projectOrdersInfo = new Map<Id, List<OrderSupportInfo>>();
        
		List<OrderItem> orderItems = [SELECT Id, SKU_Number__c, Order.Id, Order.Milestone__c FROM OrderItem WHERE Order.project__c IN :projectIds and Order.Status != 'CL'];
               
        Set<String> skus = new Set<String>();
        
        for (OrderItem item : orderItems) {
			skus.add(item.SKU_Number__c); 
        }

		List<Sku_Effort_Map__c> maps = [SELECT Id, Name, SKU_Number__c, X30_Day_Support__c FROM Sku_Effort_Map__c WHERE SKU_Number__c IN :skus AND Active__c = true];
		
        for (Id projectId : projectIds) {
            
            for (OrderItem item : orderItems) {
                for (Sku_Effort_Map__c skuEffortMap : maps) {
                    if (item.SKU_Number__c == skuEffortMap.SKU_Number__c) {
                        OrderSupportInfo orderInfo = ordersInfo.get(item.Order.Id);
                        
                        if (orderInfo == null) {
                            orderInfo = new OrderSupportInfo();
                            
                            orderInfo.HasThirtyDaySupport = skuEffortMap.X30_Day_Support__c;
                            orderInfo.Order = item.Order;
                        
                            ordersInfo.put(orderInfo.Order.Id, orderInfo);
                        }
                        else {
                            orderInfo.HasThirtyDaySupport |= skuEffortMap.X30_Day_Support__c;
                        }
                        
                        break;
                    }
                }
            }
            
            projectOrdersInfo.put(projectId, ordersInfo.values());
            ordersInfo.clear();
        }
        
        return projectOrdersInfo;
    }
}