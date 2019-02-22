/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchManualPartSelection_Test
Description:  This class contain the test method for DispatchManualPartSelection to validate coverage - story #4913343
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
04/07/2018     1.0    Rodrigo Carpio       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
public class DispatchManualPartSelection_Test { 
    
    public static string responseCode;
    @testSetup
    private static void setupTestData() {
     
        //create a test account
        Account acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.Type='Customer';
        acnt.AccountNumber='1234567890';
        acnt.BUID__c='99';
        insert acnt;
        
        //create a test asset
        Asset ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Name='Test Asset';
        ast.UsageEndDate = System.Today();
        insert ast;
        
        //create a test contact
        contact con=SRVS_CreateTestDataFactory.createContactRecord(acnt);
        con.Email = 'testtag@test.com';
        con.firstname = 'firstname';
        con.LastName = 'testtag';   
        con.accountid = acnt.id;
        insert con;
        
        //create a test LiveChatVisitor
        LiveChatVisitor visitor=SRVS_CreateTestDataFactory.createLiveChatVisitor();
        insert visitor;
        
       // create a LiveChatTranscript
        LiveChatTranscript lct=SRVS_CreateTestDataFactory.createLiveChatTranscript(visitor,ast);
        insert lct;
        
        //create a test case
        Case cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse.subject='Test Controller Acct Case';
        cse.Service_Tag__c = 'TESTTAG';
        cse.NonAgentContactEmail__c = 'testtag@test.com';
        cse.NonAgentContactFirstName__c = 'firstname';
        cse.NonAgentContactLastName__c = 'testtag';
        cse.NonAgentContactPhone__c = '800-123-4567';
        cse.TranscriptId__c = lct.Id;
        insert cse;        
        
        //create a test Product
        Product2 prd = new Product2();
        prd.ProductCode = 'AH129';
        prd.Name = 'AH129';
        prd.LOB_Code__c = 'AH129';
        prd.LOB_Description__c = 'AH129';
        prd.Description = 'AH129 TEST Product';
        
        insert prd;
    }
    
    @isTest static void testMethod_validatePartsBooked() {
        Account accRec = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert accRec;
        System.Assert(accRec.id != null);
        
        Contact conRec = SRVS_CreateTestDataFactory.createContactRecord(accRec);
        insert conRec;
        System.Assert(conRec.id != null);
        
        
        Asset assetRec = SRVS_CreateTestDataFactory.createSingleAsset(accRec.Id);
        assetRec.Name= 'ABC123';
        insert assetRec;
        System.Assert(assetRec.id != null);
        
        Case csRec = SRVS_CreateTestDataFactory.createSingleCase(assetRec.id, accRec.id, conRec.id);
        insert csRec;
        System.Assert(csRec.id != null);
        
        WorkOrder dispatchRec = SRVS_CreateTestDataFactory.createSingleWorkOrder(assetRec.id, accRec.id, conRec.id, csRec.id);
        dispatchRec.City = 'Round Rock';
        dispatchRec.StateCode = 'TX';
        dispatchRec.CountryCode = 'US';
        dispatchRec.Street = 'Dell Way';
        dispatchRec.PostalCode = '78556';
        dispatchRec.Dispatch_Country__c = 'Global except LATAM';
        
        insert dispatchRec;     
        System.Assert(dispatchRec.id != null);
                
        WorkOrderLineItem woLineItemRec = new WorkOrderLineItem(WorkOrderId = dispatchRec.id, PartPrice__c = '64.7332',
                                            PartType__c='DIMM', PartCommodity__c= 'MEMORY', Selected_By_user__c= true, AssetId = assetRec.id);
        insert woLineItemRec;
        System.Assert(woLineItemRec.id != null);
        
        woLineItemRec = [select ServiceTag__c, PartNumber__c from WorkOrderLineItem where id =:woLineItemRec.id];
        system.debug('woLineItemRec-------  '+woLineItemRec.ServiceTag__c);
        
        ValidatePartsBooked__x validatedPartsBookedMockRec = new ValidatePartsBooked__x(ResponseCode__c = '200', ResponseMessage__c = 'Test Response',
                              AddressBUID__c = '2020', PartNumber__c = '9159M', OrderQuantity__c = '1', ServiceTag__c = 'BKRBJ72' 
                             , ISOCountryCode__c = 'CH', State__c = 'Ticino', City__c = 'Preonzo', PostalCode__c = '6523' 
                             , Billable__c = 'Y', KYHD__c = 'N', CompleteCare__c = 'N', KoreanMonitorRequest__c = 'N' 
                             , SanbaoFlag__c ='N', Category__c = 'Y', ServiceLevel__c = 'Next Business Day', ServiceHours__c = '8x5' 
                             , SystemClassification__c = 'Notebook', ServiceType__c = 'Parts and Labor' );
        
        //list<DispatchManualPartSelection.ValidatedPartWrapper> ValidatedPartWrapperList = DispatchManualPartSelection.validatePartsBooked(dispatchRec.id, woLineItemRec.id, woLineItemRec.PartNumber__c);
        //system.debug('--------------   '+ValidatedPartWrapperList);
        //System.Assert(ValidatedPartWrapperList.size() == 0);
        
    }
    
