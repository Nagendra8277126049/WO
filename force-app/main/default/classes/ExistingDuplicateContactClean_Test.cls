@isTest
public class ExistingDuplicateContactClean_Test {
    
    @isTest 
    public static void unitTestDuplicateContactClean()
    {       
        Account act = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert act;
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        con.AccountId = act.id;
        con.FirstName = 'Test567';
        con.LastName = 'Contact';
        con.Primary_Email__c = 'abc@xyz.com';
        con.Secondary_Email__c = 'pqr@xyz.com';
        con.Secondary_Phone__c = '529847572985';
        con.Secondary_Phone_Type__c='General';
        con.Tertiary_Email__c = 'test@xyz.com';
        con.Tertiary_Phone__c = '98776543344';
        con.Country_Code__c = 'India (91)';
        con.Primary_Phone__c = '1234567891';
        con.Email = 'test123@xyz.com';
        conList.add(con);
        
        Contact con1 = new Contact();
        con1.AccountId = act.id;
        con1.FirstName = 'Test567';
        con1.LastName = 'Contact';
        con1.Primary_Email__c = 'abc@xyz.com';
        con1.Secondary_Email__c = 'pqr@xyz.com';
        con1.Secondary_Phone__c = '529847572985';
        con1.Secondary_Phone_Type__c='General';
        con1.Tertiary_Email__c = 'test@xyz.com';
        con1.Tertiary_Phone__c = '98776543344';
        con1.Country_Code__c = 'India (91)';
        con1.Primary_Phone__c = '1234567891';
        con1.Email = 'test123@xyz.com';
        conList.add(con1);
        
        Contact con2 = new Contact();
        con2.AccountId = act.id;
        con2.FirstName = 'Test567';
        con2.LastName = 'Contact';
        con2.Primary_Email__c = null;
        con2.Secondary_Email__c = null;
        con2.Secondary_Phone_Type__c= null;
        con2.Tertiary_Email__c = null;
        con2.Country_Code__c = 'India (91)';        
        con2.Email = 'test123@xyz.com';
        con2.Tertiary_Phone__c=null;
        con2.Secondary_Phone__c=null;
        con2.Primary_Phone__c=null ;       
        conList.add(con2);
        
        insert conList;
        
        List<Contact> cts = [Select id from Contact where Id In:conList];
        
        Test.startTest();
        
        DuplicateRule dR = [select id from DuplicateRule where DeveloperName = 'Duplicate_Contact_Check' LIMIT 1];
        DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
        
        
        insert dupRS;
        
        
        Database.DMLOptions insertDML = new Database.DMLOptions(); 
        insertDML.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(conList[0], insertDML);
        DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId=conList[0].id);
        insert dup;
        
