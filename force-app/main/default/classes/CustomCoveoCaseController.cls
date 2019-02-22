public class CustomCoveoCaseController {
    @AuraEnabled
    public static Case getCaseFromId(Id caseID) {
        List<Case> cases = [ SELECT Status from CASE where ID = :caseID ];
        return cases[0];
    }
}