/* -----------------------------------------------------------------------------------------------------------------------
Name:         DeactivateInactiveUserScedule
Description:  Used to Schedule Class DeactivateInactiveUserBatch to run on daily basis.
              -  Story #4541390 And Story #4055035
----------------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ----------------------------------------------------------------------------------
02/12/2018     1.0           Abhishek Pandey       Initial Release
----------------------------------------------------------------------------------------------------------------------------------*/
Public class DeactivateInactiveUserScedule implements Schedulable
{
     public void execute(SchedulableContext ctx)
    {
         string ct;
        DeactivateInactiveUserBatch batchSchedule = new DeactivateInactiveUserBatch();
        if(!test.isRunningTest())
        Database.executeBatch(batchSchedule);
    }
}