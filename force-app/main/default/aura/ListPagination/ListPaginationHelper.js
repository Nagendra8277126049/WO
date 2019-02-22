({
	toggleNextPage : function(component, event, helper) {
		var nxtPage = component.find("nextPage");
		if(component.get("v.maxPageNumber") == '' || component.get("v.currentPageNumber") >= component.get("v.maxPageNumber")){
        	$A.util.addClass(nxtPage, 'hideMeNChild');
        }
        else{
            $A.util.removeClass(nxtPage, 'hideMeNChild');
        }
	},
    togglePrevPage : function(component, event, helper) {
        var prvPage = component.find("prevPage");
		if(component.get("v.currentPageNumber") <= "1"){
            $A.util.addClass(prvPage, 'hideMeNChild');
        }
        else{
            $A.util.removeClass(prvPage, 'hideMeNChild');
        }
    }
})