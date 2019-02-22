@isTest
private class EmailUtility_Test 
{
    @isTest
    static void testEmailUtility()
    {
        Test.StartTest();
        EmailUtility.sendPlainTextEmail(new List<String>{'test@test.com'}, 'Unit Test X', 'Unit Test');
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, invocations, 'An email has not been sent');
    }
}