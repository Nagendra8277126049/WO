/* -----------------------------------------------------------------------------------------------------------------------
Name:       CommonReturnMessaging
Description:  This class contain common ReturnMessaging structure that can be used in response initialization - application
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
11/02/2017     1.0     Rodrigo Carpio      Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
global with sharing class CommonReturnMessaging {
        public String type{get;set;}  //SUCCESS
        public String details{get;set;}  //100000, Operation successful. 
        public String message{get;set;}  //Operation completed successfully
        public String code{get;set;}  //100
    }