    @isTest static void testMethod_getCommodities() {
        Account accRec = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert accRec;
        System.Assert(accRec.id != null);
        
        Contact conRec = SRVS_CreateTestDataFactory.createContactRecord(accRec);
        insert conRec;
        System.Assert(conRec.id != null);
        
        
        Asset assetRec = SRVS_CreateTestDataFactory.createSingleAsset(accRec.Id);
        assetRec.Name= 'ABC123';
        insert assetRec;
        System.Assert(assetRec.id != null);
        
        Case csRec = SRVS_CreateTestDataFactory.createSingleCase(assetRec.id, accRec.id, conRec.id);
        insert csRec;
        System.Assert(csRec.id != null);
        
        WorkOrder dispatchRec = SRVS_CreateTestDataFactory.createSingleWorkOrder(assetRec.id, accRec.id, conRec.id, csRec.id);
        insert dispatchRec;
        System.Assert(dispatchRec.id != null);
        
        WorkOrderLineItem woLineItemRec = new WorkOrderLineItem(WorkOrderId = dispatchRec.id, PartPrice__c = '64.7332',
                                            PartType__c='DIMM', PartCommodity__c= 'MEMORY', Selected_By_user__c= true, AssetId = assetRec.id);
        insert woLineItemRec;
        System.Assert(woLineItemRec.id != null);
        
        woLineItemRec = [select ServiceTag__c, PartNumber__c from WorkOrderLineItem where id =:woLineItemRec.id];
        system.debug('woLineItemRec-------  '+woLineItemRec.ServiceTag__c);
        
        list<DispatchManualPartSelection.ManualCommodityWrapper> manualCommoditiesWrapperList = DispatchManualPartSelection.getCommodities(dispatchRec.id, assetRec.id, woLineItemRec.ServiceTag__c, 'addressBUID');
        
        responseCode = '100';
        manualCommoditiesWrapperList = DispatchManualPartSelection.getCommodities(dispatchRec.id, assetRec.id, 'Test', 'addressBUID');
        
        responseCode = '101';
        manualCommoditiesWrapperList = DispatchManualPartSelection.getCommodities(dispatchRec.id, assetRec.id, 'Test', 'addressBUID');
        
        responseCode = null;
        manualCommoditiesWrapperList = DispatchManualPartSelection.getCommodities(dispatchRec.id, assetRec.id, 'Test', 'addressBUID');
        
    }
    
