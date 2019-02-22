public with sharing class EmailUtility 
{
	public static void sendPlainTextEmail(List<String> toAddresses, String subject, String body)
	{    	
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.settoAddresses(toAddresses);
		mail.setSubject(subject);
		mail.setPlainTextBody(body);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}