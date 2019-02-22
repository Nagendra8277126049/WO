public class VoiceQuickCaseHandler {
    @AuraEnabled
    public static void updateTranscriptRecord (String transcriptId, String caseId)
    {
        try
        {
            Call_Transcript__c ct =[SELECT Case__c, Id FROM Call_Transcript__c where Id=:transcriptId LIMIT 1];
            if(ct!=null)
            {
                ct.Case__c = caseId;
                update ct;
            }
        }
        catch(Exception e)
        {
            system.debug('Error Message : '+e.getMessage());
        }
    }
}