   /* @isTest static void testMethod_getReplacementParts() {
        Account accRec = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert accRec;
        System.Assert(accRec.id != null);
        
        Contact conRec = SRVS_CreateTestDataFactory.createContactRecord(accRec);
        insert conRec;
        System.Assert(conRec.id != null);
        
        
        Asset assetRec = SRVS_CreateTestDataFactory.createSingleAsset(accRec.Id);
        assetRec.Name= 'ABC123';
        insert assetRec;
        System.Assert(assetRec.id != null);
        
        Case csRec = SRVS_CreateTestDataFactory.createSingleCase(assetRec.id, accRec.id, conRec.id);
        insert csRec;
        System.Assert(csRec.id != null);
        
        WorkOrder dispatchRec = SRVS_CreateTestDataFactory.createSingleWorkOrder(assetRec.id, accRec.id, conRec.id, csRec.id);
        insert dispatchRec;
        System.Assert(dispatchRec.id != null);
        
        WorkOrderLineItem woLineItemRec = new WorkOrderLineItem(WorkOrderId = dispatchRec.id, PartPrice__c = '64.7332',
                                            PartType__c='DIMM', PartCommodity__c= 'MEMORY', Selected_By_user__c= false, AssetId = assetRec.id, Line_Item_Type__c ='MPS', PartNumber__c = 'test123' );
        insert woLineItemRec;
        System.Assert(woLineItemRec.id != null);
        
        woLineItemRec = [select ServiceTag__c, Selected_By_user__c, PartNumber__c, WorkOrderId from WorkOrderLineItem where id =:woLineItemRec.id];
        system.debug('woLineItemRec-------  '+woLineItemRec.ServiceTag__c);
        
        responseCode = '100';
        list<DispatchManualPartSelection.CommodityPartsWrapper> commodityPartsWrapperList = DispatchManualPartSelection.getReplacementParts(dispatchRec.id, assetRec.id, woLineItemRec.ServiceTag__c, 'addressBUID', new list<string>{'test'},'test123');
        commodityPartsWrapperList = DispatchManualPartSelection.getReplacementParts(dispatchRec.id, assetRec.id, woLineItemRec.ServiceTag__c, 'addressBUID', new list<string>{'MEMORY'},'test123');
        commodityPartsWrapperList = DispatchManualPartSelection.getReplacementParts(dispatchRec.id, assetRec.id, woLineItemRec.ServiceTag__c, 'addressBUID', new list<string>{'test'},'test1234');
        
        responseCode = '101';
        commodityPartsWrapperList = DispatchManualPartSelection.getReplacementParts(dispatchRec.id, assetRec.id, woLineItemRec.ServiceTag__c, 'addressBUID', new list<string>{'test'},'test123');
        commodityPartsWrapperList = DispatchManualPartSelection.getReplacementParts(dispatchRec.id, assetRec.id, woLineItemRec.ServiceTag__c, 'addressBUID', new list<string>{'MEMORY'},'test123');
        commodityPartsWrapperList = DispatchManualPartSelection.getReplacementParts(dispatchRec.id, assetRec.id, woLineItemRec.ServiceTag__c, 'addressBUID', new list<string>{'test'},'test1234');
        
        responseCode = null;
        commodityPartsWrapperList = DispatchManualPartSelection.getReplacementParts(dispatchRec.id, assetRec.id, woLineItemRec.ServiceTag__c, 'addressBUID', new list<string>{'test'},'test123');
        
    }*/
    
