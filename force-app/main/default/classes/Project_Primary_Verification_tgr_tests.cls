@isTest
private class Project_Primary_Verification_tgr_tests {
private static List<Contact> createContacts()
{
    List<Contact> result = new List<Contact>();
    
    Account account = new Account();
    account.Name = 'Create Contact Project';
    insert(account);

    pse__Work_Calendar__c workCalendar = new pse__Work_Calendar__c();
    workCalendar.Name = 'Work Calendar Test';
    insert(workCalendar);
    
    Contact contact1 = new Contact();
    contact1.Account_Id__c = account.Id;
    contact1.FirstName = 'contact1';
    contact1.LastName = 'Teste';
    contact1.pse__Work_Calendar__c = workCalendar.Id;
    contact1.Email = 'contato1@contato1.com';
    contact1.CurrencyIsoCode = 'USD';
    insert(contact1);
    result.add(contact1);

    Contact contact2= new Contact();
    contact2.Account_Id__c = account.Id;
    contact2.FirstName = 'contact2';
    contact2.LastName = 'Teste';
    contact2.pse__Work_Calendar__c = workCalendar.Id;
    contact2.Email = 'contato2@contato2.com';
    contact2.CurrencyIsoCode = 'USD';
    insert(contact2);
    result.add(contact2);
    
    Contact contact3 = new Contact();
    contact3.Account_Id__c = account.Id;
    contact3.FirstName = 'contact3';
    contact3.LastName = 'Teste';
    contact3.pse__Work_Calendar__c = workCalendar.Id;
    contact3.Email = 'contato3@contato3.com';
    contact3.CurrencyIsoCode = 'USD';
    insert(contact3);
    result.add(contact3);

    Contact contact4 = new Contact();
    contact4.Account_Id__c = account.Id;
    contact4.FirstName = 'contact4';
    contact4.LastName = 'Teste';
    contact4.pse__Work_Calendar__c = workCalendar.Id;
    contact4.Email = 'contato4@contato4.com';
    contact4.CurrencyIsoCode = 'USD';
    insert(contact4);
    result.add(contact4);
    
    return result;
}
private static List<Project_Contact__c> Duplicated_Project_Contacts()
{
    List<Project_Contact__c> result = new List<Project_Contact__c>();
    List<Contact> contacts = createContacts();
    
    pse__Proj__c project1 = new pse__Proj__c();
    project1.Name = 'Project Teste 1';
    project1.pse__Is_Template__c = false;
    project1.pse__Is_Active__c = true;
    project1.Project_Visibility__c = 'All';
    insert(project1);

    Project_contact__c projectContact1 = new Project_contact__c();
    projectContact1.Contact__c = contacts[0].Id;
    projectContact1.Project__c = project1.Id;
    projectContact1.Primary_Contact__c = true;
    result.add(projectContact1);

    Project_contact__c projectContact2 = new Project_contact__c();
    projectContact2.Contact__c = contacts[1].Id;
    projectContact2.Project__c = project1.Id;
    projectContact2.Primary_Contact__c = true;
    result.add(projectContact2);

    pse__Proj__c project2 = new pse__Proj__c();
    project2.Name = 'Project Teste 2';
    project2.pse__Is_Template__c = false;
    project2.pse__Is_Active__c = true;
    project2.Project_Visibility__c = 'All';
    insert(project2);
    
    Project_contact__c projectContact3 = new Project_contact__c();
    projectContact3.Contact__c = contacts[2].Id;
    projectContact3.Project__c = project2.Id;
    projectContact3.Primary_Contact__c = true;
    result.add(projectContact3);

    Project_contact__c projectContact4 = new Project_contact__c();
    projectContact4.Contact__c = contacts[3].Id;
    projectContact4.Project__c = project2.Id;
    projectContact4.Primary_Contact__c = true;
    result.add(projectContact4);
    
    return result;
}

@isTest
static void Insert_List_With_Duplications_Should_Return_2_Errors()
{
    try
    {
        List<Project_Contact__c> duplicated_Project_Contacts  = Duplicated_Project_Contacts();
        Test.startTest();
     	insert(duplicated_Project_Contacts);
        Test.stopTest();
    }catch(Exception e)
	{
		System.AssertEquals(e.getMessage().contains('This Project Contact are duplicated, you can not have more than one Primary Contact'), true );
	}
}
@isTest
static void Insert_List_Without_Duplications_But_The_Project_have_a_primaryContact_Should_Return_Errors()
{
    try
    {
        List<Project_Contact__c> listToInsert = new List<Project_Contact__c>();
	    List<Contact> contacts = createContacts();
    
	    pse__Proj__c project1 = new pse__Proj__c();
	    project1.Name = 'Project Teste 1';
	    project1.pse__Is_Template__c = false;
	    project1.pse__Is_Active__c = true;
	    project1.Project_Visibility__c = 'All';
	    insert(project1);

	    Project_contact__c projectContact1 = new Project_contact__c();
	    projectContact1.Contact__c = contacts[0].Id;
	    projectContact1.Project__c = project1.Id;
	    projectContact1.Primary_Contact__c = true;
        insert(projectContact1);

        Project_contact__c projectContact2 = new Project_contact__c();
	    projectContact2.Contact__c = contacts[1].Id;
	    projectContact2.Project__c = project1.Id;
	    projectContact2.Primary_Contact__c = true;
        listToInsert.add(projectContact2);
	
	    Project_contact__c projectContact3 = new Project_contact__c();
	    projectContact3.Contact__c = contacts[2].Id;
	    projectContact3.Project__c = project1.Id;
	    projectContact3.Primary_Contact__c = false;
        listToInsert.add(projectContact3);
        Test.startTest();
        insert(listToInsert);
        Test.stopTest();

    }catch(Exception e)
	{
		System.AssertEquals(e.getMessage().contains('The project should have only one Primary Contact'), true);
	}
}
}