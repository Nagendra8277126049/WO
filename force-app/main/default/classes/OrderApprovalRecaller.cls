public class OrderApprovalRecaller 
{
    @InvocableMethod(label='Recall Order Approval Process' description='Recall approval process if the process is Pending')
	public static void RecallOrderApprovalProcess(List<string> orderIds)
    {
        List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem  WHERE ProcessInstance.TargetObjectId IN :orderIds AND ProcessInstance.Status = 'Pending'];
        
        for (ProcessInstanceWorkitem workItem : workItems) {
        	Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
            
            request.setAction('Removed');
            request.setWorkItemId(workItem.id);
            
            Approval.process(request);
        }
        
        /*
        for(Id orderId : orderIds)
        {
            ProcessInstanceWorkitem[] workItems = [SELECT Id FROM ProcessInstanceWorkitem  WHERE ProcessInstance.TargetObjectId = :orderId AND ProcessInstance.Status = 'Pending'];

        	if(workItems.size() > 0)
       		{
            	Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
            	request.setAction('Removed');
            	request.setWorkItemId(workItems[0].id);
            	Approval.process(request);
        	}
        }*/
    }
}