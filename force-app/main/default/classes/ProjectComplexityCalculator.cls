public class ProjectComplexityCalculator {
    private static List<pse__Proj__c> getProjectsInformation(List<Id> projectIds){
        List<pse__Proj__c> projects = [select Id, name, pse__Region__c, PM_Complexity__c, Project_Complexity__c from pse__Proj__c where Id IN :projectIds];
        return projects;
    }
    
    private static pse__Region__c getRegion(Id regionId){
        pse__Region__c region = [select Id, name, ISO_Country_Code__c from pse__Region__c where Id = :regionId];
        return region;
    }
    
    private static Decimal getTotalProjectAmount(ID projectId){
        AggregateResult[] TotalprojectAmount = [select SUM(pse__Amount__c)total from pse__Budget__c where pse__Project__c = :projectId];
        system.debug(TotalprojectAmount);
        Decimal TotalAmount = (Decimal)TotalprojectAmount[0].get('total');
        system.debug(TotalAmount);
        return TotalAmount;
    }
    
    private static string getThreshold(Decimal amount, string isoCountryCode){
       
        List<Project_Complexity_Threshold__c> countryThresholds = [select Low_Threshold__c, High_Threshold__c from Project_Complexity_Threshold__c where Name =:isoCountryCode LIMIT 1];
        if(countryThresholds.size() <= 0){
            return 'Low';
        }
        if(amount <= CountryThresholds[0].Low_Threshold__c){
          return 'Low';
        }
        else if(amount >= CountryThresholds[0].High_Threshold__c){
            return 'High';
        }
        else{
            return 'Medium';
        }
    }   
    
    private static string CalculateBudgetThreshold(pse__Proj__c project)
    {
        Decimal projectAmount = getTotalProjectAmount(project.Id);
         
        pse__Region__c region = getRegion(project.pse__Region__c);
        string country = region.ISO_Country_Code__c;
        String Amountthreshold = getThreshold(projectAmount, country);
        return Amountthreshold;
    }
    
	@InvocableMethod(label='Calcule project complexity' description='Calcule project complexity based on PM Complexity field and revenue threshold.' )
    public static void CalculeProjectComplexity(List<Id> projectId) {
        List<pse__Proj__c> projects = getProjectsInformation(projectId);
        
        for (pse__Proj__c project : projects) {
        	string BudgetThreshold = CalculateBudgetThreshold(project);
        
        	List<Project_Complexity_Mapping__c> projectComplexityMappings = [
            	select Overall_Project_Complexity__c 
            	from Project_Complexity_Mapping__c 
            	where PM_Complexity__c =:project.PM_Complexity__c 
            	and Revenue_Threshold__c = :BudgetThreshold
        		Limit 1];
        
       	 	if(projectComplexityMappings.size() > 0)
            {
                project.Project_Complexity__c = projectComplexityMappings[0].Overall_Project_Complexity__c;
            }	
    	}
        
         ResourceRequestSkillAutomator.UpdateResourceRequestSkills(projectId);
        
        update projects;
        
       
    }
}