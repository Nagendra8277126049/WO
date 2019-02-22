@isTest
public class VoiceQuickCaseHandler_Test {
    @isTest
    private static void setupTestData() {
            
        	// Insert Case
        	Case objCase = new Case (Origin = 'Test', Status = 'In Progress', Priority = 'Medium');
        	insert objCase;
            
        	//create a test Call Transcript
            Call_Transcript__c callTransAttr=SRVS_CreateTestDataFactory.createcallTranscript();
            insert callTransAttr;
            
        VoiceQuickCaseHandler.updateTranscriptRecord(callTransAttr.id,objCase.id);
        VoiceQuickCaseHandler.updateTranscriptRecord(null,null);
            
          
        
    }
}