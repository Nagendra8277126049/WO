/* -----------------------------------------------------------------------------------------------------------------------
Name:       SlotWrapper
Description:  This class contains details of schedules slots structure story #4916977
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
04/09/2018     1.0     Rodrigo Carpio      Initial Release
--------------------------------------------------------------------------------------------------------------------------*/
public class SlotWrapper 
{    
        @AuraEnabled public string dpsStartDateTime {get;set;}
        @AuraEnabled public string dpsEndDateTime {get;set;}
        @AuraEnabled public string slotId {get;set;}
        @AuraEnabled public string slotDate {get;set;}
        @AuraEnabled public string slotStartTime  {get;set;}
        @AuraEnabled public string slotEndTime  {get;set;}
        @AuraEnabled public string slotStartEndTime  {get;set;}
        @AuraEnabled public string concatenatedStartEndDate {get;set;}
    
        public SlotWrapper(String slotId, String dpsStartDateTime, String dpsEndDateTime, String slotDate, String slotStartTime, String slotEndTime)
        {
            this.slotId = slotId;
            this.dpsStartDateTime = dpsStartDateTime;
            this.dpsEndDateTime = dpsEndDateTime;
            this.slotDate = slotDate;
            this.slotStartTime = slotStartTime;
            this.slotEndTime = slotEndTime;
            this.slotStartEndTime = slotStartTime + '-' + slotEndTime;
            this.concatenatedStartEndDate = dpsStartDateTime + '|' + dpsEndDateTime;
        }
}