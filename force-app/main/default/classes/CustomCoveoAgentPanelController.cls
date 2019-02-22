public class CustomCoveoAgentPanelController {
    @AuraEnabled
    public static String getUserLanguage(){
       String userLanguage = UserInfo.getLanguage();
       return userLanguage;
    }
}