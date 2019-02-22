/* -----------------------------------------------------------------------------------------------------------------------
Name:       AttachmentRestriction
Description:  Used in AttachmentTrigger to restrict Blacklisted file types uploaded through Live Agent Chat console
and Email to Case
-  Story #4202316
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
12/28/2017     1.0     Dhamodharan Duraisamy        Initial Release
01/08/2018     1.1     Soniya Sharaff               Bulkification
01/30/2018     1.2     Ayesha Shahab                Changes based on Defect 4591050
02/26/2018     1.3     Ayesha Shahab                Changes based on story 4540225
04/06/2018     1.4     Dhamodharan Duraisamy        Changes based on Defect 4926280
-------------------------------------------------------------------------------------------------------------------------- */
public with sharing class AttachmentRestriction { 
    public static void AttRestrict(List<Attachment> Atchmnt, Map<Id, Attachment> newAttachMap){  
        String ParentId;   
        List < Database.DeleteResult > listOfDR = new List < Database.DeleteResult > ();
        Map < Id, Attachment > parentIds = new Map < Id, Attachment > ();
        List <Id> restrictedAttachment = new List<Id>();
        List<Attachment> lstAtts = new List<Attachment>();
        for(Attachment Att : newAttachMap.values()){
            String FileName = Att.Name;
            List<String> FileExtension = FileName.split('\\.');  
            if(FileExtension.size() > 1)  {
            FileExtension[1] = '"' + FileExtension[1] + '"';
            FileExtension[1] = FileExtension[1].tolowerCase();
            String Blacklist = System.Label.AttachExtension;
                Boolean isRestricted=Blacklist.contains(FileExtension[1]);
                if(isRestricted) { 
                    parentIds.put(Att.ParentId, Att);
                    restrictedAttachment.add(Att.id);
                     lstAtts.add(Att); // For Blacklisted files other than Email
                    }
                }
            }
        try{
            if(!parentIds.isEmpty()){
                List<EmailMessage> Source = [SELECT Id,HtmlBody FROM EMAILMESSAGE WHERE ID IN :ParentIds.keySet()];
                if ( !Source.isEmpty()) {
                    List<Attachment> deleteattachment = [Select Id,Name from Attachment where ID IN :restrictedAttachment AND ParentId IN: ParentIds.keySet()];
                    Database.DeleteResult[] ldr = Database.delete(deleteattachment, false);//delete deleteattachment;
                    // Iterate through each returned result
                    if(ldr.size()>0) {
                    for(Database.DeleteResult dr : ldr) {
                        if (!dr.isSuccess()) {
                            listOfDR.add(dr);
                        }  
                    }
                    String[] stringList = new String[0];
                    for(Attachment delAttach: deleteattachment) {
                    stringList.add(String.valueOf(delAttach.Name));
                    }
                    String result = String.join(stringList, ', ');
                    for(EmailMessage em:source){                        
                    String temp;
                        temp= em.HtmlBody ;
                        em.htmlbody ='';
                        em.HtmlBody = +result+ ' : One or more attachments have been deleted because the file extensions are not allowed'+temp;
                        update em;
                        }
                     if(!listOfDR.isEmpty()) {ExceptionHandler.logHandledExceptions(listOfDR, 'AttachmentRestriction','AttRestrict','AttachmentRestriction ');
                    } 
                }
            }
             //Restrict blacklisted files coming from source other than Email 
                else{
                    for(Attachment att: lstAtts){
                       att.addError('This file format is not allowed'); 
                    } 
                }
            }
        }
        catch(exception e){ExceptionHandler.logHandledExceptions(e,'AttachmentRestriction','AttRestrict','AttachmentRestriction ');                                                   
        }
    }
}