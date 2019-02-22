public class ProjectMilestoneCalculator {
    public static Date CaculateTargetDate(Date projectCreatedDate, String projectComplexity) {
        
    	// Calculates Target Date based on Project Complexity
        
       	switch on projectComplexity {
            when 'Low' {
                return projectCreatedDate.addDays(50);
            }
            when 'Medium' {
                return projectCreatedDate.addDays(75);
            }
            when 'High' {
                return projectCreatedDate.addDays(90);
            }
            when else {
                return null;
            }
        }
    }
        
}