/* -----------------------------------------------------------------------------------------------------------------------
Name:       CommonMessageHeader
Description:  This class contain common ReturnMessaging structure that can be used in response initialization - application
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
11/02/2017     1.0     Rodrigo Carpio      Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
global with sharing class CommonMessageHeader {
	public CommonReturnMessaging ReturnMessaging{get;set;}   
}