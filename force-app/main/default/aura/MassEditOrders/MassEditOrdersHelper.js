/**
 * Created by tdavis on 10/5/18.
 */
({
    fetchOrders: function (component, event, helper) {
        var action = component.get("c.getOrderList");
        var projectId = component.get("v.recordId");

        action.setParams({
            projectIds: projectId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var orderList = response.getReturnValue();
                component.set("v.orderList", orderList);
                component.set("v.firstOrder", orderList[0]);
            }
            else {
                alert('Error in getting data');
            }
        });

        component.find("updateAllButton").set("v.disabled", true);

        $A.enqueueAction(action);
    },

    doAllUpdate: function (component, event, helper) {
        var action = component.get("c.doAllUpdate");
        var orders = component.get("v.orderList");
        var milestoneId = component.find("milestoneLookupId").get("v.value");

        action.setParams({
            orderList: orders,
            milestoneId: milestoneId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                location.reload();
            }
            else {
                alert('Error in updating data');
            }
        });

        $A.enqueueAction(action);
    }
})