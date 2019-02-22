/* -----------------------------------------------------------------------------------------------------------------------
Name:       ScheduleWrapper
Description:  This class contains schedules slots structure
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
04/09/2018     1.0     Rodrigo Carpio      Initial Release
--------------------------------------------------------------------------------------------------------------------------*/
public class ScheduleWrapper
{
    @AuraEnabled public string slotSection{get;set;}
    @AuraEnabled public List<SlotWrapper> sectionSlotList {get;set;}
    public ScheduleWrapper (string slotSection, List<SlotWrapper> sectionSlotList)
    {
        this.slotSection = slotSection;
        this.sectionSlotList = sectionSlotList;
    }
}