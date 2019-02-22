global with sharing class ExistingContactDuplicateCleanup implements Database.Batchable<SObject> { 
    
    global final String Query;
    global ExistingContactDuplicateCleanup(String q)
    {
        Query=q; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Query to get records based on recordsets with limit of 45 when run from anonymous window
        //Each recordset could contain potentially 10 duplicates on a approximate 
        //Below line will be used in dev console, to run 2 concurrent batch class to save time with the exact split in count of records
        
        //Database.executeBatch(new ExistingContactDuplicateCleanup('SELECT Id FROM DuplicateRecordSet where recordcount > 1 order by id DESC limit (exact half count)'), 45);
        //Database.executeBatch(new ExistingContactDuplicateCleanup('SELECT Id FROM DuplicateRecordSet where recordcount > 1 order by id ASC limit (exact half count)'), 45);                  
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC , List<DuplicateRecordSet> scope){ 
        //key = DuplicateRecordsetId //Value = List of DuplicateRecordItem
        Map<Id,List<DuplicateRecordItem>> MapOfDuplicateRecordSetID_And_ListOfDuplicateRecordItems = new Map<Id,List<DuplicateRecordItem>>();
        
        //Initialization
        Contact c ;
        List<DuplicateRecorditem> dupeCons;
        
        //Duplicate Record set Id's from Query call are stored in a set
        Set<ID> IdFromDuplicateRecordSet = new set<ID>();
        for(DuplicateRecordSet DR : scope){
            IdFromDuplicateRecordSet.add((id)DR.get('Id'));
        }
        system.debug('IdFromDuplicateRecordSet'+IdFromDuplicateRecordSet.size());
        
        //Map of Existing Contacts in system within the duplicate record set
        Map<Id, Contact> DuplicateRecordItemsContactsMap = new Map<Id, Contact>([SELECT Id, Email , Primary_Phone__c, Secondary_Phone__c, Tertiary_Phone__c, 
                                                                                 Primary_Email__c, Secondary_Email__c, Tertiary_Email__c 
                                                                                 FROM Contact WHERE id in (Select RecordId from DuplicateRecorditem where DuplicateRecordSetId in :IdFromDuplicateRecordSet)]);
        
        
        //For loop runs for filter criteria as duplicateRecordSet
        for(DuplicateRecorditem DuplicateRecorditemRecord : [Select Id,RecordId,DuplicateRecordSetId from DuplicateRecorditem where DuplicateRecordSetId in :IdFromDuplicateRecordSet order by DuplicateRecordSetId, createddate]){
            string S = DuplicateRecorditemRecord.DuplicateRecordSetId ;
            if(!MapOfDuplicateRecordSetID_And_ListOfDuplicateRecordItems.containsKey(s))
            {
                MapOfDuplicateRecordSetID_And_ListOfDuplicateRecordItems.put(s,new List<DuplicateRecorditem>{DuplicateRecorditemRecord});
                //if Only one Master record is present, it is left as such. No Merge contact.
                c = DuplicateRecordItemsContactsMap.get(DuplicateRecorditemRecord.RecordId);
                dupeCons = new list<DuplicateRecorditem>();
            }
            else
            {
                MapOfDuplicateRecordSetID_And_ListOfDuplicateRecordItems.get(s).add(DuplicateRecorditemRecord);
                
                //List of duplicateRecordItems gettting populated in Map is taken out here
                dupeCons = MapOfDuplicateRecordSetID_And_ListOfDuplicateRecordItems.get(s);
                
                //To track the null value for phone in Master contact record
                if(c.Primary_Phone__c == null || c.Primary_Phone__c == '')    
                    c.Primary_Phone__c = DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Primary_Phone__c;
                else if(c.Secondary_Phone__c == null || c.Secondary_Phone__c == '')    
                    c.Secondary_Phone__c = DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Primary_Phone__c;
                else if(c.Tertiary_Phone__c == null && DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Secondary_Phone__c != null)    
                    c.Tertiary_Phone__c = DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Secondary_Phone__c;
                else if(c.Tertiary_Phone__c == null)    
                    c.Tertiary_Phone__c = DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Primary_Phone__c;
                else if(c.Tertiary_Phone__c != null ||  DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Secondary_Phone__c != null )    
                {
                    String commaToPhone = c.Tertiary_Phone__c;
                    //Set is declared to remove the duplicates
                    Set<String> IndividualPhoneSet = new Set<String>();
                    //Split all emails based on comma and put in set
                    for(String IndividualPhone:commaToPhone.Split(','))
                    {
                        IndividualPhoneSet.add(IndividualPhone.trim()); 
                    }
                    //If only one value is present, just add that value in set
                    if(IndividualPhoneSet.size() == 0)
                        IndividualPhoneSet.add(c.Tertiary_Phone__c);

                     if(DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Primary_Phone__c != null)
                        IndividualPhoneSet.add(DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Primary_Phone__c);
                                        
                    //if duplicate contact has secondary value, then put that in this set 
                    if(DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Secondary_Phone__c != null)
                        IndividualPhoneSet.add(DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Secondary_Phone__c);
                                        
                    //Checking if value in phoneset is present in primary and secondary
                    if(IndividualPhoneSet.contains(c.Primary_Phone__c))
                       IndividualPhoneSet.remove(c.Primary_Phone__c); 
                    if(IndividualPhoneSet.contains(c.Secondary_Phone__c))
                       IndividualPhoneSet.remove(c.Secondary_Phone__c); 

                    //making the value null to avoid previous instance from getting tracked
                    c.Tertiary_Phone__c = null;
                    
                    //Building up values for Tertiary field
                    for(String IndividualPhoneValue : IndividualPhoneSet){
                        if(c.Tertiary_Phone__c == null)
                            c.Tertiary_Phone__c = IndividualPhoneValue;
                        else
                            c.Tertiary_Phone__c += ',' + IndividualPhoneValue;
                    }
                    
                }
                //c.Tertiary_Phone__c += ',' +  DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Primary_Phone__c;
                
                //To track the null value for email in Master contact record
                if(c.Email == null ||c.Email == '' )    
                    c.Email = DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Email;
                else if(c.Primary_Email__c == null ||c.Primary_Email__c == '')    
                    c.Primary_Email__c = DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Email;
                else if(c.Secondary_Email__c == null || c.Secondary_Email__c == '')    
                    c.Secondary_Email__c = DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Email;
                else if(c.Tertiary_Email__c == null)    
                    c.Tertiary_Email__c = DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Email;
                else if(c.Tertiary_Email__c != null )
                {
                    String commaToEmail = c.Tertiary_Email__c;
                    Set<String> IndividualEmailSet = new Set<String>();
                    for(String IndividualEmail:commaToEmail.Split(','))
                    {
                        IndividualEmailSet.add(IndividualEmail.trim()); 
                    }
                    if(IndividualEmailSet.size() == 0)
                        IndividualEmailSet.add(c.Tertiary_Email__c);
                    
                     if(DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Email != null)
                        IndividualEmailSet.add(DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Email);
                      
                    
                    //Checking if value in emailset is present in primary and secondary
                    if(IndividualEmailSet.contains(c.Primary_Email__c))
                       IndividualEmailSet.remove(c.Primary_Email__c); 
                    if(IndividualEmailSet.contains(c.Secondary_Email__c))
                       IndividualEmailSet.remove(c.Secondary_Email__c); 


                    c.Tertiary_Email__c = null;
                    
                    for(String IndividualEmailValue : IndividualEmailSet){
                        if(c.Tertiary_Email__c == null)
                            c.Tertiary_Email__c = IndividualEmailValue;
                        else
                            c.Tertiary_Email__c += ',' + IndividualEmailValue;
                    }
                    
                }
                //c.Tertiary_Email__c += ',' + DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Email; 
                
                //Standard Merge operation, all related list of duplicate contact will be moved to master contact.
                try
                {    
                  Database.merge(c, DuplicateRecordItemsContactsMap.get(dupeCons[dupeCons.size()-1].RecordId).Id);
                }
                catch(exception e){
                  ExceptionHandler.logHandledExceptions(e,'ExistingDuplicatescleanup','execute','dupicates');  
                }            
            }   
        }  
    }
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email    from AsyncApexJob where Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Merge Duplicate contacts batch' + a.Status);
        mail.setPlainTextBody('records processed ' + a.TotalJobItems +   'with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}