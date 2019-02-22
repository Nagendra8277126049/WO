@isTest
public class EncryptKey_Test {
	 @isTest
     static void test()
    {   
        //system.debug('***** TEST2: check null pointer exception catch exception error *****');
        String key = 'abcd';
        Test.startTest();
        String[] result = EncryptKey.getEncryptedValue(key);
        //List<Id> recId =new List<Id>();
        //recId.add([select id from Case where Service_Tag__c ='128K51S'].id);
        //Einstein_Settings__c settings = Einstein_Settings__c.getOrgDefaults();
        //settings.Einstein_EMail__c = 'test@mail.com';
        //upsert settings;
        //CaseClassificationProcessBuilder.doCallout(recId);
        Test.stopTest();
    } 
}