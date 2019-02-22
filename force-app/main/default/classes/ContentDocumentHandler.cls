/*
      Purpose:
            Detect changes in ContentNote records related to PSA project tasks, and
            roll up the title and text preview for each task to the related Project Task.
            
      Initiative: North Star PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    5/30/18
*/

public class ContentDocumentHandler {
    private static String PROJECT_TASK_PREFIX = pse__Project_Task__c.SObjectType.getDescribe().getKeyPrefix();

    public static void rollUpContentNotesToProjectTasks(List<ContentDocument> cdocs) {
        Set<Id> cdocIds = new Map<Id, ContentDocument>(cdocs).keySet();
        Set<Id> taskIds = findTaskIdsGivenContentDocumentIds(cdocIds);
        Set<Id> relatedNotesIdSet = cloneSet(cdocIds);
        if (!taskIds.isEmpty()) {
            List<pse__Project_Task__c> tasks = findProjectTasksAndContentDocumentLinksGivenIds(taskIds);
            Map<Id,List<Id>> taskIdToNoteIdsMap = new Map<Id, List<Id>>();
            for (pse__Project_Task__c task : tasks) {
                List<Id> noteIdList = collectContentDocumentIds(task);
                taskIdToNoteIdsMap.put(task.Id,noteIdList);
                relatedNotesIdSet.addAll(noteIdList);
            }
            Map<Id,ContentNote> noteMap = findContentNotesGivenIds(relatedNotesIdSet);
            List<pse__Project_Task__c> tasksToUpdate = new List<pse__Project_Task__c>();
            for (pse__Project_Task__c task : tasks) {
                if (taskIdToNoteIdsMap.containsKey(task.Id)) {
                    String formattedNoteContent = formatContentNotes(taskIdToNoteIdsMap.get(task.Id), noteMap);
                    updateProjectTask(task, formattedNoteContent, tasksToUpdate);
                }
            }
            updateProjectTasks(tasksToUpdate);
        }
    }

    private static List<Id> collectContentDocumentIds(pse__Project_Task__c task) {
        List<Id> result = new List<Id>();
        for (ContentDocumentLink link : task.ContentDocumentLinks) {
            result.add(link.ContentDocumentId);
        }
        return result;
    }

    private static Map<Id, ContentNote> findContentNotesGivenIds(Set<Id> relatedNotesIdSet) {
        return new Map<Id, ContentNote>([SELECT Title,TextPreview FROM ContentNote WHERE Id IN :relatedNotesIdSet]);
    }

    private static List<pse__Project_Task__c> findProjectTasksAndContentDocumentLinksGivenIds(Set<Id> taskIds) {
        return [SELECT Task_Notes__c, (SELECT ContentDocumentId FROM ContentDocumentLinks) FROM pse__Project_Task__c WHERE Id IN :taskIds];
    }

    private static Set<Id> cloneSet(Set<Id> idSet) {
        Set<Id> result = new Set<Id>();
        result.addAll(idSet);
        return result;
    }

    private static String formatContentNotes(List<Id> cnoteIds, Map<Id, ContentNote> noteMap) {
        String result = '';
        if (cnoteIds != null) {
            for (Id cnoteId : cnoteIds) {
                ContentNote cdoc = noteMap.get(cnoteId);
                if (cdoc != null) {
                    result += formatContentNote(cdoc);
                }
            }
        }
        return result;
    }

    private static void updateProjectTasks(List<pse__Project_Task__c> tasksToUpdate) {
        if (!tasksToUpdate.isEmpty()) {
            update tasksToUpdate;
        }
    }

    private static void updateProjectTask(pse__Project_Task__c task, String concatenated, List<pse__Project_Task__c> tasksToUpdate) {
        if (task.Task_Notes__c != concatenated) {
            task.Task_Notes__c = concatenated;
            tasksToUpdate.add(task);
        }
    }

    private static Set<Id> findTaskIdsGivenContentDocumentIds(Set<Id> cdocIds) {
        Set<Id> taskIds = new Set<Id>();
        for (ContentDocumentLink contentDocumentLink : findContentDocumentLinksGivenCdocIds(cdocIds)) {
            String linkedEntityIdString = contentDocumentLink.LinkedEntityId != null ? contentDocumentLink.LinkedEntityId : '';
            if (linkedEntityIdString.startsWith(PROJECT_TASK_PREFIX)) {
                taskIds.add(contentDocumentLink.LinkedEntityId);
            }
        }
        return taskIds;
    }

    private static List<ContentDocumentLink> findContentDocumentLinksGivenCdocIds(Set<Id> cdocIds) {
        return [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :cdocIds];
    }

    private static String formatContentNote(ContentNote cdoc) {
        return formatTitle(cdoc) + formatTextPreview(cdoc) + formatCr();
    }

    private static String formatCr() {
        return '\n';
    }

    private static String formatTextPreview(ContentNote cdoc) {
        return textPreviewNotEmpty(cdoc)
                ? ': ' + cdoc.TextPreview
                : '';
    }

    private static String formatTitle(ContentNote cdoc) {
        return cdoc.Title;
    }

    private static Boolean textPreviewNotEmpty(ContentNote cdoc) {
        return cdoc.TextPreview != null && cdoc.TextPreview.length() > 0;
    }
}