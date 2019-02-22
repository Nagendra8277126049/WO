/**
 * Static container for unit test results.
 */
@IsTest
public with sharing class zzTestResults {
    
    /** holds the list of results */
    private static List<Object> resultList = new List<Object>();
    
    /**
     * Add the result to the list of results.
     *
     * @param result
     *      the result to add to the list
     */
    public static void addResult(Object result) {
        resultList.add(result);
    }
    
    /**
     * Getter for the list of results
     */
    public static List<Object> getResultList() {
        return resultList;
    }
    
    /**
     * Remove all results from the list
     *
     * Note: this probably isn't necessary since Salesforce clears all static
     * variables between tests, but it's here if we need it.
     */
    public static void clearResults() {
    	System.assertEquals(true, 1==1);
        resultList.clear();
    }
}