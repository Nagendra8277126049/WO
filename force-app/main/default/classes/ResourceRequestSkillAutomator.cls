public class ResourceRequestSkillAutomator {
    public static void UpdateResourceRequestSkills(List<Id> projectIds) {
        List<pse__Proj__c> projects = [SELECT Id, pse__Start_Date__c, pse__End_Date__c, Project_Complexity__c FROM pse__Proj__c WHERE Id IN:projectIds];

        List<pse__Resource_Request__c> resourceRequests = [
                SELECT Id, pse__Start_Date__c, pse__End_Date__c, pse__Staffer_Resource__c, pse__Project__c, pse__Resource_Role__c, pse__Status__c
                FROM pse__Resource_Request__c
                WHERE pse__Project__c IN :projectIds
                AND pse__Resource_Role__c = 'Project Manager'
                AND pse__Staffer_Resource__c = NULL
        ];

        List<Id> resourceRequestIds = new List<Id>();
        for (pse__Resource_Request__c rq : resourceRequests) {
            resourceRequestIds.add(rq.Id);
        }

        pse__Skill__c lowSkill = [SELECT Id, Name FROM pse__Skill__c WHERE Name = 'Project Management (Low)' LIMIT 1];
        pse__Skill__c mediumSkill = [SELECT Id, Name FROM pse__Skill__c WHERE Name = 'Project Management (Medium)' LIMIT 1];
        pse__Skill__c highSkill = [SELECT Id, Name FROM pse__Skill__c WHERE Name = 'Project Management (High)' LIMIT 1];

        List<Id> skillIds = new List<Id>();

        skillIds.add(lowSkill.Id);

        skillIds.add(mediumSkill.Id);
        skillIds.add(highSkill.Id);

        List<pse__Resource_Skill_Request__c> skillRequestToDelete = [
                SELECT Id, pse__Resource_Request__c, pse__Skill_Certification__c, pse__Is_Primary__c, pse__Match_All__c, pse__Minimum_Rating__c
                FROM pse__Resource_Skill_Request__c
                WHERE pse__Resource_Request__c IN :resourceRequestIds
                AND pse__Skill_Certification__c IN :skillIds
        ];

        List<pse__Resource_Skill_Request__c> skillRequestToCreate = new List<pse__Resource_Skill_Request__c>();

        for (pse__Proj__c project : projects) {
            //Get Project PM Resource Request
            for (pse__Resource_Request__c rq : resourceRequests) {
                /*if(rq.pse__Project__c == project.Id && rq.pse__Status__c == 'Assigned'){
                    for(Integer i = 0; i < skillRequestToDelete.size() ; i++){
                        skillRequestToDelete.remove(i);
                    }
                }else */
                if (rq.pse__Project__c == project.Id) {

                    //Update the dates for the resource request
                    rq.pse__Start_Date__c = project.pse__Start_Date__c;
                    rq.pse__End_Date__c = project.pse__End_Date__c;

                    pse__Resource_Skill_Request__c skillRequest;
                    for (pse__Resource_Skill_Request__c sr : skillRequestToDelete) {
                        if (sr.pse__Resource_Request__c == rq.Id) {
                            skillRequest = new pse__Resource_Skill_Request__c();
                            skillRequest.pse__Resource_Request__c = rq.Id;
                            skillRequest.pse__Minimum_Rating__c = sr.pse__Minimum_Rating__c;
                            skillRequest.pse__Is_Primary__c = sr.pse__Is_Primary__c;
                            skillRequest.pse__Match_All__c = sr.pse__Match_All__c;
                            skillRequestToCreate.add(skillRequest);
                        }
                    }

                    if (skillRequest == NULL) {
                        skillRequest = new pse__Resource_Skill_Request__c();
                        skillRequest.pse__Resource_Request__c = rq.Id;
                        skillRequest.pse__Minimum_Rating__c = 'No';
                        skillRequestToCreate.add(skillRequest);
                    }

                    if (rq.pse__Project__c == project.Id) {
                        if (project.Project_Complexity__c == 'Low') {
                            skillRequest.pse__Skill_Certification__c = lowSkill.Id;
                            rq.pse__SOW_Hours__c = 20;
                        } else if (project.Project_Complexity__c == 'Medium') {
                            skillRequest.pse__Skill_Certification__c = mediumSkill.Id;
                            rq.pse__SOW_Hours__c = 30;
                        } else if (project.Project_Complexity__c == 'High') {
                            skillRequest.pse__Skill_Certification__c = highSkill.Id;
                            rq.pse__SOW_Hours__c = 40;
                        }
                    }
                }
            }
        }

        delete(skillRequestToDelete);
        insert(skillRequestToCreate);
        update(resourceRequests);
    }

    @InvocableMethod(label='Add Skills to Resource Request')
    public static void AddSkills(List<Id> addedUpdatedOrders) {
        //RemoveSkuMappingSkills(removedCancelledOrders);

        //AddSkillFromSkuMapping(addedUpdatedOrders);
    }

    public static void UpdateSkillsFromSkuMapping(List<Id> addedUpdatedOrders, List<Id> removedCancelledOrders, List<Id> projectIds) {
        RemoveSkuMappingSkills(removedCancelledOrders, projectIds);

        AddSkillFromSkuMapping(addedUpdatedOrders);
    }

    @future
    private static void AddSkillFromSkuMapping(List<Id> orderIds) {
        //Get All Orders Information
        List<Order> orders = [
                SELECT Id, Project__c
                FROM Order
                WHERE Id IN :orderIds
        ];

        //Get All Order Items
        List<OrderItem> orderItens = [
                SELECT Id, SKU_Number__c
                FROM OrderItem
                WHERE OrderId IN :orderIds
        ];

        List<string> skuNumbers = new List<string>();
        for (OrderItem orderItem : orderItens) {
            skuNumbers.add(orderItem.SKU_Number__c);
        }

        //Get All SKU Effort Maps
        Map<Id, SKU_Effort_Map__c> skus = new Map<Id, SKU_Effort_Map__c>([
                SELECT Id, SKU_Number__c, Active__c
                FROM SKU_Effort_Map__c
                WHERE SKU_Number__c IN :skuNumbers AND Active__c = true
        ]);


        //Get All Sku Effort Mapping Entries
        Map<Id, SKU_Effort_Map_Entry__c> skuEntries = new Map<Id, SKU_Effort_Map_Entry__c>([
                SELECT Id, SKU_Effort_Map__c, Role__c
                FROM SKU_Effort_Map_Entry__c
                WHERE SKU_Effort_Map__c IN:skus.keySet()
                AND Role__c = 'Project Manager'
        ]);


        List<Skill_SKU_Effort_Map_Entry__c> skillEntries = [
                SELECT Id, SKU_Effort_Map_Entry__c, Skill_Certification__c
                FROM Skill_SKU_Effort_Map_Entry__c
                WHERE SKU_Effort_Map_Entry__c IN:skuEntries.keySet()
        ];


        List<Id> projectIds = new List<Id>();
        for (Order order : orders) {
            projectIds.add(order.Project__c);
        }

        //Get All Resource Requests
        Map<Id, pse__Resource_Request__c> resourceRequests = new Map<Id, pse__Resource_Request__c>([
                SELECT Id, pse__Start_Date__c, pse__End_Date__c, pse__Staffer_Resource__c, pse__Project__c, pse__Resource_Role__c
                FROM pse__Resource_Request__c
                WHERE pse__Project__c IN :projectIds
                AND pse__Resource_Role__c = 'Project Manager'
                AND pse__Staffer_Resource__c = NULL
        ]);


        List<pse__Resource_Skill_Request__c> skillRequests = [SELECT Id, pse__Skill_Certification__c FROM pse__Resource_Skill_Request__c WHERE Id IN:resourceRequests.keySet()];
        List<pse__Resource_Skill_Request__c> newSkills = new List<pse__Resource_Skill_Request__c>();
        for (pse__Resource_Request__c request : resourceRequests.values()) {
            for (OrderItem orderItem : orderItens) {
                for (SKU_Effort_Map__c sku : skus.values()) {
                    if (sku.SKU_Number__c != orderItem.SKU_Number__c) {
                        continue;
                    }

                    for (SKU_Effort_Map_Entry__c skuEntry : skuEntries.values()) {
                        if (skuEntry.SKU_Effort_Map__c != sku.Id) {
                            continue;
                        }

                        for (Skill_SKU_Effort_Map_Entry__c skillEntry : skillEntries) {
                            if (skillEntry.SKU_Effort_Map_Entry__c != skuEntry.Id) {
                                continue;
                            }

                            pse__Resource_Skill_Request__c skillRequest;
                            for (pse__Resource_Skill_Request__c sr : skillRequests) {
                                if (sr.pse__Resource_Request__c == request.Id
                                        && sr.pse__Skill_Certification__c == skillEntry.Skill_Certification__c) {
                                    skillRequest = sr;
                                }
                            }

                            if (skillRequest == NULL) {
                                newSkills.add(new pse__Resource_Skill_Request__c(
                                        pse__Resource_Request__c = request.Id,
                                        pse__Minimum_Rating__c = 'No',
                                        pse__Skill_Certification__c = skillEntry.Skill_Certification__c,
                                        pse__Is_Primary__c = false));
                            }
                        }
                    }
                }
            }
        }
        if (!newSkills.isEmpty()) {
            insert(newSkills);
        }
    }

    @future
    private static void RemoveSkuMappingSkills(List<Id> orderIds, List<Id> projectIds) {
        //Get All Orders Information
        List<Order> orders = [
                SELECT Id, Project__c
                FROM Order
                WHERE Id IN :orderIds
        ];


        //Get All Order Items
        List<OrderItem> orderItens = [
                SELECT Id, SKU_Number__c
                FROM OrderItem
                WHERE OrderId IN :orderIds
        ];


        List<string> skuNumbers = new List<string>();
        for (OrderItem orderItem : orderItens) {
            skuNumbers.add(orderItem.SKU_Number__c);
        }

        //Get All SKU Effort Maps
        Map<Id, SKU_Effort_Map__c> skus = new Map<Id, SKU_Effort_Map__c>([
                SELECT Id, SKU_Number__c, Active__c
                FROM SKU_Effort_Map__c
                WHERE SKU_Number__c IN :skuNumbers AND Active__c = true
        ]);


        //Get All Sku Effort Mapping Entries
        Map<Id, SKU_Effort_Map_Entry__c> skuEntries = new Map<Id, SKU_Effort_Map_Entry__c>([
                SELECT Id, SKU_Effort_Map__c, Role__c
                FROM SKU_Effort_Map_Entry__c
                WHERE SKU_Effort_Map__c IN:skus.keySet()
                AND Role__c = 'Project Manager'
        ]);


        List<Skill_SKU_Effort_Map_Entry__c> skillEntries = [
                SELECT Id, SKU_Effort_Map_Entry__c, Skill_Certification__c
                FROM Skill_SKU_Effort_Map_Entry__c
                WHERE SKU_Effort_Map_Entry__c IN:skuEntries.keySet()
        ];


        for (Order order : orders) {
            projectIds.add(order.Project__c);
        }

        //Get All Resource Requests
        Map<Id, pse__Resource_Request__c> resourceRequests = new Map<Id, pse__Resource_Request__c>([
                SELECT Id, pse__Start_Date__c, pse__End_Date__c, pse__Staffer_Resource__c, pse__Project__c, pse__Resource_Role__c
                FROM pse__Resource_Request__c
                WHERE pse__Project__c IN :projectIds
                AND pse__Resource_Role__c = 'Project Manager'
                AND pse__Staffer_Resource__c = NULL
        ]);


        pse__Skill__c lowSkill = [SELECT Id, Name FROM pse__Skill__c WHERE Name = 'Project Management (Low)' LIMIT 1];
        pse__Skill__c mediumSkill = [SELECT Id, Name FROM pse__Skill__c WHERE Name = 'Project Management (Medium)' LIMIT 1];
        pse__Skill__c highSkill = [SELECT Id, Name FROM pse__Skill__c WHERE Name = 'Project Management (High)' LIMIT 1];
        List<Id> skillIds = new List<Id>();
        skillIds.add(lowSkill.Id);
        skillIds.add(mediumSkill.Id);
        skillIds.add(highSkill.Id);

        List<pse__Resource_Skill_Request__c> skillRequests = [
                SELECT Id, pse__Resource_Request__c, pse__Skill_Certification__c
                FROM pse__Resource_Skill_Request__c
                WHERE pse__Resource_Request__c IN:resourceRequests.keySet()
                AND pse__Skill_Certification__c NOT IN:skillIds
        ];


        List<pse__Resource_Skill_Request__c> skillsToDelete = new List<pse__Resource_Skill_Request__c>();

        for (pse__Resource_Request__c request : resourceRequests.values()) {
            for (OrderItem orderItem : orderItens) {
                for (SKU_Effort_Map__c sku : skus.values()) {
                    if (sku.SKU_Number__c != orderItem.SKU_Number__c) {
                        continue;
                    }

                    for (SKU_Effort_Map_Entry__c skuEntry : skuEntries.values()) {
                        if (skuEntry.SKU_Effort_Map__c != sku.Id) {
                            continue;
                        }

                        for (Skill_SKU_Effort_Map_Entry__c skillEntry : skillEntries) {
                            if (skillEntry.SKU_Effort_Map_Entry__c != skuEntry.Id) {
                                continue;
                            }

                            for (pse__Resource_Skill_Request__c sr : skillRequests) {
                                if (sr.pse__Resource_Request__c == request.Id
                                        && sr.pse__Skill_Certification__c == skillEntry.Skill_Certification__c) {
                                    skillsToDelete.add(sr);
                                }
                            }
                        }
                    }
                }
            }
        }
        delete(skillRequests);
    }
}