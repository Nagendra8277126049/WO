({
	getItems : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Order #', fieldName: 'Order_Number__c', type: 'text', initialWidth: 100, sortable: true},
            {label: 'Tie #', fieldName: 'Order_Tie_Number__c', type: 'number', initialWidth: 80, cellAttributes: { alignment: 'left' }, sortable: true}, 
            {label: 'Asset', fieldName: 'Name', type: 'text', initialWidth: 80, sortable: true},
            {label: 'LOB', fieldName: 'LobDescription', type: 'text', sortable: true}
        ]);
        
        var getWorkOrderStatus = component.get("c.GetWorkOrderStatus");
        
        var getOrderItems = component.get("c.GetOrderItems");
               
        getOrderItems.setParams({
            workOrderId: component.get("v.recordId")
        });
        
        getWorkOrderStatus.setParams({
            workOrderId: component.get("v.recordId")
        });
        
        getWorkOrderStatus.setCallback(this, function(data)
        {
         	var workOrderStatus = data.getReturnValue();
            
            if (workOrderStatus != 'FF - Submitted') {
                $A.enqueueAction(getOrderItems);
            }
            else {
                component.set("v.dispatchMsg","Dispatch was already created for this Work Order.");
            }
        });
        
        getOrderItems.setCallback(this, function(data) 
        {
            console.log('Entering - setCallback');
            var response = data.getReturnValue();
            var assets = response != null ? response.Assets : null;
            
            console.log(assets);
            
            if (assets != null) {
                for (var i = 0; i < response.Assets.length; i++) {
                    var res = response.Assets[i];
                    if (res.Product2) res.LobDescription = res.Product2.LOB_Description__c;
                }
                        
            	component.set("v.OrderItems", assets);
                
                console.log('selected Rows:');
                var selectedRows = component.get("v.selectedRows");
                
                let selectedKeysArr = response.Assets
                  .map((row) => {
                    return row.Id
                  });
                
                console.log(selectedKeysArr);
                component.set("v.selectedRows", selectedKeysArr);
                
                var test = component.get("v.selectedRows");
                console.log(test);
                
                console.log("Final:");
                //console.log(v.selectedRows);
                
                //var rows = ['02in0000008J881AAC'];
                //component.set("v.selectedRows", rows);
            };
        });
        
        $A.enqueueAction(getWorkOrderStatus);    
    },
    
    updateColumnSorting: function(component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    
    getSelectedName: function (component, event) {
        var selectedRecords = [];
        var selectedRows = event.getParam('selectedRows');
        
        selectedRows.forEach(function(selectedRow){
            selectedRecords.push(selectedRow);
        })
        component.set("v.selectedAssets", selectedRecords);
    },
    
    listSelectedRows: function (component, event, helper) {
        var selectedAssets = component.get("v.selectedAssets");
        console.log("Selected assets:");
        console.log(selectedAssets);
        var assets = "";
        
        for(var i = 0; i < selectedAssets.length; i++){
        	assets = assets + selectedAssets[i].Id + "#";
        }
        component.set("v.assets", assets);
        
        var setWorkOrderLineItems = component.get("c.SetWorkOrderLineItems");
        
        setWorkOrderLineItems.setParams({
            workOrderId: component.get("v.recordId"),
            assets: component.get("v.assets")
        });
        
        setWorkOrderLineItems.setCallback(this, function(data) 
        {
            helper.showSuccessToast();
            console.log('Entering - setWorkOrderLineItems');
            var response = data.getReturnValue();
            
            $A.get('e.force:refreshView').fire();
        });
        
        let button = component.find('createDispatchBtn');
        button.set('v.disabled', true);
        
        component.set("v.hideCheckboxes", true);
        
		$A.enqueueAction(setWorkOrderLineItems);
        //$A.enqueueAction(callWebService);
    },
    
    handleSelect: function (component, event, helper) {
        componentTest = component.find("orderItemsTable");
        console.log(componentTest);
             
         test = component.getElementById('hideCheckboxes').value;
        alert(test);
        
        var selectedRowsIds = ["02in0000008JVfxAAG"];
        //var selectedRowsIds = {Id:"02in0000008JVfxAAG"};
        
        component.set("v.selectedRows", selectedRowsIds);
        //alert('handleSelect');
        var rows = ['02in0000008J881AAC'];
        //component.set('v.selectedRows', rows);
        //
        //var selectedRows = event.getParam('selectedRows');
        
        //console.log(selectedRows);
    	// Display that fieldName of the selected rows
    	//for (var i = 0; i < selectedRows.length; i++){
       // 	alert("You selected: " + selectedRows[i].opportunityName);
    //	}
    }
    
})