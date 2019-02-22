/* -----------------------------------------------------------------------------------------------------------------------
Name:       TestUtils
Description:  Utility class to enhance unit testing.
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
2018-10-18     1.0         Jorge Moreira          Initial Release
-------------------------------------------------------------------------------------------------------------------------- */

public class TestUtils {
  public static Boolean enable_isRunningTest = true;
	
  public static Boolean isRunningTest()
  {
    return Test.isRunningTest() && enable_IsRunningTest;
  }
}