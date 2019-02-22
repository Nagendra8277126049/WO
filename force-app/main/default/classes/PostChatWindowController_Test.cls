/* -----------------------------------------------------------------------------------------------------------------------
Name:       PostChatWindowController_Test
Description:  This test class for PostChatWindowController
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
06/11/2018     1.0     Roselin Hephzibah      Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
public class PostChatWindowController_Test {
    @isTest
    public static void postChatWindow_Test(){
            Test.setCurrentPage(Page.LiveAgentPostChatForm);
            ApexPages.currentPage().getParameters().put('startTime','startTime');
            ApexPages.currentPage().getParameters().put('chatKey','chatKey');
            ApexPages.currentPage().getParameters().put('buttonId','buttonId');
            PostChatWindowController pc = new PostChatWindowController();
            pc.onPageLoadAction();
        }
}