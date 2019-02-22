public class DeleteDispatchDefault
{
	@InvocableMethod
	public static void DeleteDispatchDefault (List<Id> recordId)
    {
        try{            
            List<DispatchDefaults__c> ddlist= new List<DispatchDefaults__c >([Select Id from DispatchDefaults__c where Work_Order__c in:recordId]); 
				if(!ddlist.Isempty())
				{
				    Delete ddlist;
				}
        } 
        Catch(Exception e)
        {
            ExceptionHandler.logHandledExceptions(e, 'DispatchDefaultsConfiguration', 'DeleteDispatchDefault', 'Dispatch Management');
        }    
    }
}