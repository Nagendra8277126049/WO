@isTest()
public with sharing class RegionManagerTest 
{
    @isTest()
    static void Should_Return_CountryId_When_Buid_Is_Valid()
    {
        //Arrange 
        pse__Region__c r = new pse__Region__c();
       	r.ISO_Country_Code__c = 'XX';
        r.Name = 'Test Country';
        insert(r);
        
        //Act
        Test.startTest(); 
        pse__region__c region = RegionManager.GetRegionByBUID('0');
        Id regionId = region != null ? region.Id : null;
		Test.stopTest();
        
        //Assert
        System.assert(regionId != null);
        System.assert(regionId == r.Id);
    }
    
    @isTest()
    static void Should_Return_Null_When_Buid_Is_Not_Configured()
    {
        //Arrange 
        pse__Region__c r = new pse__Region__c();
       	r.ISO_Country_Code__c = 'XX';
        r.Name = 'Test Country';
        insert(r);
        
        //Act
        Test.startTest(); 
        pse__region__c region = RegionManager.GetRegionByBUID('9999999');
        Id regionId = region != null ? region.Id : null;
		Test.stopTest();
        
        //Assert
        System.assert(regionId == null);
    }
    
    @isTest()
    static void Should_Return_Null_When_region_Does_Not_Exists()
    {        
        //Act
        Test.startTest(); 
        pse__region__c region = RegionManager.GetRegionByBUID('0');
        Id regionId = region != null ? region.Id : null;
		Test.stopTest();
        
        //Assert
        System.assert(regionId == null);
    }
}