/**
 * Mock business object service implementation for testing.
 */
@IsTest
public with sharing class zzMockBusinessEventService
        implements xecm.IBusinessEventService2 {

	/** variable to hold the flag value **/
	@TestVisible
	private static Boolean globalTriggerEnabled = true;        	
    
	/** {@inheritDoc} */
	@TestVisible     
	public boolean getGlobalTriggerEnabledFlag() {
		System.assertEquals(true, 1==1);
		return globalTriggerEnabled;
	}
     
	/** {@inheritDoc} */
	@TestVisible     
	public void setGlobalTriggerEnabledFlag(Boolean flagValue) {
		System.assertEquals(true, 1==1);
		globalTriggerEnabled = flagValue;
	}
    
    /** {@inheritDoc} */
    public void raiseStandardEvent(List<ID> recordIDs, List<String> eventParameters) {
		/*
		 * TODO : not sure if we need to apply globalTriggerEnabled flag here
		 */        
		System.assertEquals(true, 1==1);
        zzTestResults.addResult('raiseStandardEvent');
        zzTestResults.addResult(recordIDs);
        zzTestResults.addResult(eventParameters);
    }

	public void processContents(List<sObject> sObjects) {

	}
    
    /** {@inheritDoc} */
/*
    public void raiseCustomEvent(
            String       eventName,
            List<ID>     recordIDs,
            List<String> eventParameters) {
        
        zzTestResults.addResult('raiseCustomEvent');
        zzTestResults.addResult(eventName);
        zzTestResults.addResult(recordIDs);
        zzTestResults.addResult(eventParameters);
    }
*/
}