    @isTest static void testMethod_validateSelectedParts() {
        Account accRec = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert accRec;
        System.Assert(accRec.id != null);
        
        Contact conRec = SRVS_CreateTestDataFactory.createContactRecord(accRec);
        insert conRec;
        System.Assert(conRec.id != null);
        
        
        Asset assetRec = SRVS_CreateTestDataFactory.createSingleAsset(accRec.Id);
        assetRec.Name= 'ABC123';
        insert assetRec;
        System.Assert(assetRec.id != null);
        
        Case csRec = SRVS_CreateTestDataFactory.createSingleCase(assetRec.id, accRec.id, conRec.id);
        insert csRec;
        System.Assert(csRec.id != null);
        
        WorkOrder dispatchRec = SRVS_CreateTestDataFactory.createSingleWorkOrder(assetRec.id, accRec.id, conRec.id, csRec.id);
        insert dispatchRec;
        System.Assert(dispatchRec.id != null);
        
        WorkOrderLineItem woLineItemRec = new WorkOrderLineItem(WorkOrderId = dispatchRec.id, PartPrice__c = '64.7332', 
                                            PartType__c='DIMM', PartNumber__c = 'test', Part_Quantity__c = 'testQuantity', PartCommodity__c= 'MEMORY', Selected_By_user__c= true, AssetId = assetRec.id);
        insert woLineItemRec;
        System.Assert(woLineItemRec.id != null);
        
        woLineItemRec = [select ServiceTag__c, Selected_By_user__c, PartNumber__c, Part_Quantity__c, WorkOrderId from WorkOrderLineItem where id =:woLineItemRec.id];
        system.debug('woLineItemRec-------  '+woLineItemRec.ServiceTag__c);
        
        //list<DispatchManualPartSelection.CommodityPartsWrapper> commodityPartsWrapperList =  DispatchManualPartSelection.validateSelectedParts(new List<workorderLineItem>{woLineItemRec});
        
        // Added Newly
        list<DispatchManualPartSelection.CommodityPartsWrapper> commodityPartsWrapperList =  DispatchManualPartSelection.validateSelectedParts(new List<workorderLineItem>{woLineItemRec},'Parts not in APS', true);
        // Added Newly
        
        //List<AutoSelectPartController.AutoSelectPartWrapper> autoSelectPartWrapperList = DispatchManualPartSelection.insertAndReturnWorkOrderLI(dispatchRec.id, 'Test','Test');
        //DispatchManualPartSelection.saveSelectedParts(new List<workorderLineItem>{woLineItemRec});
        
    }
    
    public static list<GetCommodities__x> getTestCommodities(string responseCode) {
        if(responseCode == null){
            return null;
        }
        list<GetCommodities__x> Commodities_list = new list<GetCommodities__x>();
        Commodities_list.add(new GetCommodities__x(ResponseCode__c = responseCode));
        return Commodities_list;
    }
    
