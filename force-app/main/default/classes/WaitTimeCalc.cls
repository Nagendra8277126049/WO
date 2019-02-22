/* -----------------------------------------------------------------------------------------------------------------------
Name:         WaitTimeCalc
Description:  To calculate the chat wait time (Code coverage - 75%. This API Class requires the admin who is running the test
        class to be part of a queue, Ready in omni with ongoing chats to increase the coverage.)
----------------------------------------------------------------------------------------------------------------------------
Date          Version        Author               Summary of Changes 
---------------------------------------------------------------------------------------------------------------------------
06/28/2018     1.0          Roselin Hephzibah      Initial Version
02/01/2019     1.1          Roselin Hephzibah      Updated the logic to consider agent's workload
-------------------------------------------------------------------------------------------------------------------------- */

@RestResource(urlMapping='/WaitTimeCalc/*')
Global class WaitTimeCalc{
@HttpPost
global static void calculateWaitTime()
{
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    res.addHeader('Content-Type', 'application/json');

    Decimal waitTime;
    Decimal ratioOfChats;
    Decimal waitingChats = 0;
    Decimal averageTime = 0;
    Decimal chatsHandledWoWait = 0;
    List<Id> activeUserIds = new List<Id>();
    Decimal capacityPercent = 0;
    
    try{
        WaitTimeRequest waitTimeReq=(WaitTimeRequest) Json.deserialize(req.requestBody.toString(),
                                                                       WaitTimeRequest.class);                                
                                
        // Query the button details
        LiveChatButton buttonDet = [Select Id, DeveloperName, queueId, queue.DeveloperName,queue.QueueRoutingConfigId
                                           from LiveChatButton
                                           where Id =: waitTimeReq.chatButtonId
                                           LIMIT 1];
        //system.debug(buttonDet.queue.DeveloperName);
        //system.debug(buttonDet.Id);
        String queueName = buttonDet.queue.DeveloperName;
        String groupName;
        if(queueName <> null && queueName.length() > 33)
            groupName = '%'+queueName.substring(0,33)+'%';
        else
            groupName = '%'+queueName+'%';            
        
        //Query the configuredCapacityPercentage
        Decimal configuredCapacityPercentage = [Select Id, CapacityPercentage
                                                from QueueRoutingConfig
                                                Where Id =: buttonDet.queue.QueueRoutingConfigId].CapacityPercentage;
        
        // Agents capacity
        Decimal agentCapacity = 100/configuredCapacityPercentage;            
        
        //Query Active agents
        List<UserServicePresence> activeUsers = [Select Id,UserId 
                                                 from UserServicePresence
                                                 where userid IN (select  UserOrGroupId
                                                                  from GroupMember
                                                                  where Group.DeveloperName like :groupName )
                                                 and ServicePresenceStatus.DeveloperName = 'Available'
                                                 and IsCurrentState = true];        
        Integer activeAgents = activeUsers.size();
        system.debug('activeAgents'+activeAgents);
        
        If(!activeUsers.isEmpty()){
            for(UserServicePresence usp : activeUsers) { activeUserIds.add(usp.UserId); }
        }
        
        //Query the active agents workload
        List<AgentWork> activeAgentsWorkload = [Select id,CapacityPercentage, UserId, user.Name
                                                from AgentWork
                                                where userId in: activeUserIds
                                                and status =: 'Opened' 
                                                order by userId ];
        
        
        if(!activeAgentsWorkload.isEmpty()) {
            for(Id userId : activeUserIds) {
                for(AgentWork agentWrk : activeAgentsWorkload) {
                    if(agentWrk.UserId == UserId){
                        capacityPercent = capacityPercent+agentWrk.CapacityPercentage;   
                        system.debug(capacityPercent);                         
                    }
                }
                if(100 - capacityPercent >= configuredCapacityPercentage){
                     chatsHandledWoWait = 1; capacityPercent = 0; break;
                }
                capacityPercent = 0;
            }
        }
        
        // Total available agent's full capaciity
        Decimal totalAgentsCapacity = agentCapacity * activeAgents;
        system.debug('totalAgentsCapacity '+totalAgentsCapacity );
        
        //No of Chats that can be serviced immediately
        if(activeAgents > 0 && activeAgentsWorkload.isEmpty())
            chatsHandledWoWait = totalAgentsCapacity;
            
        system.debug('chatsHandledWoWait '+chatsHandledWoWait ); 
        
        if(chatsHandledWoWait <= 0) {
            
            // Calculate the Avg Speed to Answer with latest 100 AgentWork records for the specific queue.    
            Datetime onehrBefore = System.now().addHours(-1);
            List<AgentWork> agentWorkId = [SELECT Id FROM AgentWork
                                           WHERE (OriginalQueue.DeveloperName =: queueName)
                                           and SpeedToAnswer < 10000
                                           order by createddate desc
                                           LIMIT 100];
            AggregateResult[] avgTime =[SELECT Avg(SpeedToAnswer) FROM AgentWork WHERE Id IN: agentWorkId];
            system.debug('avgTime'+avgTime);
            averageTime = (Decimal)avgTime[0].get('expr0');
            system.debug('avgTime'+averageTime);
            
            //# of Chats which are in Waiting           
            AggregateResult[] waitingChatsCount = [select count(Id) from LiveChatTranscript where LiveChatButton.DeveloperName =: buttonDet.DeveloperName and status = 'waiting'];
            waitingChats = (Integer)waitingChatsCount[0].get('expr0');
            system.debug('waitingChats '+waitingChats );
        }

        //Ratio of Chats which are waiting to the number of chats the agents can handle on full capacity         
        if(totalAgentsCapacity != 0) {
            ratioOfChats = Math.ceil(waitingChats/totalAgentsCapacity);
        } else {
            ratioOfChats = 0;
            }
        system.debug('ratioOfChats'+ratioOfChats);
        
        if((activeAgents == 0) || ((chatsHandledWoWait > 0) && (ratioOfChats == 0))) {
            waitTime = null;
            system.debug('waitTime '+waitTime);
            }        
         else if((waitingChats == (totalAgentsCapacity*ratioOfChats)) && (ratioOfChats >= 1)) {
            waitTime = averageTime * (ratioOfChats+1);
            system.debug('waitTime '+waitTime);
            }
         else if((waitingChats < (totalAgentsCapacity*ratioOfChats)) && (ratioOfChats >= 1)) {
            waitTime = averageTime * ratioOfChats;
            system.debug('waitTime '+waitTime);
            }
        else if(chatsHandledWoWait == 0) {
            waitTime = averageTime;
            system.debug('waitTime '+waitTime);
            }
      }catch(Exception e) {
          waitTime = null;
          ExceptionHandler.logHandledExceptions(e,'WaitTimeCalc','WaitTimeCalc','Channels'); 
      }  
     
    WaitTimeResponse crr = New WaitTimeResponse();
    crr.waitTime = waitTime;
    res.responseBody = blob.valueOf(JSON.serialize(crr));    
}

//Wrapper Class for Response
Public Class WaitTimeResponse{
    Public Decimal waitTime;
}

//Wrapper Class for Request
Public Class WaitTimeRequest{
    Public String chatButtonId;
}


}