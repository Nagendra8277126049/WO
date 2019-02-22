/* -----------------------------------------------------------------------------------------------------------------------
Name:       GetOrderLineItems
Description:  Makes OData call to external system and fetches the Order details
                to display this information in Lightning Component - OrderDetails.cmp and OrderLineItems.cmp - Story #4146442 
                & Story #4192504
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
11/17/2017     1.0     Tamojit Dasgupta             Initial Release
11/17/2017     1.1     Sri Harsha Gangi Reddy       Initial Release - Updated Code based on Code Review
-------------------------------------------------------------------------------------------------------------------------- */

public with sharing class GetOrderLineItems {
        
    public with sharing class OrderWrapper {
        @AuraEnabled public string OrderNumber {get;set;}
        @AuraEnabled public String CustomerName {get;set;}
        @AuraEnabled public String InvoiceDate {get;set;}
        @AuraEnabled public String ShipDate {get;set;}
        @AuraEnabled public String OrderStatus {get;set;}
        @AuraEnabled public String CustomerNumber {get; set;}
        @AuraEnabled public String BillToAddress {get;set;}
        @AuraEnabled public String ShipToAddress {get; set;}
        @AuraEnabled public String OrderType {get;set;}
        @AuraEnabled public String CustomerBUID {get;set;}
        @AuraEnabled public String BillCity {get;set;}
        @AuraEnabled public String BillState {get;set;}
        @AuraEnabled public String BillStreetAddress1 {get;set;}
        @AuraEnabled public String BillStreetAddress2 {get;set;}
        @AuraEnabled public String BillStreetAddress3 {get;set;}
        @AuraEnabled public String BillStreetAddress4 {get;set;}
        //@AuraEnabled public String BillCountry {get;set;}
        @AuraEnabled public String BillZipCode {get;set;}  
        //@AuraEnabled public String ShiptoCountry {get;set;}
        @AuraEnabled public String ShiptoCity {get;set;}
        @AuraEnabled public String ShiptoState {get;set;}
        @AuraEnabled public String ShiptoStreetAddress1 {get;set;}
        @AuraEnabled public String ShiptoStreetAddress2 {get;set;}
        @AuraEnabled public String ShiptoStreetAddress3 {get;set;}
        @AuraEnabled public String ShiptoStreetAddress4 {get;set;}
        @AuraEnabled public String ShiptoZipCode {get;set;}   
    }
    
    public with sharing class OrderLineWrapper {
        @AuraEnabled public string serviceTag {get;set;}
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Boolean next {get; set;}
        @AuraEnabled public Boolean previous {get; set;}       
        @AuraEnabled public List<AssetOrderDetailsByTag__x> orderLine {get;set;}
    }
    
    @AuraEnabled
    public Static OrderLineWrapper getItems(String recordID, Decimal PageKey, String PageSize){
        try{
            String assetName ='';
            string lastPage='';
            Integer page = (Integer) PageKey;
            String sInteger = String.valueOf(page);
            
            
            assetName = [SELECT Name FROM Asset WHERE Id=:recordID LIMIT 1].Name;
           
            List<AssetOrderDetailsByTag__x> orderItems = new List<AssetOrderDetailsByTag__x>();
            
            OrderLineWrapper objResp = new OrderLineWrapper();  
            
            
            if (assetName != null) {
                if(!Test.isRunningTest()){            
                    orderItems = [SELECT PartNumber__c, ProductNumber__c, Description__c, PPID__c, CommodityDesc__c, LastPage__c, PageKey__c, PageSize__c, Quantity__c
                              	 FROM AssetOrderDetailsByTag__x WHERE ServiceTagId__c=:assetName AND PageKey__c =:sInteger AND PageSize__c =:PageSize LIMIT 200];
                }
                
                else{
                    orderItems.add(new AssetOrderDetailsByTag__x(PartNumber__c='1234',ProductNumber__c='STAG1234', LastPage__c = 'false',
                                                               Description__c='Monitor LCD 24 inches', PPID__c='11',
                                                               CommodityDesc__c='Monitor',Quantity__c='4'));                    
                        
                    orderItems.add(new AssetOrderDetailsByTag__x(PartNumber__c='2345',ProductNumber__c='STAG789', LastPage__c = 'false',
                                                               Description__c='Desktop Description', PPID__c='10',
                                                               CommodityDesc__c='Desktop',Quantity__c='5'));
                    orderItems.add(new AssetOrderDetailsByTag__x(PartNumber__c='28888',ProductNumber__c='STAG000', LastPage__c = 'true',
                                                               Description__c='Desktop Description', PPID__c='10',
                                                               CommodityDesc__c='Desktop',Quantity__c='0'));
                    
                }
                
                
                if (orderItems.size()>0 ) {
                     
                    lastPage = orderItems[0].LastPage__c;
                    objResp.page = page;
                            
                    if (lastPage!=null && page!=null){
                        if (lastPage.equalsIgnoreCase('false') && page == 1){
                            objResp.next = true;
                            objResp.previous = false;
                        }
                        else if (lastPage.equalsIgnoreCase('true') && page > 1){
                            objResp.next = false;
                            objResp.previous = true;
                        }
                        else if (lastPage.equalsIgnoreCase('false') && page > 1){
                            objResp.next = true;
                            objResp.previous = true;
                        }
                    }
                    
                    objResp.serviceTag = assetName;
                    objResp.orderLine = orderItems;
                }
            }
            
            return objResp;
        }Catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'GetOrderLineItems','getItems','OrderManagement');
            return null;
        }
    }
    
    @AuraEnabled
    public Static OrderWrapper getDetail(String assetRowID){
        try{
            
            String orderNumber = '';
            String orderBuid = '';
            List<Asset> assetDetails = new List<Asset>();
            
            assetDetails = [SELECT Order_Number__c,Order_BUID__c FROM Asset WHERE Id=:assetRowID LIMIT 1];
            
            orderNumber = assetDetails[0].Order_Number__c;
            orderBuid = assetDetails[0].Order_BUID__c;
           
            List<GetOrderDetails__x> orderDet = new List<GetOrderDetails__x>();
            OrderWrapper orders = new OrderWrapper();
            //system.debug('order Number---'+orderNumber+' '+assetDetails);
            if (orderNumber!=null && orderBuid!=null ){
                
                if(!Test.isRunningTest()){
                    orderDet = [SELECT OrderNumber__c, CustomerName__c, InvoiceDate__c, ShipDate__c, OrderStatus__c, ShiptoState__c,
                                CustomerNumber__c, BillToAddress__c, OrderType__c, BillCity__c, BillState__c, BillStreetAddress1__c,
                                BillStreetAddress2__c, BillStreetAddress3__c, BillStreetAddress4__c, BillZipCode__c, ShipToAddress__c, ShiptoCity__c,
                                ShiptoStreetAddress1__c, ShiptoStreetAddress2__c, ShiptoStreetAddress3__c, ShiptoStreetAddress4__c, ShiptoZipCode__c,
                                CustomerBUID__c FROM GetOrderDetails__x WHERE OrderNumber__c= :orderNumber AND BUID__c= :orderBuid LIMIT 1];    
                }
                
                else{
                    orderDet.add(new GetOrderDetails__x(OrderNumber__c = '1234567', BUID__c = '01', CustomerName__c ='Sample customer',
                                InvoiceDate__c='2017/01/01 01:01:01', ShipDate__c='2017/01/01 01:01:01', OrderStatus__c='Active',
                                CustomerNumber__c ='78690', BillToAddress__c ='RoundRock Texas 78664', ShipToAddress__c='Dallas Texas 78994',
                                OrderType__c ='new',CustomerBUID__c ='01', BillCity__c='Houston', BillState__c ='Texas', BillStreetAddress1__c ='Street1',
                                BillStreetAddress2__c = 'Fairborn Drive', BillStreetAddress3__c ='Apt 234', BillStreetAddress4__c =null, BillZipCode__c ='78994', 
                                ShiptoCity__c='Houston', ShiptoStreetAddress1__c ='Street1', ShiptoStreetAddress2__c='Fairborn Drive', 
                                ShiptoStreetAddress3__c = 'Apt 234', ShiptoStreetAddress4__c = null, ShiptoZipCode__c ='78994' ));
                }
            
                orders.OrderNumber = orderDet[0].OrderNumber__c;
                orders.CustomerName = orderDet[0].CustomerName__c;
                orders.OrderStatus = orderDet[0].OrderStatus__c;
                orders.CustomerNumber = orderDet[0].CustomerNumber__c;
                orders.BillToAddress = orderDet[0].BillToAddress__c;
                orders.ShipToAddress = orderDet[0].ShipToAddress__C;
                orders.OrderType = orderDet[0].OrderType__c;
                orders.CustomerBUID = orderDet[0].CustomerBUID__c;
                
                /*Mapping Bill To Address */
                orders.BillCity = orderDet[0].BillCity__c;
                orders.BillState = orderDet[0].BillState__c;
                orders.BillStreetAddress1 = orderDet[0].BillStreetAddress1__c;
                orders.BillStreetAddress2 = orderDet[0].BillStreetAddress2__c;
                orders.BillStreetAddress3 = orderDet[0].BillStreetAddress3__c;
                orders.BillStreetAddress4 = orderDet[0].BillStreetAddress4__c;
				orders.BillZipCode = orderDet[0].BillZipCode__c;
                
                /*Mapping Ship To Address */
                orders.ShiptoCity = orderDet[0].ShiptoCity__c;
                orders.ShiptoState = orderDet[0].ShiptoState__c;
                orders.ShiptoStreetAddress1 = orderDet[0].ShiptoStreetAddress1__c;
                orders.ShiptoStreetAddress2 = orderDet[0].ShiptoStreetAddress2__c;
                orders.ShiptoStreetAddress3 = orderDet[0].ShiptoStreetAddress3__c;
                orders.ShiptoStreetAddress4 = orderDet[0].ShiptoStreetAddress4__c;
       			orders.ShiptoZipCode  = orderDet[0].ShiptoZipCode__c;
                
                // To convert date format from MM-DD-YYYY HH:MM AM/PM to dd-MMM-YYYY (20 JAn 2015)
                if(orderDet[0].InvoiceDate__c!=null){
                    String edDtStr = String.valueOf(orderDet[0].InvoiceDate__c).subString(0,10);
                    orders.InvoiceDate = edDtStr.substring(5,7)+ '/' +edDtStr.substring(8,10)+'/'+edDtStr.substring(0,4);
                }
                
                if(orderDet[0].ShipDate__c!=null){
                    String edDtStr1 = String.valueOf(orderDet[0].ShipDate__c).subString(0,10);
                    orders.ShipDate = edDtStr1.substring(5,7)+ '/' +edDtStr1.substring(8,10)+'/'+edDtStr1.substring(0,4);
                }
            }

            return orders;
            }Catch(exception e){
              ExceptionHandler.logHandledExceptions(e,'GetOrderLineItems','getDetail','OrderManagement');
            return null;    
        }
    }

}