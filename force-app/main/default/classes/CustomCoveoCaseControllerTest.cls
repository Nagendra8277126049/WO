@isTest
public class CustomCoveoCaseControllerTest {
	static testMethod void testMethod1() {
		Case testCase = new Case();
		testCase.Status = 'Closed';
		insert testCase;

		Test.StartTest(); 
			Case c = CustomCoveoCaseController.getCaseFromId(testCase.Id);
            System.assertEquals(c.Status, 'Closed');
		Test.StopTest();
	}
}