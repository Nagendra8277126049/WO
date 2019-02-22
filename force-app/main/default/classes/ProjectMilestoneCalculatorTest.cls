@isTest
public class ProjectMilestoneCalculatorTest {
    
    
   @isTest static void calculateProjectMilestoneLow()
    {
        Date projectCreatedDate = date.today();
        String projectComplexity = 'Low';
        Date resultDate;
        
        Test.startTest();
        resultDate = ProjectMilestoneCalculator.CaculateTargetDate(projectCreatedDate, projectComplexity);
        Test.stopTest();
        
        System.assert(resultDate.addDays(-50) == date.today());
        System.assert(resultDate != null);
    } 
    @isTest
    public static void calculateProjectMilestoneMedium() {
        
        Date projectCreatedDate = date.today();
        String projectComplexity= 'Medium';
        Date resultDate;
        Test.startTest();
        
        resultDate=ProjectMilestoneCalculator.CaculateTargetDate(projectCreatedDate, projectComplexity);
        
        Test.stopTest();
        System.assert(resultDate.addDays(-75) == date.today() );
        System.assert(resultDate != null);
    }
    
    @isTest static void calculateProjectMilestoneHigh()
    {
        Date projectCreatedDate = date.today();
        String projectComplexity = 'High';
        Date resultDate;
        
        Test.startTest();
        resultDate = ProjectMilestoneCalculator.CaculateTargetDate(projectCreatedDate, projectComplexity);
        Test.stopTest();
        
        System.assert(resultDate.addDays(-90) == date.today());
        System.assert(resultDate != null);
    }
        @isTest static void calculateProjectMilestoneInvalid()
    {
        Date projectCreatedDate = date.today();
        String projectComplexity = 'NoSense';
        Date resultDate;
        
        Test.startTest();
        resultDate = ProjectMilestoneCalculator.CaculateTargetDate(projectCreatedDate, projectComplexity);
        Test.stopTest();
        
      
        System.assert(resultDate == null);
    }
}