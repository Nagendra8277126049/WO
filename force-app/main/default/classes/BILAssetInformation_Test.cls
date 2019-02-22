/* -----------------------------------------------------------------------------------------------------------------------
Name:       BILAssetInformation_Test
Description:  This is Test class for the BIL asset information structure #4640778
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
03/09/2018     1.0     Rodrigo Carpio      Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class BILAssetInformation_Test {
    private static User u=SRVS_CreateTestDataFactory.createUser('System Administrator');
    @isTest
    private static void BILAssetInformation_POSITIVE()
    {
         System.runAs(u) {
             Test.startTest();
             
             BILAssetInformation asssetInfo=new BILAssetInformation();
             
             BILAssetInformation.AssetDetails assetDetResp=new BILAssetInformation.AssetDetails();
             BILAssetInformation.AssetIdentifiers assetIDResp=new BILAssetInformation.AssetIdentifiers();
             
             
             
             /******** Positive Case ***************/
             assetDetResp.id = '12345';
             assetDetResp.serviceTag = 'TESTTAG';
             assetDetResp.serialNumber = 'SN1234567890';
             assetDetResp.manufacturerId = '1';
             assetDetResp.manufacturerDescription = 'MY DESCRIPTION';
             assetDetResp.expressServiceCode = 'ESC1234567890';
             assetDetResp.customerBuid = '11';
             assetDetResp.customerNumber = 'CN1234567890';
             assetDetResp.orderBuid = '11';
             assetDetResp.orderNumber = 'ON1234567890';
             assetDetResp.tieNumber = '123';
             assetDetResp.sourceSiteId = '11';
             assetDetResp.shipDate = '2018-03-10 00:00:00';
             assetDetResp.productCode = 'PC1234567890';
             assetDetResp.productDescription = 'PC DESCRIPTION';
             assetDetResp.productLineCode = 'PLC12345';
             assetDetResp.productLineDescription = 'PL DESCRIPTION';
             assetDetResp.productLobCode = 'PLOB12345';
             assetDetResp.productLobDescription = 'PLOB DESCRIPTION';
             assetDetResp.localChannel = '123';
             assetDetResp.orderCompanyNumber = 'OCN12345';
             
             System.assertEquals('12345',assetDetResp.id);             
             System.assertEquals('TESTTAG',assetDetResp.serviceTag);
             System.assertEquals('SN1234567890',assetDetResp.serialNumber);
             System.assertEquals('1',assetDetResp.manufacturerId);
             System.assertEquals('MY DESCRIPTION',assetDetResp.manufacturerDescription);
             System.assertEquals('ESC1234567890',assetDetResp.expressServiceCode);
             System.assertEquals('11',assetDetResp.customerBuid);
             System.assertEquals('CN1234567890',assetDetResp.customerNumber);
             System.assertEquals('11',assetDetResp.orderBuid);
             System.assertEquals('ON1234567890',assetDetResp.orderNumber);
             System.assertEquals('123',assetDetResp.tieNumber);
             System.assertEquals('11',assetDetResp.sourceSiteId);
             
             System.assertEquals('2018-03-10 00:00:00',assetDetResp.shipDate);
             System.assertEquals('PC1234567890',assetDetResp.productCode);
             System.assertEquals('PC DESCRIPTION',assetDetResp.productDescription);
             System.assertEquals('PLC12345',assetDetResp.productLineCode);
             System.assertEquals('PL DESCRIPTION',assetDetResp.productLineDescription);
             System.assertEquals('PLOB12345',assetDetResp.productLobCode);
             System.assertEquals('PLOB DESCRIPTION',assetDetResp.productLobDescription);
             System.assertEquals('123',assetDetResp.localChannel);
             System.assertEquals('OCN12345',assetDetResp.orderCompanyNumber);
             System.assertEquals(null,assetDetResp.tiedToAssetFlag);
             /*
             BILAssetInformation.Identifiers contentId = new BILAssetInformation.Identifiers();
             contentId.identifierTypeId = '92';
             contentId.identifierTypeName = 'TYPE';
             contentId.identifierValue = 'VALUE';
             assetIDResp.content.add(contentId);
             system.debug(assetIDResp.content);
             System.assertEquals('92',assetIDResp.content[0].identifierTypeId);
             System.assertEquals('TYPE',assetIDResp.content[0].identifierTypeName);
             System.assertEquals('VALUE',assetIDResp.content[0].identifierValue); */
             
             Test.stopTest();
         }
    }
	@isTest
    private static void BILAssetInformation_NEGATIVE()
    {
         System.runAs(u) {
             Test.startTest();
             
             BILAssetInformation asssetInfo=new BILAssetInformation();
             
             BILAssetInformation.AssetDetails assetDetResp=new BILAssetInformation.AssetDetails();
             BILAssetInformation.AssetIdentifiers assetIDResp=new BILAssetInformation.AssetIdentifiers();
             
             Test.stopTest();
             
             /******** Negative Case ***************/
             System.assertEquals(null,assetDetResp.id);
             System.assertEquals(null,assetDetResp.serviceTag);
             System.assertEquals(null,assetDetResp.serialNumber);
             System.assertEquals(null,assetDetResp.manufacturerId);
             System.assertEquals(null,assetDetResp.manufacturerDescription);
             System.assertEquals(null,assetDetResp.expressServiceCode);
             System.assertEquals(null,assetDetResp.customerBuid);
             System.assertEquals(null,assetDetResp.customerNumber);
             System.assertEquals(null,assetDetResp.orderBuid);
             System.assertEquals(null,assetDetResp.orderNumber);
             System.assertEquals(null,assetDetResp.tieNumber);
             System.assertEquals(null,assetDetResp.sourceSiteId);
             System.assertEquals(null,assetDetResp.shipDate);
             System.assertEquals(null,assetDetResp.productCode);
             System.assertEquals(null,assetDetResp.productDescription);
             System.assertEquals(null,assetDetResp.productLineCode);
             System.assertEquals(null,assetDetResp.productLineDescription);
             System.assertEquals(null,assetDetResp.productLobCode);
             System.assertEquals(null,assetDetResp.productLobDescription);
             System.assertEquals(null,assetDetResp.localChannel);
             System.assertEquals(null,assetDetResp.orderCompanyNumber);
             System.assertEquals(null,assetDetResp.tiedToAssetFlag);
             
             System.assertEquals(null,assetIDResp.content);
             
         }
    }
}