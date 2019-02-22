public with sharing class SiteManager {
    private static Site__c GetExistingSite(String street, String postalCode, List<Site__c> sites) {
        for (Site__c site : sites) {
            if (site.Address_1__c == street && site.Postal_Code__c == postalCode) {
                return site;
            }
        }

        return null;
    }

    private static Boolean ProjectSiteExists(List<Project_Site__c> projectSites, Id siteId, String addressType) {
        for (Project_Site__c projectSite : projectSites) {
            if (projectSite.Site__C == siteId && projectSite.Address_Type__c == addressType) {
                return true;
            }
        }

        return false;
    }
    
    private static void CreateAndAssociateSite(Id orderId, Id accountId, Id projectId, Id contactId, String contactType) {
        Contact contact = [SELECT MailingStreet,
                                  MailingPostalCode,
                                  MailingCountry,
                                  MailingCity,
                       		      MailingState,
                       		      Mailing_State__c
                             FROM Contact
                            WHERE Id = :contactId];
        
        List<Site__c> dellSites = [SELECT Address_1__c, 
                                               Postal_Code__c,
                                        	   Name
                                          FROM site__c 
                                         WHERE Account__c = :accountId];

        List<Project_Site__c> projectSites = [SELECT Site__C, Address_Type__c FROM Project_Site__c WHERE Project__c = :projectId];

        Site__c site = GetExistingSite(contact.MailingStreet, contact.MailingPostalCode, dellSites);

        if (site != null) {
            if (!ProjectSiteExists(projectSites, site.Id, contactType)) {
                Project_Site__c projectSite = new Project_Site__c (
                    Address_Type__c = contactType,
                    Site__c = site.Id,
                    Project__c = projectId,
                    Name = site.Name
                );
                
                insert projectSite;
            }
        }
        else {
            Site__c newSite = new Site__C (
                Address_1__c = contact.MailingStreet,
                City__c = contact.MailingCity,
                Country__c = contact.MailingCountry,
                Postal_Code__c = contact.MailingPostalCode,
                State__c =  contact.Mailing_State__c,
                Status__c = 'Active',
                Account__c = accountId
            );

            if (contact.MailingCity != null){
                newSite.Name = contact.Mailing_State__c+'_'+contact.MailingCity;
			}
            else{
                newSite.Name = contact.Mailing_State__c;
			}

            
            if (String.isNotBlank(newSite.Name)) {
                newSite.Name += ' Site';
            }
            
            insert newSite;
            
            Project_Site__c projectSite = new Project_Site__c (
                Address_Type__c = contactType,
                Site__c = newSite.Id,
                Project__c = projectId,
                Name = newSite.Name
            );
            
            insert projectSite;
        }
    }

    @InvocableMethod(label = 'Create and associate Sites to Order Account and Order Project')
    public static void CreateAndAssociateOrderSites(List<Id> orderIds) {
        List<Order> orders = [SELECT Sold_to_Contact__c,
                              		 ShipToContactId,
                              		 BillToContactId,
                              		 Direct_Contact__c,
                                    Install_At_Account__c,
                                    Install_At_Contact__c,
                              		 AccountId,
                              		 Project__c
                         	    FROM Order 
                        	   WHERE Id IN :orderIds];
        
        for (Order order : orders) {
            if (order.Sold_to_Contact__c != null) {
                CreateAndAssociateSite(order.Id, order.accountId, order.Project__c, order.Sold_to_Contact__c, 'Sold to');
            }
            
            if (order.ShipToContactId != null) {
                CreateAndAssociateSite(order.Id, order.accountId, order.Project__c, order.ShipToContactId, 'Shipping');
            }
            
            if (order.BillToContactId != null) {
                CreateAndAssociateSite(order.Id, order.accountId, order.Project__c, order.BillToContactId, 'Billing');
            }
            
            if (order.Direct_Contact__c != null) {
                CreateAndAssociateSite(order.Id, order.accountId, order.Project__c, order.Direct_Contact__c, 'Direct');
            }
            if (order.Install_At_Contact__c != null) {
                CreateAndAssociateSite(order.Id, order.accountId, order.Project__c, order.Install_At_Contact__c, 'Install At Contact');
            }
        }
    }
}