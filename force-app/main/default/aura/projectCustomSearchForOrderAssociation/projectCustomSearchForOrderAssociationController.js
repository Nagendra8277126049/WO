({
    Search: function(component, event, helper) {
            helper.searchHelper(component, event);
    },
    
    init: function (component, event, helper) {

        component.set('v.columns', [
            {label: 'Project Name', fieldName: 'Name', type: 'text', sortable: true},
            {type: 'button', initialWidth: 50, typeAttributes:
                { 
                    label: { fieldName: 'actionLabel'}, 
                    title: 'Click to Associate', 
                    variant: "base",
                    name: 'associateOrder', 
                    iconName: 'utility:link', 
                    disabled: {fieldName: 'actionDisabled'}}}
        ]);
        
       	var orderIds = component.get("v.orderIds");
        if(orderIds.length === 0)
            orderIds.push(component.get("v.recordId"));
        
        component.set('v.orderIds', orderIds);
        
       	helper.getOrderNumbers(component, event);
    },
    
    updateColumnSorting: function (component, event, helper) {
        // We use the setTimeout method here to simulate the async
        // process of the sorting data, so that user will see the
        // spinner loading when the data is being sorted.
        setTimeout(function() {
            var fieldName = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
            component.set("v.sortedBy", fieldName);
            component.set("v.sortedDirection", sortDirection);
            helper.sortData(component, fieldName, sortDirection);
        }, 0);
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'associateOrder':
                helper.associationHelper(component, row);
                break;
            default:
                break;
        }
    }
})