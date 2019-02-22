public class ActionResult {
    @AuraEnabled public String Body { get; set; }
    @AuraEnabled public Integer Status { get; set; }
    
    public ActionResult(String body, Integer status) {
        this.Body = body;
        this.Status = status;
    }
}