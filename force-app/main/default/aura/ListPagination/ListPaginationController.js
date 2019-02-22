({
    doInit: function(component, event, helper){
        helper.toggleNextPage(component, event, helper);
        helper.togglePrevPage(component, event, helper);
    },
    firstPage: function(component, event, helper) {
        component.set("v.currentPageNumber", 1);
    },
    prevPage: function(component, event, helper) {
        component.set("v.currentPageNumber", Math.max(component.get("v.currentPageNumber")-1, 1));
        helper.toggleNextPage(component, event, helper);
        helper.togglePrevPage(component, event, helper);
    },
    nextPage: function(component, event, helper) {
        component.set("v.currentPageNumber", Math.min(component.get("v.currentPageNumber")+1, component.get("v.maxPageNumber")));
		helper.toggleNextPage(component, event, helper);
        helper.togglePrevPage(component, event, helper);
    },
    lastPage: function(component, event, helper) {
        component.set("v.currentPageNumber", component.get("v.maxPageNumber"));
    }
})