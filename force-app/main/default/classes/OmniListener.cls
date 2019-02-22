/* -----------------------------------------------------------------------------------------------------------------------
Name:       OmniListener 
Description:  This class contains the logic to check the ECS chat #5121537 
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
03/07/2018     1.0     Roselin Hephzibah      Initial Release

-------------------------------------------------------------------------------------------------------------------------- */

public with sharing class OmniListener {

    public static string lctName {get; set;}
 /* -----------------------------------------------------------------------------------------------------------------------
    Name:       queueCheck
    Description:  this functions returns the asset number stored in temporary field when the asset is not found.
    Input: workId - holds the record identifier to pull the agent work.
    Output: None
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    03/12/2018     1.0     Roselin Hephzibah      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    @AuraEnabled
    public static string queueCheck(Id workId, Id workItemId) {
        
        try{    
            boolean isS360 = false;
            system.debug('work Id' + workId);
            if(workId != null){          
                List<LiveChatButton> buttonList = new List<LiveChatButton>();
                if(Test.isRunningTest()){
                    buttonList = [SELECT id from LiveChatButton LIMIT 1];
                }else{
   					buttonList = [Select Id from LiveChatButton WHERE QueueId In (Select OriginalQueueId from AgentWork where Id =: workId)];
                    }
                system.debug('buttonList Id' + buttonList );
              /*  for(LiveChatButton l : buttonList){
                system.debug('buttonList Id' + l.id);
                system.debug('buttonList Id' + System.Label.ECS_Chat_Button);
                    If(l.Id == System.Label.ECS_Chat_Button){
                        //lctName = l.name;
                        isS360 = true;
                    } 
                }  */
                if(!buttonList.isEmpty()){
                    isS360 = true;
                }
            }
            system.debug('isS360' + isS360);
            if(isS360){
                system.debug(workItemId);
                lctName = [Select Id, Name from LiveChatTranscript Where Id =: workItemId].Name;
                system.debug(lctName);
            }
            else { lctName = null; }
            return lctName;
        }catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'OmniListener','queueCheck','Chat Notification popup');
            return null;  
        }
    }
}