/* -----------------------------------------------------------------------------------------------------------------------
Name:         DeactivateInactiveUserBatch
Description:  Used to deactivate the user who is not loggedin in salesforce from 90 days and send a mail to the user at 75th 
day before deactivating the user.
-  Story #4541390 And Story #4055035
----------------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ----------------------------------------------------------------------------------
02/12/2018     1.0           Abhishek Pandey       Initial Release
----------------------------------------------------------------------------------------------------------------------------------*/
global with sharing class DeactivateInactiveUserBatch implements Database.Batchable<Sobject>,Database.Stateful
{
    global string FName='SERVICE';
    global string LName='COVEO';
    global string Name = 'Service Integration Profile';
    Integer N = Integer.valueOf(System.Label.NotificationToUser);
    Integer M = Integer.valueOf(System.Label.DeactivateAlert);
    global dateTime loginDate = date.today()-N;
    global list<User> userlist = new list<User>();
    global list<String> Emaillist = new list<String>();
    global list<User> userId = new list<User>();
    global Database.querylocator start(Database.BatchableContext bc)
    {
        try{
            String query ='select user.id, user.Email,user.LastLoginDate, user.FirstName, user.LastName,user.Manager_email_id__c, user.profile.name, user.Username, user.Isactive FROM user, user.profile where Isactive=true AND profile.name!=:Name AND FirstName!=:FName AND LastName!=:LName AND LastLoginDate<=:loginDate';
            return Database.getQueryLocator(query); 
        }
        catch(Exception e)
        {
            return null;
        }
    }
    global void execute(Database.BatchableContext bc,list<User> scope)
    {
        for(User usr:scope)
        {  
            //75days send notification email
            if(usr.LastLoginDate==loginDate)
            {
                Emaillist.add(usr.Email);
                userId.add(usr);
            }
            //morethan 90days then deactive user 
            else if(usr.LastLoginDate<=loginDate-M)                
            {
                usr.IsActive=false;
                userlist.add(usr); 
            }           
        }
    } 
    global void finish(Database.BatchableContext bc)
    {
        //send notification
        if(Emaillist.size() > 0)
        {
            EmailUtilityClass.emailTemp(userId);
        }
        //deactivate users
        if(userlist.size() > 0)
        {
            try{
                Database.update(userlist,false);              
            }
            catch(Exception e){}
        }      
    }
}