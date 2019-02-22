({
	getItems : function(component, event, helper) {
        component.set("v.isLoading", true);
        
		component.set('v.columns', [
            {label: 'Order #', fieldName: 'orderNumber', type: 'text', initialWidth: 120, cellAttributes: { class: {fieldName: 'category'}, iconName:'utility:record', iconPosition: 'left' }},
            {label: 'Tie #', fieldName: 'Tie_Number__c', type: 'text', initialWidth: 80}, 
            {label: 'Sku #', fieldName: 'SKU_Number__c', type: 'text', initialWidth: 100},
            {label: 'Sku Description', fieldName: 'SKU_Description__c', type: 'text'},
            {label: 'Quantity', fieldName: 'Quantity', type: 'number', initialWidth: 100},
            {label: 'Item Class/LOB Description', fieldName: 'classLobDescription', type: 'text'}
        ]);
        
        var getOrderItems = component.get("c.GetOrderItems");
               
        getOrderItems.setParams({
            projectId: component.get("v.recordId"),
            filterCriteria: component.find('enter-search').get('v.value')
        });
        
        getOrderItems.setCallback(this, function(data) 
        {
            var orderItems = data.getReturnValue();
            
            orderItems.forEach(function(item) { 
                var findOrderItem = function (hasLobDescription) {
                    return orderItems.find(function(element) {
                		var criteria = element.Order.OrderNumber__c === item.Order.OrderNumber__c && 
                           element.Tie_Number__c === item.Tie_Number__c && 
                           element.SKU_Number__c !== item.SKU_Number__c;
                                           
                        if (hasLobDescription) {
                    		criteria = criteria && (!element.LOB_Description__c || element.LOB_Description__c === null);
                    	}
                    	else {
                        	criteria = criteria && element.LOB_Description__c && element.LOB_Description__c !== null;
                    	}
                    	
                    	return criteria;
                  	});
                };

                if (item.LOB_Description__c) {
                	var orderItem = findOrderItem(true);
                	
                    item.category = orderItem ? 'green' : 'yellow';
                }
                else {
                    var orderItem = findOrderItem(false);

                    item.category = orderItem ? 'green' : 'red';
               	}
                
            	item.orderNumber = item.Order.OrderNumber__c; 
            	item.classLobDescription = item.LOB_Description__c || item.Item_Class_Description__c;
            });
            
            component.set("v.OrderItems", orderItems);
            component.set("v.isLoading", false);
        });
        
        $A.enqueueAction(getOrderItems);
    },
    
    handleKeyUp: function (component, event) {
        var isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            var queryTerm = component.find('enter-search').get('v.value');
            var getItems = component.get('c.getItems');
        	$A.enqueueAction(getItems);
        }
    },
    downloadCsv: function(component, event, helper) {
        var orderItems = component.get('v.OrderItems');
        
        var csv = helper.convertArrayOfObjectsToCSV(component, orderItems);   
        
        if (csv == null) {
            return;
        }
        
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'ExportData.csv';
        document.body.appendChild(hiddenElement); // Required for FireFox browser
    	hiddenElement.click(); // using click() js function to download csv file        
    }
})