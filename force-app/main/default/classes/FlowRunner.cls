public class FlowRunner {
	public static void Run_Create_Order_Budget_for_Project(string OrderId, string ProjectId)
	{
	    Map<String, Object> InputMaps = new Map<String, Object>();
	    InputMaps.put('OrderId', OrderId);
	    InputMaps.put('ProjectId', ProjectId);
	    Flow.Interview.Create_Order_Budget_for_Project FlowCreateOrderBudget = new Flow.Interview.Create_Order_Budget_for_Project(InputMaps);
	    FlowCreateOrderBudget.start();
	}
	public static void Run_Post_Chatter_Message(string UserId, string Message)
	{
	    Map<String, Object> InputMaps = new Map<String, Object>();
	    InputMaps.put('UserId', UserId);
	    InputMaps.put('Message', Message);
	    Flow.Interview.Post_Message_To_User_Flow PostMessageToUserFlow = new Flow.Interview.Post_Message_To_User_Flow(InputMaps);
	    PostMessageToUserFlow.start();
	}
    
    public static void Run_Add_Tasks_based_on_SKU_Mapping(string orderId, string projectId, boolean isProjectAssociation) {
    	Map<String, Object> InputMaps = new Map<String, Object>();
	    
        InputMaps.put('OrderId', orderId);
	    InputMaps.put('ProjectId', projectId);
        InputMaps.put('IsProjectAssociation', isProjectAssociation);
	    
        Flow.Interview.Add_Tasks_based_on_SKU_Mapping addTasksBasedOnSkuMapping = new Flow.Interview.Add_Tasks_based_on_SKU_Mapping(InputMaps);
	    
        addTasksBasedOnSkuMapping.start();
    }
}