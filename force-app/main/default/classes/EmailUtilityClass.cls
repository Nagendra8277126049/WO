/* -----------------------------------------------------------------------------------------------------------------------
Name:         EmailUtilityClass
Description:  Used in DeactivateInactiveUserBatch to send the mail to Users who is not logged in salesforce from 75 days.
              -  Story #4541390 And Story #4055035
----------------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ----------------------------------------------------------------------------------
02/12/2018     1.0           Abhishek Pandey       Initial Release
----------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class EmailUtilityClass 
{ 
    public static void emailTemp(list<User> userList)
    {
        try{
            String TempName=Label.EmailTempName;
            String OrgwideMail=Label.OrgWideEmailAdd;
            EmailTemplate  a = [SELECT id,body FROM EmailTemplate WHERE name =:TempName]; 
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:OrgwideMail];
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage> ();
            if(a!=null)
            {
            for(User U :userList )
            {
              String textBody=a.Body;
              textBody=textBody.replace('{!User.FirstName}',U.FirstName);
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
              mail.setToAddresses(new List<String> {U.Email});
                if(String.isNotBlank(U.Manager_email_id__c)){
                mail.setCcAddresses(new List<String> {U.Manager_email_id__c});
                }
              mail.setTemplateId(a.Id);
              mail.setTargetObjectId(U.Id);
                if ( owea.size() > 0 )
                {
    				mail.setOrgWideEmailAddressId(owea.get(0).Id);
				}
              mail.setSaveAsActivity(false);
            mail.setSubject('Your Dell Salesforce SIT4/GE2 access expires in 15 days');
            mail.setPlainTextBody(textBody);
            mailList.add(mail);
            }
            } 
			Messaging.SendEmailResult [] results = Messaging.sendEmail(mailList);
            for(Messaging.SendEmailResult r : results){
                if(!r.isSuccess()){
                    system.debug(r.getErrors());}
                }
        }
        catch(Exception e){}
            }
  }