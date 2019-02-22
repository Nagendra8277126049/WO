/*
      Purpose:
            Test the ContentDocument / ContentNote handler that is responsible for rolling up notes
            to the Project Task level in PSA
            
      Initiative: Dell North Star PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    5/30/18
*/

@IsTest
private class ContentDocumentTriggerTest {
    @IsTest
    static void testOneNoteAdded() {
        pse__Proj__c testProject = new pse__Proj__c(Project_Visibility__c='All', pse__Is_Active__c = true);
        insert testProject;
        pse__Project_Task__c task = new pse__Project_Task__c(Name='Test Task',pse__Project__c=testProject.Id);
        insert task;
        List<TitleAndBody> testTextList = new List<TitleAndBody>();
        testTextList.add(new TitleAndBody('Lorem Ipsum Consectetur','This is mny Lorem Ipsum thing.'));
        createNotesAndLinks(task,testTextList);
        task = [SELECT Task_Notes__c FROM pse__Project_Task__c WHERE Id = :task.Id];
        System.assertEquals(concatenatedText(testTextList),task.Task_Notes__c);
    }
    @IsTest
    static void testWithNullBody() {
        pse__Proj__c testProject = new pse__Proj__c(Project_Visibility__c='All', pse__Is_Active__c = true);
        insert testProject;
        pse__Project_Task__c task = new pse__Project_Task__c(Name='Test Task',pse__Project__c=testProject.Id);
        insert task;
        List<TitleAndBody> testTextList = new List<TitleAndBody>();
        testTextList.add(new TitleAndBody('Lorem Ipsum Consectetur',null));
        createNotesAndLinks(task,testTextList);
        task = [SELECT Task_Notes__c FROM pse__Project_Task__c WHERE Id = :task.Id];
        System.assertEquals(concatenatedText(testTextList),task.Task_Notes__c);
        System.assert(!task.Task_Notes__c.contains('null'));
    }
    @IsTest
    static void testTwoNotesAdded() {
        pse__Proj__c testProject = new pse__Proj__c(Project_Visibility__c='All', pse__Is_Active__c = true);
        insert testProject;
        pse__Project_Task__c task = new pse__Project_Task__c(Name='Test Task',pse__Project__c=testProject.Id);
        insert task;
        List<TitleAndBody> testTextList = new List<TitleAndBody>();
        testTextList.add(new TitleAndBody('Lorem Ipsum Consectetur','This is mny Lorem Ipsum thing.'));
        testTextList.add(new TitleAndBody('Lorem Ipsum Consectetur 2','This is mny second Lorem Ipsum thing.'));
        createNotesAndLinks(task,testTextList);
        task = [SELECT Task_Notes__c FROM pse__Project_Task__c WHERE Id = :task.Id];
        System.assertEquals(concatenatedText(testTextList),task.Task_Notes__c);
    }
    static String concatenatedText(List<TitleAndBody> tbs) {
        String result = '';
        for (TitleAndBody titleAndBody : tbs) {
            result += titleAndBody.Title + (titleAndBody.Body != null ? ': ' + titleAndBody.Body : '') + '\n';
        }
        return textWithoutCr(result);
    }
    static String textWithoutCr(String text) {
        Integer lastIndexOfCr = text.lastIndexOf('\n');
        return lastIndexOfCr > 0 ? text.left(lastIndexOfCr) : text;
    }
    static List<ContentNote> createNotesAndLinks(pse__Project_Task__c task,List<TitleAndBody> testText) {
        List<ContentNote> notes = new List<ContentNote>();
        for (TitleAndBody tst : testText) {
            notes.add(new ContentNote(Title=tst.Title,Content=tst.Body != null ? Blob.valueOf(tst.Body) : null));
        }
        insert notes;
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (ContentNote contentNote : notes) {
            links.add(new ContentDocumentLink(ContentDocumentId=contentNote.Id,LinkedEntityId=task.Id,ShareType='I'));
        }
        insert links;
        return notes;
    }
    static ContentNote createNote(String title, String body) {
        ContentNote cdoc = new ContentNote();
        cdoc.Title = title;
        cdoc.Content = Blob.valueOf(body);
        return cdoc;
    }
    class TitleAndBody {
        public TitleAndBody(String title, String body) {
            this.Title = title;
            this.Body = body;
        }
        public String Title {get;set;}
        public String Body {get;set;}
    }
}