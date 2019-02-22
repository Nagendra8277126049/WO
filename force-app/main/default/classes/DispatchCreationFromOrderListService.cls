public class DispatchCreationFromOrderListService {
    
    @future(callout=true)
    public static void createDeltaDispatch(List<Id> workOrderLineItemIds, Id workOrderId) {
        
        //Get Work Order Data        
        WorkOrder workOrder = [SELECT Project_Task__c, Severity__c, Description, DPSType__c, CallType__c, Partner_Code__c,
                               		Street, City, CountryCode, PostalCode, StateCode, Contact.Email, Contact.FirstName, Contact.LastName, Contact.Phone, Contact.HomePhone 
                               FROM WorkOrder WHERE ID = :workOrderId];
        
        //Get the Project Task Data
        pse__Project_Task__c projectTask = [SELECT pse__Project__c FROM pse__Project_Task__c WHERE ID = :workOrder.Project_Task__c];

        //Get the Project Data
        pse__Proj__c project = [SELECT Id, Name, pse__Account__c FROM pse__Proj__c WHERE ID = :projectTask.pse__Project__c];
        
        // Get Customer
        Account customer = [SELECT Id, AccountNumber, BUID__c FROM Account WHERE Id = :project.pse__Account__c];
 
        //Get Sku from work order
        string skuNumber = '';

        Project_Task_SKU_Effort_Mapping_Entry__c[] project_Task_SKU_Effort_Mapping_Entry = [SELECT Id, SKU_Effort_Mapping_Entry__c FROM Project_Task_SKU_Effort_Mapping_Entry__c WHERE Project_Task__c = :workOrder.Project_Task__c];
        
        if(project_Task_SKU_Effort_Mapping_Entry.size() > 0) {
            SKU_Effort_Map_Entry__c[] sku_effort_map_entry = [SELECT Id, SKU_Effort_Map__c FROM SKU_Effort_Map_Entry__c WHERE Id = :project_Task_SKU_Effort_Mapping_Entry[0].SKU_Effort_Mapping_Entry__c];
            
            if(sku_effort_map_entry.size() > 0) {
                SKU_Effort_Map__c[] sku_effort_map = [SELECT Id, SKU_Number__c FROM SKU_Effort_Map__c WHERE Id = :sku_effort_map_entry[0].SKU_Effort_Map__c];
                
                if(sku_effort_map.size() > 0)
                    skuNumber = sku_effort_map[0].SKU_Number__c + ' Qtd:1';
            }
        }        
        
        List<WorkOrderLineItem> workOrderLineItems = [SELECT Id, AssetId, Status FROM WorkOrderLineItem WHERE Id IN :workOrderLineItemIds];
        
        User[] user = [SELECT CommunityNickname FROM User WHERE Id = :UserInfo.getUserId()];        
        
        List<Dispatch> deltaDispatches = new List<Dispatch>();
        
        // get all assetIds
        List<Id> assetIds = new List<Id>();
        for(WorkOrderLineItem workOrderLineItem : workOrderLineItems) {
            assetIds.add(workOrderLineItem.AssetId);
        }
        
        // get all assets
        List<Asset> assets = [SELECT Id, Name, Customer_Number__c, Customer_BUID__c, Order_Number__c, Order_BUID__c FROM Asset WHERE Id IN :assetIds];
        
        // Get Order
        List<Order> orders = [SELECT Id, OrderNumber__c, BUID__c, AccountId, ShipToContact.FirstName, ShipToContact.LastName, ShipToContact.Email, ShipToContact.Phone, ShipToContact.HomePhone, ShipToContact.MailingStreet, ShipToContact.MailingCity, ShipToContact.MailingState, ShipToContact.MailingCountry, ShipToContact.MailingStateCode, ShipToContact.MailingCountryCode, ShipToContact.MailingPostalCode
                              FROM Order WHERE Project__c = :project.Id];
        
        //Get Custom Metadata Types
        FF_Dispatch_Configuration__mdt[] mapping = [SELECT Type__c, Sub_Type__c FROM FF_Dispatch_Configuration__mdt limit 1];     
    
        for(WorkOrderLineItem workOrderLineItem : workOrderLineItems) {
            for(Asset asset : assets) {
                if (workOrderLineItem.AssetId != asset.Id)
                    continue;
                
                for (Order order : orders) {
                    if (asset.Order_Number__c != order.OrderNumber__c)
                        continue;
                
                    string customerBUID = customer.BUID__c;
                    if (String.isEmpty(customerBUID)) 
                        customerBUID = order.BUID__c;
                
                    // set message values
                    Dispatch dispatch = new Dispatch();             
                    dispatch.SalesforceId = workOrderLineItem.Id;
                    dispatch.ExternalCaseId = null;
                    dispatch.CustomerNumber = customer.AccountNumber;
                    dispatch.CustomerBuid = customerBUID;
                    dispatch.OrderNumber = order.OrderNumber__c;
                    dispatch.OrderBuid = order.BUID__c;
                    dispatch.ServiceTag = asset.Name;
                    dispatch.Severity = workOrder.Severity__c;
                    dispatch.Title = project.Name + ' - ' + order.OrderNumber__c; 
                    dispatch.ProjectId = project.Id;
                    
                    if (user.size() > 0)
                        dispatch.ProjectManager = user[0].CommunityNickname;
                    
                    Interaction interaction = new Interaction();
                    interaction.Notes = workOrder.Description;
                    interaction.Priority = '3-Medium';
                    interaction.DPSType = workOrder.DPSType__c;
                    interaction.DSP = workOrder.Partner_Code__c; 
                    interaction.ServiceHours = '10x5';
                    interaction.CallType = workOrder.CallType__c;      
                    interaction.SKU = skuNumber; // SKU Number + 'Qtd:1';                
                    interaction.Type = mapping[0].Type__c; 
                    interaction.SubType = mapping[0].Sub_Type__c;
                    interaction.LOB = ''; // Marchetti is looking it                    
                    
                    DispatchContact dispatchContact = new DispatchContact();   
                    
                    dispatchContact.AddressLine1 = workOrder.Street;
                    dispatchContact.City = workOrder.City;
                    dispatchContact.Country = workOrder.CountryCode;
                    dispatchContact.ZipCode = workOrder.PostalCode;
                    dispatchContact.State = workOrder.StateCode;
                    dispatchContact.Email = workOrder.Contact.Email;
                    dispatchContact.FirstName = workOrder.Contact.FirstName;
                    dispatchContact.LastName = workOrder.Contact.LastName;
                    dispatchContact.HomePhone = workOrder.Contact.Phone;
                    dispatchContact.AlternatePhone = workOrder.Contact.HomePhone;                    
                    
                    interaction.PrimaryContact = dispatchContact;                    
                    
                    dispatch.Interaction = interaction;
                    
                    deltaDispatches.add(dispatch);
                }
            }
        }
        
        callout(JSON.serialize(deltaDispatches));
    }
    
    public static void callout(string jsonMessage) {
        
        // http request
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:ResourceScheduling_Create_Case');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        // Set the body as a JSON object
        request.setBody(jsonMessage);
        
        HttpResponse response = http.send(request);
        
        System.debug('HTTP REQUEST SENT');
        System.debug(jsonMessage);
        
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug(LoggingLevel.Error, '[ResourceScheduling - CreateCase] Error HTTP response code: ' +
                response.getStatusCode() + ' ' + response.getStatus());
            // save it in the database.
        } else {
            // message sent successfully
            System.debug('[ResourceScheduling - CreateCase] - HTTP response code: 200');
        }
    }
    
    // intern classes
    public class Dispatch {
        public string SalesforceId;
        public string ExternalCaseId;
        public string CustomerNumber;
        public string CustomerBuid;
        public string OrderNumber;
        public string OrderBuid;
        public string ServiceTag;
        public string Severity;
        public string Title;
        public string ProjectId;
        public string ProjectManager;
        public Interaction Interaction;
    }
    
    public class Interaction {
        public string Notes;
        public string Priority;
        public string DPSType;
        public string DSP;
        public string ServiceHours;
        public string CallType;      
        public string SKU;
        public DispatchContact PrimaryContact;
        public DispatchContact SecondaryContact;
        public string Type;
        public string SubType;
        public string ProblemDescription;
        public string LOB;
    }
    
    public class DispatchContact {
        public string AddressLine1;
        public string AddressLine2;
        public string AddressLine3;
        public string AddressLine4;
        public string City;
        public string Country;
        public string ZipCode;
        public string State;
        public string Email;
        public string FirstName;
        public string LastName;
        public string HomePhone;
        public string AlternatePhone;
    }
}