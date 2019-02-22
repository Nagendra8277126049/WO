public class SKUEffortManagementRemovalService 
{
    public class SKUEffortManagementRequest 
    {
    	@InvocableVariable(required=true)
    	public Id orderId;
    	@InvocableVariable(required=true)
    	public Id projectId;
	}
    
    @InvocableMethod(label='Manage WBS between a project and an order' description='Change the WBS structure of a project removing tasks according the SKU Effort Mapp Configuration' )
    public static void ManageTasksForOrder(List<SKUEffortManagementRequest> requests)
    {
        for(SKUEffortManagementRequest req : requests)
        {
            SKUEffortAutomator s  = new SKUEffortAutomator();
            s.ManageTasksRemoval(req.orderId, req.projectId);
        }
    }
}