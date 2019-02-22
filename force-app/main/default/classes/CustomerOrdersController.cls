/* -----------------------------------------------------------------------------------------------------------------------
Name:       CustomerOrdersController
Description:  Makes OData call to external system and fetches the Customer Order Details
            to display this information in Lightning Component - CustomerOrders.cmp - story #4150201
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
12/13/2017     1.0     Sri Harsha Gangi Reddy       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */

public with sharing class CustomerOrdersController {

    /*Wrapper Class*/
    public with sharing class OrderPagerWrapper {
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Boolean next {get; set;}
        @AuraEnabled public Boolean previous {get; set;}
        @AuraEnabled public String serviceResponse {get; set;}
        @AuraEnabled public Boolean serviceCode {get;set;}
        @AuraEnabled public List<CustomerOrderWrapper> custOrder {get;set;}
    }
    /*Wrapper Class*/
    public with sharing class CustomerOrderWrapper{
        @AuraEnabled public  string AssocOrder {get;set;}
        @AuraEnabled public string BUID {get;set;}
        @AuraEnabled public string CustomerNumberBUID {get;set;}
        @AuraEnabled public string CustomerNumber {get;set;}
        @AuraEnabled public string InvoiceDate {get;set;}
        @AuraEnabled public string OrderDate {get;set;}
        @AuraEnabled public string OrderNumber {get;set;} 
        @AuraEnabled public string OrderBuid {get; set;}
    }
    
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Method Name:  getOrders
    Description:  Makes OData call to external system and fetches the Customer Order Details
    ----------------------------------------------------------------------------------------------------------------------------
    Date         Version          Author             Summary of Changes 
    -----------  -------  ------------------------  ------------------------------------------------------------------------------
    12/13/2017     1.0     Sri Harsha Gangi Reddy       Initial Release 
    -------------------------------------------------------------------------------------------------------------------------- */
        
    
    @AuraEnabled
    public static OrderPagerWrapper getOrders(Id recordID, Decimal PageKey, String PageSize){
        try{
            string lastPage='';
            string customerNumber='';
            string customerBuid ='';
            string responseCode = '';
            Integer page = (Integer) PageKey;
            String sInteger = String.valueOf(page);
            List<Account> accDetails = new List<Account>();
            accDetails = [SELECT AccountNumber,BUID__c FROM Account WHERE Id=:recordID LIMIT 1];
            
            customerNumber = accDetails[0].AccountNumber;
            customerBuid = accDetails[0].BUID__c;
            
            List<GetAccountOrderDetails__x> orderDetailsList = new List<GetAccountOrderDetails__x>();
            
            OrderPagerWrapper objOrder =  new OrderPagerWrapper();
            
            List<CustomerOrderWrapper> OrderDetWrapper = new List<CustomerOrderWrapper>();
            
            if (customerNumber !=null && customerBuid !=null){
            
                if(!Test.isRunningTest()){
                    orderDetailsList =[SELECT AssocOrder__c,BUID__c,CustomerNumberBUID__c,CustomerNumber__c,InvoiceDate__c,
                                    LastPage__c,OrderDate__c,OrderNumber__c,ResponseCode__c,ResponseMessage__c, PageKey__c, OrderBuid__c	
                                    FROM GetAccountOrderDetails__x WHERE CustomerNumber__c = :customerNumber AND 
                                    CustomerNumberBUID__c =:customerBuid AND PageKey__c =:sInteger  AND PageSize__c =:PageSize LIMIT 10];
                }
                
                else{
                    
                    orderDetailsList.add(new GetAccountOrderDetails__x( AssocOrder__c='6701234', BUID__c='11', CustomerNumberBUID__c='1234', CustomerNumber__c ='Test Cust', 
                                                                        InvoiceDate__c='2017/01/01 01:01:01', LastPage__c='false', OrderDate__c='2017/01/01 01:01:01', OrderBuid__c	='11',
                                                                        ResponseCode__c='100', ResponseMessage__c='Success',PageKey__c='1', OrderNumber__c='108979'));

                    orderDetailsList.add(new GetAccountOrderDetails__x( AssocOrder__c='67023894', BUID__c='11', CustomerNumberBUID__c='129034', CustomerNumber__c ='Test Cust', 
                                                                        InvoiceDate__c='2017/01/01 01:01:01', LastPage__c='false', OrderDate__c='2018/01/01 01:01:01', OrderBuid__c	='11',
                                                                        ResponseCode__c='100', ResponseMessage__c='Success',PageKey__c='1', OrderNumber__c='10998979'));
                }
            
                responseCode = orderDetailsList[0].ResponseCode__c;
                
                if (responseCode.equals('100')){
                    lastPage = orderDetailsList[0].LastPage__c;
                    objOrder.page = integer.valueof(orderDetailsList[0].PageKey__c);
                    //objOrder.page = page;
                    //obj.custAddress = orderDetailsList;
                    objOrder.serviceCode = true;
                    objOrder.serviceResponse = orderDetailsList[0].ResponseMessage__c;
                    
                    
                    if (lastPage!=null && page!=null){
                        if (lastPage.equalsIgnoreCase('false') && page == 1){
                            objOrder.next = true;
                            objOrder.previous = false;
                        }
                        else if (lastPage.equalsIgnoreCase('true') && page > 1){
                            objOrder.next = false;
                            objOrder.previous = true;
                        }
                        else if (lastPage.equalsIgnoreCase('false') && page > 1){
                            objOrder.next = true;
                            objOrder.previous = true;
                        }
                    }
                    
                    
                    CustomerOrderWrapper customOrder;
                    
                    for(GetAccountOrderDetails__x ord: orderDetailsList){
                    
                        customOrder = new CustomerOrderWrapper();
                        
                        customOrder.AssocOrder = ord.AssocOrder__c;
                        customOrder.BUID = ord.BUID__c;
                        customOrder.CustomerNumberBUID = ord.CustomerNumberBUID__c;
                        customOrder.CustomerNumber = ord.CustomerNumber__c;
                        //customOrder.InvoiceDate = ord.InvoiceDate__c;
                        //customOrder.OrderDate = ord.OrderDate__c;
                        customOrder.OrderNumber = ord.OrderNumber__c;
                        customOrder.OrderBuid = ord.OrderBuid__c;
                        
                        if(ord.InvoiceDate__c!=null){
                            // To convert date format from YYYY-MM-DD HH:MM AM/PM to dd-MMM-YYYY (20 JAn 2015)
                    
                            String edDtStr = String.valueOf(ord.InvoiceDate__c).subString(0,10);
                            /*
                            Datetime dttim = datetime.newInstance(Integer.valueOf(edDtStr.substring(0,4)), 
                                                                  Integer.valueOf(edDtStr.substring(5,7)), 
                                                                  Integer.valueOf(edDtStr.substring(8,10)));
                            customOrder.InvoiceDate = datetime.valueOf(dttim).format('dd-MMM-yyyy');
                            */
                            
                            customOrder.InvoiceDate = edDtStr.substring(5,7)+ '/' +edDtStr.substring(8,10)+'/'+edDtStr.substring(0,4);
                        }
                        
                        if(ord.OrderDate__c!=null){
                            // To convert date format from YYYY-MM-DD HH:MM AM/PM to dd-MMM-YYYY (20 JAn 2015)
     
                            String edDtStr1 = String.valueOf(ord.OrderDate__c).subString(0,10);
                            /*
                            Datetime dttim1 = datetime.newInstance(Integer.valueOf(edDtStr1.substring(0,4)), 
                                                                  Integer.valueOf(edDtStr1.substring(5,7)), 
                                                                  Integer.valueOf(edDtStr1.substring(8,10)));
                            customOrder.OrderDate = datetime.valueOf(dttim1).format('dd-MMM-yyyy');
                            */          
                            customOrder.OrderDate = edDtStr1.substring(5,7)+ '/' +edDtStr1.substring(8,10)+'/'+edDtStr1.substring(0,4);
                        }
                        
                        OrderDetWrapper.add(customOrder);
                    }
                        
                    objOrder.custOrder = OrderDetWrapper;
                   
                }
                else{
                    objOrder.serviceResponse = orderDetailsList[0].ResponseMessage__c;
                    objOrder.serviceCode = false;
                }    
            }
            
            return objOrder;
        }catch(exception e){
           // ExceptionLogger.newExceptionLogger(e.getMessage(), 'CustomerAddressController','getAddress');
           ExceptionHandler.logHandledExceptions(e,'CustomerOrdersController','getOrders','CustomerManagement');
            return null;
        }
    }
}