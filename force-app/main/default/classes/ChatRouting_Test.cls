/* -----------------------------------------------------------------------------------------------------------------------
Name:         ChatRouting_Test
Description:  Test class for ChatRouting Api and CheckAvailabilityUtility
----------------------------------------------------------------------------------------------------------------------------
Date          Version        	Author               Summary of Changes E
---------------------------------------------------------------------------------------------------------------------------
07/24/2018     1.0        	Surya Subramanian		   August Release
08/24/2018	   2.0			Surya Subramanian		   Novemeber Release - Story : 5458375 
10/25/2018	   3.0			Surya Subramanian		   Defect : 5737514
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
public class ChatRouting_Test {
    
    private static User u;
    
    @testsetup
    public static void testdata()
    {   
        u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        insert u;
        system.runAs(u)
        {
            Holiday h = SRVS_CreateTestDataFactory.createSingleHolidayRecord('BH for Testing Shift');
            h.ActivityDate=System.now().DateGMT();
            h.RecurrenceType = 'RecursDaily';
            h.RecurrenceInterval=1;
            h.StartTimeInMinutes=0;
            h.EndTimeInMinutes=1439;
            h.RecurrenceStartDate = Date.today();
            h.IsAllDay = false;
            insert h;
            System.debug('Holiday 1 :'+h.ActivityDate);  
            
            Priority_Mapping__c priorityMapping = SRVS_CreateTestDataFactory.createSinglePriorityMappingRecord();
            insert priorityMapping;
            
            Routing_Rules__c routingRule = SRVS_CreateTestDataFactory.createSingleRoutingRuleRecord();
            routingRule.Rule_Name__c = priorityMapping.Id;
            insert routingRule;
            
            BusinessHours bh3 = SRVS_CreateTestDataFactory.querySingleBusinessHoursRecord('EMEA.TS.CLI.CHAT.EN.CORE');
            BusinessHours bhStandardShift = SRVS_CreateTestDataFactory.querySingleBusinessHoursRecord('BH for Testing Standard Shift');
     
            Holiday fullDay = SRVS_CreateTestDataFactory.createSingleHolidayRecord('EMEA.TS.CLI.CHAT.EN.CORE');
            fullDay.ActivityDate=System.now().DateGMT();
            insert fullDay;
            
            Business_Hours_Exeption__c bheFullday = new Business_Hours_Exeption__c();
            bheFullday.Business_Hours__c = bh3.id;
            bheFullday.Holiday__c = fullDay.Name;
            bheFullday.Name = 'Testing Full Day';
            insert bheFullday;

			Holiday HolidayFulldayforStandardShift = SRVS_CreateTestDataFactory.createSingleHolidayRecord('BH for Testing Standard Shift');
            HolidayFulldayforStandardShift.ActivityDate=System.now().DateGMT();
            insert HolidayFulldayforStandardShift; 
			            
            Business_Hours_Exeption__c bheFulldayforStandardShift = new Business_Hours_Exeption__c();
            bheFulldayforStandardShift.Business_Hours__c = bhStandardShift.id;
            bheFulldayforStandardShift.Holiday__c = HolidayFulldayforStandardShift.Name;
            bheFulldayforStandardShift.Name = 'Testing Standard Shift';
            insert bheFulldayforStandardShift;

            MapQueueBH__mdt mq=SRVS_CreateTestDataFactory.QuerySingleMapQueueBHRecord('BH_for_Testing_Shift');
            MapQueueBH__mdt mqforStandardShift=SRVS_CreateTestDataFactory.QuerySingleMapQueueBHRecord('BH_for_Testing_Standard_Shift');
            
            BusinessHours bh = SRVS_CreateTestDataFactory.querySingleBusinessHoursRecord('BH for Testing Shift1');
            BusinessHours bh1 = SRVS_CreateTestDataFactory.querySingleBusinessHoursRecord('BH for Testing Shift2');
            
            Business_Hours_Exeption__c bhe = new Business_Hours_Exeption__c();
            bhe.Business_Hours__c = bh.id;
            bhe.Holiday__c = h.Name;
            bhe.Name = 'Testing';
            insert bhe;
            
        }
    }

   @isTest
    public static void PerformChatRouting_Test()
    {
        String returnMessage;
        String JSONMsg = ' {"Region":"1","BUID":"11","Extra1":"","Country":"USA","Language":"","PremierType":"","OOW":"N","LocalChannel":"","CompanyNumber":"","FamilyName":"","ProductCode":""}'; 
        // Set up a test request
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        // Set request properties
        req.addHeader('Content-Type', 'application/json');
        req.requestUri ='/services/apexrest/ChatRouting/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        ChatRouting.PerformChatRouting();
        Test.stopTest();  
        returnMessage = res.responseBody.toString();
        system.assertNotEquals(null ,returnMessage);
    }   
    
    @isTest
    public static void PerformChatRouting_Negative_Scenario_Test()
    {
        String returnMessage;
        String JSONMsg = ' {"Region":"1","BUID":"11","Extra1":"US","Country":"USA","Language":"EN","PremierType":"PROSUPPORT","OOW":"Y","LocalChannel":"28","CompanyNumber":"28","FamilyName":"Latitude","ProductCode":"4CS"}'; 
        // Set up a test request
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        // Set request properties
        req.addHeader('Content-Type', 'application/json');
        req.requestUri ='/services/apexrest/ChatRouting/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        ChatRouting.PerformChatRouting();
        Test.stopTest();       
        returnMessage = res.responseBody.toString();
        system.assertNotEquals(null ,returnMessage);
    } 

    @isTest
    public static void checkAvailability_test()
    {
        String multipleShiftResponse;
        String response1;
        CheckAvailabilityUtility.ResponseWrapper errorResponse = new CheckAvailabilityUtility.ResponseWrapper();
        CheckAvailabilityUtility.ResponseWrapper standardShiftResponse = new CheckAvailabilityUtility.ResponseWrapper();
        Map<String,String> testMap = new Map<String,String>();
        CheckAvailabilityUtility.ResponseWrapper response = new CheckAvailabilityUtility.ResponseWrapper();
        
        BusinessHours bh1 = SRVS_CreateTestDataFactory.querySingleBusinessHoursRecord('BH for Testing Shift1');
        BusinessHours bh2 = SRVS_CreateTestDataFactory.querySingleBusinessHoursRecord('BH for Testing Shift2');
        
        /*----------------For Covering Line no.708 - 730-----------------------------*/
        
        BusinessHours bh3 = SRVS_CreateTestDataFactory.querySingleBusinessHoursRecord('EMEA.TS.CLI.CHAT.EN.CORE');
        List<BusinessHours> bh = new List<BusinessHours>();
        bh.add(bh3);
        
        /*-------------------------------------------------------------------------------------------*/
        
        /*----------------For Covering Line no.123 - 136-----------------------------*/
        
        BusinessHours bh4 = SRVS_CreateTestDataFactory.querySingleBusinessHoursRecord('BH for Testing Standard Shift');
        List<BusinessHours> bhForStandardShift = new List<BusinessHours>();
        //bhForStandardShift.add(bh3);
        
        /*-------------------------------------------------------------------------------------------*/
        
        /*----------------For Covering Line no.1328 - 1348-----------------------------*/
        DateTime dt = DateTime.newInstance(System.now().dateGMT(),bh1.MondayStartTime);
        Time returnValue; 
        String returnTime;
        /*-------------------------------------------------------------------------------------------*/
        
        /*----------------For Covering Line no.740 - 1327-----------------------------*/
        String returnResponse1;
        String returnResponse2;
        String returnResponse3;
        String returnResponse4;
        String returnResponse5;
        String returnResponse6;
        String returnResponse7;
        
        String returnResponse8;
        String returnResponse9;
        String returnResponse10;
        String returnResponse11;
        String returnResponse12;
        String returnResponse13;
        String returnResponse14;
        
        String multipleBh;
        
        DateTime datet1 = DateTime.now();
        System.debug('Date 1 :'+datet1.format('EEEE',bh1.TimeZoneSidKey));
        DateTime dt2 = datet1.addDays(1);
        System.debug('Date 2 :'+dt2.format('EEEE',bh1.TimeZoneSidKey));
        DateTime dt3 = datet1.addDays(2);
        System.debug('Date 3 :'+dt3.format('EEEE',bh1.TimeZoneSidKey));
        DateTime dt4 = datet1.addDays(3);
        System.debug('Date 4 :'+dt4.format('EEEE',bh1.TimeZoneSidKey));
        DateTime dt5 = datet1.addDays(4);
        System.debug('Date 5 :'+dt5.format('EEEE',bh1.TimeZoneSidKey));
        DateTime dt6 = datet1.addDays(5);
        System.debug('Date 6 :'+dt6.format('EEEE',bh1.TimeZoneSidKey));
        DateTime dt7 = datet1.addDays(6);
        System.debug('Date 7 :'+dt7.format('EEEE',bh1.TimeZoneSidKey));
        
        List<BusinessHours> bhEveryDay = new List<BusinessHours>();
        bhEveryDay.add(bh1);
        List<BusinessHours> bhNoHoliday  = new List<BusinessHours>();
        bhNoHoliday.add(bh2);
        
        List<BusinessHours> bhMultiple  = new List<BusinessHours>();
        bhMultiple.add(bh1);
        bhMultiple.add(bh2);
        /*-------------------------------------------------------------------------------------------*/
        
        
        Test.startTest();
        errorResponse = CheckAvailabilityUtility.checkWithInBusinessHours('Testing');   
        standardShiftResponse = CheckAvailabilityUtility.checkWithInBusinessHours('BH_for_Testing_Standard_Shift');
        response= CheckAvailabilityUtility.checkWithInBusinessHours('BH_for_Testing_Shift');   
        testMap = CheckAvailabilityUtility.timing('Sunday','Saturday',bh1);
        response1 = CheckAvailabilityUtility.CreateException(bh);
        returnValue = CheckAvailabilityUtility.returnValue(dt,bh1.MondayStartTime);
        returnTime = CheckAvailabilityUtility.returnTime(dt);
        returnResponse1 = CheckAvailabilityUtility.nextAvailableTimingForMultipleShifts(bh,datet1);
        returnResponse2 = CheckAvailabilityUtility.nextAvailableTimingForMultipleShifts(bhEveryDay,dt2);
        returnResponse3 = CheckAvailabilityUtility.nextAvailableTimingForMultipleShifts(bhEveryDay,dt3);
        returnResponse4 = CheckAvailabilityUtility.nextAvailableTimingForMultipleShifts(bhEveryDay,dt4);
        returnResponse5 = CheckAvailabilityUtility.nextAvailableTimingForMultipleShifts(bhEveryDay,dt5);
        returnResponse6 = CheckAvailabilityUtility.nextAvailableTimingForMultipleShifts(bhEveryDay,dt6);
        returnResponse7 = CheckAvailabilityUtility.nextAvailableTimingForMultipleShifts(bhEveryDay,dt7);
        
        //returnResponse = CheckAvailabilityUtility.nextAvailableTimingForMultipleShifts(bhNoHoliday,dt3);
        returnResponse8 = CheckAvailabilityUtility.nextAvailableTimingForMultipleShifts(bhNoHoliday,datet1);
        returnResponse9 = CheckAvailabilityUtility.nextAvailableTimingForMultipleShifts(bhNoHoliday,dt2);
        returnResponse10 = CheckAvailabilityUtility.nextAvailableTimingForMultipleShifts(bhNoHoliday,dt3);
        returnResponse11 = CheckAvailabilityUtility.nextAvailableTimingForMultipleShifts(bhNoHoliday,dt4);
        returnResponse12 = CheckAvailabilityUtility.nextAvailableTimingForMultipleShifts(bhNoHoliday,dt5);
        returnResponse13 = CheckAvailabilityUtility.nextAvailableTimingForMultipleShifts(bhNoHoliday,dt6);
        returnResponse14 = CheckAvailabilityUtility.nextAvailableTimingForMultipleShifts(bhNoHoliday,dt7);
        
        multipleBh = CheckAvailabilityUtility.nextAvailableTimingForMultipleShifts(bhMultiple,datet1);
        
        multipleShiftResponse = CheckAvailabilityUtility.TimingForMultipleShifts(bhMultiple);
        
        Test.stopTest();
        
        System.debug('Response : '+response);
        System.debug('Response 1:'+response1);
        System.debug('Error Response :'+errorResponse.exceptionMessage);
        System.debug('Standard Response : '+standardShiftResponse);
        
        System.assertNotEquals(null, response);
        System.assertNotEquals(null, response1);
        System.assertEquals('List has no rows for assignment to SObject', errorResponse.exceptionMessage);
        
    }
}