    public static list<ReplacementParts__x> getTestReplacementParts(string responseCode) {
        if(responseCode == null){
            return null;
        }
        list<ReplacementParts__x> ReplacementParts_list = new list<ReplacementParts__x>();
        ReplacementParts_list.add(new ReplacementParts__x(ResponseCode__c = responseCode));
        return ReplacementParts_list;
    }
    
@isTest static void testMethod_getReplacementParts1() {
        Account accRec = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert accRec;
        System.Assert(accRec.id != null);
        
        Contact conRec = SRVS_CreateTestDataFactory.createContactRecord(accRec);
        insert conRec;
        System.Assert(conRec.id != null);
        
        
        Asset assetRec = SRVS_CreateTestDataFactory.createSingleAsset(accRec.Id);
        assetRec.Name= 'ABC123';
        insert assetRec;
        System.Assert(assetRec.id != null);
        
        Case csRec = SRVS_CreateTestDataFactory.createSingleCase(assetRec.id, accRec.id, conRec.id);
        insert csRec;
        System.Assert(csRec.id != null);
        
        WorkOrder dispatchRec = SRVS_CreateTestDataFactory.createSingleWorkOrder(assetRec.id, accRec.id, conRec.id, csRec.id);
        insert dispatchRec;
        System.Assert(dispatchRec.id != null);
        
        WorkOrderLineItem woLineItemRec = new WorkOrderLineItem(WorkOrderId = dispatchRec.id, PartPrice__c = '64.7332',
                                            PartType__c='DIMM', PartCommodity__c= 'MEMORY', Selected_By_user__c= false, AssetId = assetRec.id, Line_Item_Type__c ='MPS', PartNumber__c = 'test123' );
        insert woLineItemRec;
        System.Assert(woLineItemRec.id != null);
        
        woLineItemRec = [select ServiceTag__c, Selected_By_user__c, PartNumber__c, WorkOrderId from WorkOrderLineItem where id =:woLineItemRec.id];
        system.debug('woLineItemRec-------  '+woLineItemRec.ServiceTag__c);
        
        //responseCode = '100';
        ReplacementParts__x mockrequest = new ReplacementParts__x();
        mockrequest.PartNumber__c=DispatchAutoPartSelection_Test.partnumber;
        mockrequest.FunctionalDescription__c=DispatchAutoPartSelection_Test.functionalDescription;
        mockrequest.FourHrsSLA__c=DispatchAutoPartSelection_Test.fourhours;
        mockrequest.ResponseCode__c='100';
        mockrequest.AddressBUID__c=DispatchAutoPartSelection_Test.SBUID;
    mockrequest.CommodityName__c='12333333333333334567891010101010101010101010101010101010101010101010101010101010101010101010167838638963983698363863983638963986398363983689363896389368936378798798798678587587587';
        DispatchManualPartSelection.MockAutovalidateParts.add(mockrequest);
        
        validateReturnParts__x mockrequest1 = new validateReturnParts__x();
        mockrequest1.PartNumber__c='Test'+DispatchAutoPartSelection_Test.partnumber;
        mockrequest1.Price__c=DispatchAutoPartSelection_Test.partprice;
        mockrequest1.PartType__c=DispatchAutoPartSelection_Test.partType;
        mockrequest1.Subcomponent__c=DispatchAutoPartSelection_Test.subcomponent;
        mockrequest1.FunctionalDescription__c=DispatchAutoPartSelection_Test.functionalDescription;
        mockrequest1.FourHrsSLA__c=DispatchAutoPartSelection_Test.fourhours;
        mockrequest1.Commodity__c='12333333333333334567891010101010101010101010101010101010101010101010101010101010101010101010167838638963983698363863983638963986398363983689363896389368936378798798798678587587587';
        DispatchManualPartSelection.MockvalidateParts.add(mockrequest1);
        
        
        DispatchManualPartSelection.getReplacementParts(dispatchRec.id,assetRec.id,woLineItemRec.ServiceTag__c,'11', new list<string>{'test'},'test123');
     }     
@isTest static void testMethod_getReplacementParts2() {
        Account accRec = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert accRec;
        System.Assert(accRec.id != null);
        
        Contact conRec = SRVS_CreateTestDataFactory.createContactRecord(accRec);
        insert conRec;
        System.Assert(conRec.id != null);
        
        
        Asset assetRec = SRVS_CreateTestDataFactory.createSingleAsset(accRec.Id);
        assetRec.Name= 'ABC123';
        insert assetRec;
        System.Assert(assetRec.id != null);
        
        Case csRec = SRVS_CreateTestDataFactory.createSingleCase(assetRec.id, accRec.id, conRec.id);
        insert csRec;
        System.Assert(csRec.id != null);
        
        WorkOrder dispatchRec = SRVS_CreateTestDataFactory.createSingleWorkOrder(assetRec.id, accRec.id, conRec.id, csRec.id);
        insert dispatchRec;
        System.Assert(dispatchRec.id != null);
        
        WorkOrderLineItem woLineItemRec = new WorkOrderLineItem(WorkOrderId = dispatchRec.id, PartPrice__c = '64.7332',
                                            PartType__c='DIMM', PartCommodity__c= 'MEMORY', Selected_By_user__c= false, AssetId = assetRec.id, Line_Item_Type__c ='MPS', PartNumber__c = 'test123' );
        insert woLineItemRec;
        System.Assert(woLineItemRec.id != null);
        
        woLineItemRec = [select ServiceTag__c, Selected_By_user__c, PartNumber__c, WorkOrderId from WorkOrderLineItem where id =:woLineItemRec.id];
        system.debug('woLineItemRec-------  '+woLineItemRec.ServiceTag__c);
        
        //responseCode = '100';
        ReplacementParts__x mockrequest = new ReplacementParts__x();
         mockrequest.ResponseCode__c='100';
          mockrequest.PartNumber__c='Test12344';
        DispatchManualPartSelection.MockAutovalidateParts.add(mockrequest);
        validateReturnParts__x mockrequest1 = new validateReturnParts__x();
        mockrequest1.PartNumber__c='Test';
        mockrequest1.Price__c='1234567';
        mockrequest1.PartType__c='3456789';
        mockrequest1.Subcomponent__c='345677777';
        mockrequest1.FunctionalDescription__c='56346346534';
        mockrequest1.FourHrsSLA__c='YYY';
        
       
        
        DispatchManualPartSelection.MockvalidateParts.add(mockrequest1);
        
        DispatchManualPartSelection.getReplacementParts(dispatchRec.id,assetRec.id,woLineItemRec.ServiceTag__c,'11', new list<string>{'test'},'test123');
     }
     
