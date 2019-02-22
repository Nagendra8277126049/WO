@isTest
public class CallTransferLog_Test {
  @isTest static void CallTransferLogTest()
  {
          Call_Transcript__c ct=SRVS_CreateTestDataFactory.createcallTranscript();
          ct.Call_UCID__c='1213454654657';
          insert ct;
         // CallTransferLog.CTAttrWrapper wrapper= new CallTransferLog.CTAttrWrapper();  
         // wrapper=CallTransferLog.getCTAttrRec(ct.Call_UCID__c);
         // Call_Transcript__c ct1= new Call_Transcript__c();
          CallTransferLog.getCTAttrRec(ct.Call_UCID__c);
          CallTransferLog.getCTAttrRec(null);
      
  }
}