        Database.SaveResult sr1 = Database.insert(conList[1], insertDML);
        DuplicateRecordItem dup1 = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId=conList[1].id);
        insert dup1;
        
        Database.SaveResult sr2 = Database.insert(conList[2], insertDML);
        DuplicateRecordItem dup2 = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId=conList[2].id);
        insert dup2;
        
        DuplicateContactCleanupSchedule duplicateContactCleanupSchedule = new DuplicateContactCleanupSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('duplicateContactCleanupSchedule',sch,duplicateContactCleanupSchedule);
        Test.stopTest();
        
    }
    @isTest 
    public static void unitTestDuplicateContactClean1()
    {       
        Account act = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert act;
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        con.AccountId = act.id;
        con.FirstName = 'Test567';
        con.LastName = 'Contact';
        con.Primary_Email__c = 'abc@xyz.com';
        con.Secondary_Email__c = 'pqr@xyz.com';
        con.Secondary_Phone__c = '529847572985';
        con.Secondary_Phone_Type__c='General';
        con.Tertiary_Email__c = 'test@xyz.com';
        con.Tertiary_Phone__c = '98776543344';
        con.Country_Code__c = 'India (91)';
        con.Primary_Phone__c = '1234567891';
        con.Email = 'test123@xyz.com';
        conList.add(con);
        
        Contact con1 = new Contact();
        con1.AccountId = act.id;
        con1.FirstName = 'Test567';
        con1.LastName = 'Contact';
        con1.Primary_Email__c = 'abc@xyz.com';
        con1.Secondary_Email__c = 'pqr@xyz.com';
        con1.Secondary_Phone__c = '529847572985';
        con1.Secondary_Phone_Type__c='General';
        con1.Tertiary_Email__c = 'test@xyz.com';
        con1.Tertiary_Phone__c = '98776543344';
        con1.Country_Code__c = 'India (91)';
        con1.Primary_Phone__c = '1234567891';
        con1.Email = 'test123@xyz.com';
        conList.add(con1);
        
        Contact con2 = new Contact();
        con2.AccountId = act.id;
        con2.FirstName = 'Test567';
        con2.LastName = 'Contact';
        con2.Primary_Email__c = null;
        con2.Secondary_Email__c = null;
        con2.Tertiary_Email__c = null;
        con2.Secondary_Phone_Type__c=null;
        con2.Country_Code__c = 'India (91)';        
        con2.Email = 'test123@xyz.com';
        con2.Tertiary_Phone__c=null;
        con2.Secondary_Phone__c=null;
        con2.Primary_Phone__c=null ;       
        conList.add(con2);
        
        insert conList;
        
        List<Contact> cts = [Select id from Contact where Id In:conList];
        
        Test.startTest();
        
        DuplicateRule dR = [select id from DuplicateRule where DeveloperName = 'Duplicate_Contact_Check' LIMIT 1];
        DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
        
        
        insert dupRS;
        
        
        Database.DMLOptions insertDML = new Database.DMLOptions(); 
        insertDML.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(conList[2], insertDML);
        DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId=conList[2].id);
        insert dup;
        
        Database.SaveResult sr1 = Database.insert(conList[1], insertDML);
        DuplicateRecordItem dup1 = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId=conList[1].id);
        insert dup1;
        
        Database.SaveResult sr2 = Database.insert(conList[0], insertDML);
        DuplicateRecordItem dup2 = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId=conList[0].id);
        insert dup2;
        DuplicateContactCleanupSchedule duplicateContactCleanupSchedule = new DuplicateContactCleanupSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('duplicateContactCleanupSchedule',sch,duplicateContactCleanupSchedule);
        Test.stopTest();  
    }
    @isTest 
    public static void unitTestDuplicateContactClean2()
    {       
        Account act = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert act;
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        con.AccountId = act.id;
        con.FirstName = 'Test567';
        con.LastName = 'Contact';
        con.Primary_Email__c = 'abc@xyz.com';
        con.Secondary_Email__c = 'pqr@xyz.com';
        con.Secondary_Phone__c = '529847572985';
        con.Secondary_Phone_Type__c='General';
        con.Tertiary_Email__c = 'test@xyz.com';
        con.Tertiary_Phone__c = '98776543344';
        con.Country_Code__c = 'India (91)';
        con.Primary_Phone__c = '1234567891';
        con.Email = 'test123@xyz.com';
        conList.add(con);
        
        Contact con1 = new Contact();
        con1.AccountId = act.id;
        con1.FirstName = 'Test567';
        con1.LastName = 'Contact';
        con1.Primary_Email__c = 'abc@xyz.com';
        con1.Secondary_Email__c = 'pqr@xyz.com';
        con1.Secondary_Phone__c = '529847572985';
        con1.Secondary_Phone_Type__c='General';
        con1.Tertiary_Email__c = 'test@xyz.com';
        con1.Tertiary_Phone__c = '98776543344';
        con1.Country_Code__c = 'India (91)';
        con1.Primary_Phone__c = '1234567891';
        con1.Email = 'test123@xyz.com';
        conList.add(con1);
        
        Contact con2 = new Contact();
        con2.AccountId = act.id;
        con2.FirstName = 'Test567';
        con2.LastName = 'Contact';
        con2.Primary_Email__c = null;
        con2.Secondary_Phone_Type__c='General';
        con2.Tertiary_Email__c = null;
        con2.Country_Code__c = 'India (91)';        
        con2.Email = 'test123@xyz.com';
        con2.Tertiary_Phone__c=null;
        con2.Secondary_Phone__c='529847572985';
        con2.Primary_Phone__c='529847572985';       
        conList.add(con2);
        
        insert conList;
        
        List<Contact> cts = [Select id from Contact where Id In:conList];
        
        Test.startTest();
        
        DuplicateRule dR = [select id from DuplicateRule where DeveloperName = 'Duplicate_Contact_Check' LIMIT 1];
        DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
        
        
        insert dupRS;
        
        
        Database.DMLOptions insertDML = new Database.DMLOptions(); 
        insertDML.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(conList[2], insertDML);
        DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId=conList[2].id);
        insert dup;
        
        Database.SaveResult sr1 = Database.insert(conList[1], insertDML);
        DuplicateRecordItem dup1 = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId=conList[1].id);
        insert dup1;
        
        Database.SaveResult sr2 = Database.insert(conList[0], insertDML);
        DuplicateRecordItem dup2 = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId=conList[0].id);
        insert dup2;
        
        DuplicateContactCleanupSchedule duplicateContactCleanupSchedule = new DuplicateContactCleanupSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('duplicateContactCleanupSchedule',sch,duplicateContactCleanupSchedule);
        Test.stopTest();
    }
    
    @isTest 
    public static void unitTestDuplicateContactClean3()
    {       
        Account act = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert act;
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        con.AccountId = act.id;
        con.FirstName = 'Test567';
        con.LastName = 'Contact';
        con.Primary_Email__c = 'abc@xyz.com';
        con.Secondary_Email__c = 'pqr@xyz.com';
        con.Secondary_Phone__c = null;
        con.Secondary_Phone_Type__c=null;
        con.Tertiary_Email__c = 'test@xyz.com';
        con.Tertiary_Phone__c = '98776543344';
        con.Country_Code__c = 'India (91)';
        con.Primary_Phone__c = '1234567891';
        con.Email = 'test123@xyz.com';
        conList.add(con);
        
        Contact con1 = new Contact();
        con1.AccountId = act.id;
        con1.FirstName = 'Test567';
        con1.LastName = 'Contact';
        con1.Primary_Email__c = 'abc@xyz.com';
        con1.Secondary_Email__c = 'pqr@xyz.com';
        con1.Secondary_Phone__c = null;
        con1.Secondary_Phone_Type__c=null;
        con1.Tertiary_Email__c = 'test@xyz.com';
        con1.Tertiary_Phone__c = '98776543344';
        con1.Country_Code__c = 'India (91)';
        con1.Primary_Phone__c = '1234567891';
        con1.Email = 'test123@xyz.com';
        conList.add(con1);
        
        Contact con2 = new Contact();
        con2.AccountId = act.id;
        con2.FirstName = 'Test567';
        con2.LastName = 'Contact';
        con2.Primary_Email__c = 'prim@dell.com';
        con2.Secondary_Email__c = 'sec@dell.com';
        con2.Secondary_Phone_Type__c='General';
        con2.Tertiary_Email__c = null;
        con2.Country_Code__c = 'India (91)';        
        con2.Email = 'test123@xyz.com';
        con2.Tertiary_Phone__c=null;
        con2.Secondary_Phone__c='1234567891';
        con2.Primary_Phone__c='1234567891';       
        conList.add(con2);
        
        insert conList;
        
        List<Contact> cts = [Select id from Contact where Id In:conList];
        
        Test.startTest();
        
        DuplicateRule dR = [select id from DuplicateRule where DeveloperName = 'Duplicate_Contact_Check' LIMIT 1];
        DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
        
        
        insert dupRS;
        
        
        Database.DMLOptions insertDML = new Database.DMLOptions(); 
        insertDML.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(conList[2], insertDML);
        DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId=conList[2].id);
        insert dup;
        
        Database.SaveResult sr1 = Database.insert(conList[1], insertDML);
        DuplicateRecordItem dup1 = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId=conList[1].id);
        insert dup1;
        
        Database.SaveResult sr2 = Database.insert(conList[0], insertDML);
        DuplicateRecordItem dup2 = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId=conList[0].id);
        insert dup2;
        
        DuplicateContactCleanupSchedule duplicateContactCleanupSchedule = new DuplicateContactCleanupSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('duplicateContactCleanupSchedule',sch,duplicateContactCleanupSchedule);
        Test.stopTest();
    }
    
}