     @isTest static void testMethod_getReplacementParts3() {
        Account accRec = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert accRec;
        System.Assert(accRec.id != null);
        
        Contact conRec = SRVS_CreateTestDataFactory.createContactRecord(accRec);
        insert conRec;
        System.Assert(conRec.id != null);
        
        
        Asset assetRec = SRVS_CreateTestDataFactory.createSingleAsset(accRec.Id);
        assetRec.Name= 'ABC123';
        insert assetRec;
        System.Assert(assetRec.id != null);
        
        Case csRec = SRVS_CreateTestDataFactory.createSingleCase(assetRec.id, accRec.id, conRec.id);
        insert csRec;
        System.Assert(csRec.id != null);
        
        WorkOrder dispatchRec = SRVS_CreateTestDataFactory.createSingleWorkOrder(assetRec.id, accRec.id, conRec.id, csRec.id);
        insert dispatchRec;
        System.Assert(dispatchRec.id != null);
        
        WorkOrderLineItem woLineItemRec = new WorkOrderLineItem(WorkOrderId = dispatchRec.id, PartPrice__c = '64.7332',
                                            PartType__c='DIMM', PartCommodity__c= 'MEMORY', Selected_By_user__c= false, AssetId = assetRec.id, Line_Item_Type__c ='MPS', PartNumber__c = 'test123' );
        insert woLineItemRec;
        System.Assert(woLineItemRec.id != null);
        
        woLineItemRec = [select ServiceTag__c, Selected_By_user__c, PartNumber__c, WorkOrderId from WorkOrderLineItem where id =:woLineItemRec.id];
        system.debug('woLineItemRec-------  '+woLineItemRec.ServiceTag__c);
        
        //responseCode = '100';
        ReplacementParts__x mockrequest = new ReplacementParts__x();
        mockrequest.PartNumber__c=DispatchAutoPartSelection_Test.partnumber;
        mockrequest.FunctionalDescription__c=DispatchAutoPartSelection_Test.functionalDescription;
        mockrequest.FourHrsSLA__c=DispatchAutoPartSelection_Test.fourhours;
        mockrequest.ResponseCode__c='100';
        mockrequest.AddressBUID__c=DispatchAutoPartSelection_Test.SBUID;
    mockrequest.CommodityName__c='12333333333333334567891010101010101010101010101010101010101010101010101010101010101010101010167838638963983698363863983638963986398363983689363896389368936378798798798678587587587';
        DispatchManualPartSelection.MockAutovalidateParts.add(mockrequest);
        
        validateReturnParts__x mockrequest1 = new validateReturnParts__x();
        mockrequest1.PartNumber__c='Test'+DispatchAutoPartSelection_Test.partnumber;
        mockrequest1.Price__c=DispatchAutoPartSelection_Test.partprice;
        mockrequest1.PartType__c=DispatchAutoPartSelection_Test.partType;
        mockrequest1.Subcomponent__c=DispatchAutoPartSelection_Test.subcomponent;
        mockrequest1.FunctionalDescription__c=DispatchAutoPartSelection_Test.functionalDescription;
        mockrequest1.FourHrsSLA__c=DispatchAutoPartSelection_Test.fourhours;
        mockrequest1.ValidPart__c='false';
        mockrequest1.ItemExists__c='N';
        mockrequest1.Commodity__c='12333333333333334567891010101010101010101010101010101010101010101010101010101010101010101010167838638963983698363863983638963986398363983689363896389368936378798798798678587587587';
        DispatchManualPartSelection.MockvalidateParts.add(mockrequest1);
        
        
        DispatchManualPartSelection.getReplacementParts(dispatchRec.id,assetRec.id,woLineItemRec.ServiceTag__c,'11', new list<string>{'test'},'test123');
     } 
     @isTest static void testMethod_getReplacementParts4() {
        Account accRec = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert accRec;
        System.Assert(accRec.id != null);
        
        Contact conRec = SRVS_CreateTestDataFactory.createContactRecord(accRec);
        insert conRec;
        System.Assert(conRec.id != null);
        
        
        Asset assetRec = SRVS_CreateTestDataFactory.createSingleAsset(accRec.Id);
        assetRec.Name= 'ABC123';
        insert assetRec;
        System.Assert(assetRec.id != null);
        
        Case csRec = SRVS_CreateTestDataFactory.createSingleCase(assetRec.id, accRec.id, conRec.id);
        insert csRec;
        System.Assert(csRec.id != null);
        
        WorkOrder dispatchRec = SRVS_CreateTestDataFactory.createSingleWorkOrder(assetRec.id, accRec.id, conRec.id, csRec.id);
        insert dispatchRec;
        System.Assert(dispatchRec.id != null);
        
        WorkOrderLineItem woLineItemRec = new WorkOrderLineItem(WorkOrderId = dispatchRec.id, PartPrice__c = '64.7332',
                                            PartType__c='DIMM', PartCommodity__c= 'MEMORY', Selected_By_user__c= false, AssetId = assetRec.id, Line_Item_Type__c ='MPS', PartNumber__c = 'test123' );
        insert woLineItemRec;
        System.Assert(woLineItemRec.id != null);
        
       List<WorkorderLineItem>  woLineItemRecli = [select ServiceTag__c, Selected_By_user__c, PartNumber__c, WorkOrderId from WorkOrderLineItem where id =:woLineItemRec.id];
        system.debug('woLineItemRec-------  '+woLineItemRec.ServiceTag__c);
        List<WorkOrderLineItem> wllist = new List<WorkOrderLineItem>();
        for(WorkorderLineItem wl : woLineItemRecli )
        {
        wl.Selected_By_user__c=true;
        wllist.add(wl);
        }
        update wllist;
        
        //responseCode = '100';
        ReplacementParts__x mockrequest = new ReplacementParts__x();
        mockrequest.PartNumber__c=DispatchAutoPartSelection_Test.partnumber;
        mockrequest.FunctionalDescription__c=DispatchAutoPartSelection_Test.functionalDescription;
        mockrequest.FourHrsSLA__c=DispatchAutoPartSelection_Test.fourhours;
        mockrequest.ResponseCode__c='-103';
        mockrequest.AddressBUID__c=DispatchAutoPartSelection_Test.SBUID;
    mockrequest.CommodityName__c='12333333333333334567891010101010101010101010101010101010101010101010101010101010101010101010167838638963983698363863983638963986398363983689363896389368936378798798798678587587587';
        DispatchManualPartSelection.MockAutovalidateParts.add(mockrequest);
        
        validateReturnParts__x mockrequest1 = new validateReturnParts__x();
        mockrequest1.PartNumber__c='Test'+DispatchAutoPartSelection_Test.partnumber;
        mockrequest1.Price__c=DispatchAutoPartSelection_Test.partprice;
        mockrequest1.PartType__c=DispatchAutoPartSelection_Test.partType;
        mockrequest1.Subcomponent__c=DispatchAutoPartSelection_Test.subcomponent;
        mockrequest1.FunctionalDescription__c=DispatchAutoPartSelection_Test.functionalDescription;
        mockrequest1.FourHrsSLA__c=DispatchAutoPartSelection_Test.fourhours;
        mockrequest1.Commodity__c='12333333333333334567891010101010101010101010101010101010101010101010101010101010101010101010167838638963983698363863983638963986398363983689363896389368936378798798798678587587587';
        DispatchManualPartSelection.MockvalidateParts.add(mockrequest1);
        
        
        DispatchManualPartSelection.getReplacementParts(dispatchRec.id,assetRec.id,wllist[0].ServiceTag__c,'11', new list<string>{'test'},'test123');
     }       
     
