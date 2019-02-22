public class HardwareAndServicesProjectInfoController {
    @AuraEnabled
    public static List<OrderItem> GetOrderItems(Id projectId, String filterCriteria) 
    {
        return new ProjectHardwareAndServiceInfoProvider().GetOrderItems(projectId, filterCriteria);
    }
}