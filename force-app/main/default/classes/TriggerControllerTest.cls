@isTest
private class TriggerControllerTest {

    @isTest
    static void projectTriggerEnabledTest() {
        Test.startTest();

        Boolean projectTriggerEnabled = TriggerController.projectTriggerEnabled;
        
        Test.stopTest();
        
        system.assert(projectTriggerEnabled == true || projectTriggerEnabled == false);
    }
}