/* -----------------------------------------------------------------------------------------------------------------------
Name:       ContentVersionTriggerHelper
Description: Used in ContentVersionTrigger to restrict Blacklisted file types uploaded through case tab
-  Story #4202316
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
04/01/2017     1.0         Ashish Sharma          Initial Release
01/08/2018     1.1         Soniya Sharaff         Bulkification
01/30/2018     1.2         Ayesha Shahab          Changes based on Defect 4591050
-------------------------------------------------------------------------------------------------------------------------- */
public class ContentVersionTriggerHelper 
{
    public static void attach(List<ContentVersion> att){        
        set<id> Mycontentid = new set<id>();
        for(ContentVersion a:att){
            Mycontentid.add(a.ContentDocumentId);
        }
        List<ContentVersion> lstFileExtensions = [SELECT  FileExtension FROM CONTENTVERSION WHERE CONTENTDOCUMENTID IN :Mycontentid]; 
        for(ContentVersion cv: lstFileExtensions )
        {
            try
            {
                String FileExt;
                FileExt=cv.FileExtension;  
                FileExt = '"' + FileExt + '"';
                FileExt = FileExt.tolowerCase(); 
                String Blacklist = System.Label.AttachExtension;
                Boolean isRestricted=Blacklist.contains(FileExt); 
                if(isRestricted)
                {                      
                    cv.addError('This file format is not allowed');
                }
            }
            catch(Exception e)
            {
                ExceptionHandler.logHandledExceptions(e,'ContentVersionTriggerHelper','attach','ContentVersion Restriction');
            }
        } }
}