/**
 * Created by tdavis on 10/5/18.
 */
({
    getOrdersList: function (component, event, helper) {
        helper.fetchOrders(component, event, helper);
    },

    updateAllOrders: function (component, event, helper) {
        
        //----------------------------------------------
        //Added By P Kumar, OAC Services INC.
        //Date: 12/21/2018
        
		var ordersSel = [];
        
        var getOrders = component.find("selectedOrder");
        
        if( !Array.isArray(getOrders))
        {
            if(getOrders.get("v.value") == true)
            {
                ordersSel.push(getOrders.get("v.text"));
            }
        }
        else
        {
            for(var i = 0; i< getOrders.length; i++)
            {
                if(getOrders[i].get("v.value") == true)
                {
                    ordersSel.push( getOrders[i].get("v.text") );
                }
            }
        }
        component.set("v.selectedOrders", ordersSel);
        //----------------------------------------------
        
        
        helper.doAllUpdate(component, event, helper);
    },

    setButtonVisibility: function (component, event, helper) {
        var Id = component.find("milestoneLookupId").get("v.value");

        if (Id == null) {
            component.find("updateAllButton").set("v.disabled", true);
        }
        else {
            component.find("updateAllButton").set("v.disabled", false);
        }
    },

    handleClick: function (cmp, event, helper) {
        alert("Order Saved");
    }
})