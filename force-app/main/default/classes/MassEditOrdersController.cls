/**
 * Created by tdavis on 10/5/18.
 */

public with sharing class MassEditOrdersController
{
    @AuraEnabled
    public static List<Order> getOrderList(List<Id> projectIds)
    {
        List<Order> orderList = [SELECT OrderNumber, Milestone__c From Order WHERE Project__c IN :projectIds];
        return orderList;
    }

    @AuraEnabled
    public static void doAllUpdate(List<Order> orderList, Id milestoneId)
    {
        for (Order o : orderList)
        {
            o.Milestone__c = milestoneId;
        }

        update orderList;
    }
}