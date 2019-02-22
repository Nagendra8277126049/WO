@isTest
public class CustomCoveoAgentPanelControllerTest {
    
    public static testmethod void testGetUserLanguage() {
		string lang = CustomCoveoAgentPanelController.getUserLanguage();
        System.assert(lang != null);
    }
}