     @isTest static void testMethod_getReplacementParts5() {
        Account accRec = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert accRec;
        System.Assert(accRec.id != null);
        
        Contact conRec = SRVS_CreateTestDataFactory.createContactRecord(accRec);
        insert conRec;
        System.Assert(conRec.id != null);
        
        
        Asset assetRec = SRVS_CreateTestDataFactory.createSingleAsset(accRec.Id);
        assetRec.Name= 'ABC123';
        insert assetRec;
        System.Assert(assetRec.id != null);
        
        Case csRec = SRVS_CreateTestDataFactory.createSingleCase(assetRec.id, accRec.id, conRec.id);
        insert csRec;
        System.Assert(csRec.id != null);
        
        WorkOrder dispatchRec = SRVS_CreateTestDataFactory.createSingleWorkOrder(assetRec.id, accRec.id, conRec.id, csRec.id);
        insert dispatchRec;
        System.Assert(dispatchRec.id != null);
        
        WorkOrderLineItem woLineItemRec = new WorkOrderLineItem(WorkOrderId = dispatchRec.id, PartPrice__c = '64.7332',
                                            PartType__c='DIMM', PartCommodity__c= 'MEMORY', Selected_By_user__c= false, AssetId = assetRec.id, Line_Item_Type__c ='MPS', PartNumber__c = 'test123' );
        insert woLineItemRec;
        System.Assert(woLineItemRec.id != null);
        
       woLineItemRec = [select ServiceTag__c, Selected_By_user__c, PartNumber__c, WorkOrderId from WorkOrderLineItem where id =:woLineItemRec.id];
        system.debug('woLineItemRec-------  '+woLineItemRec.ServiceTag__c);
       
        
        //responseCode = '100';
        ReplacementParts__x mockrequest = new ReplacementParts__x();
        mockrequest.PartNumber__c=DispatchAutoPartSelection_Test.partnumber;
        mockrequest.FunctionalDescription__c=DispatchAutoPartSelection_Test.functionalDescription;
        mockrequest.FourHrsSLA__c=DispatchAutoPartSelection_Test.fourhours;
        mockrequest.ResponseCode__c='-103';
        mockrequest.AddressBUID__c=DispatchAutoPartSelection_Test.SBUID;
    mockrequest.CommodityName__c='12333333333333334567891010101010101010101010101010101010101010101010101010101010101010101010167838638963983698363863983638963986398363983689363896389368936378798798798678587587587';
        DispatchManualPartSelection.MockAutovalidateParts.add(mockrequest);
        
        validateReturnParts__x mockrequest1 = new validateReturnParts__x();
        mockrequest1.PartNumber__c='Test'+DispatchAutoPartSelection_Test.partnumber;
        mockrequest1.Price__c=DispatchAutoPartSelection_Test.partprice;
        mockrequest1.PartType__c=DispatchAutoPartSelection_Test.partType;
        mockrequest1.Subcomponent__c=DispatchAutoPartSelection_Test.subcomponent;
        mockrequest1.FunctionalDescription__c=DispatchAutoPartSelection_Test.functionalDescription;
        mockrequest1.FourHrsSLA__c=DispatchAutoPartSelection_Test.fourhours;
        mockrequest1.Commodity__c='12333333333333334567891010101010101010101010101010101010101010101010101010101010101010101010167838638963983698363863983638963986398363983689363896389368936378798798798678587587587';
        DispatchManualPartSelection.MockvalidateParts.add(mockrequest1);
        
        
        DispatchManualPartSelection.getReplacementParts(dispatchRec.id,assetRec.id,woLineItemRec.ServiceTag__c,'', new list<string>{},'');
        DispatchManualPartSelection.getManualSelectionReason(dispatchRec.id);
     }             
}