({
    doInit : function (component, event, helper){
       //helper.getCallTransAttrRecId(component, event);
        console.log("Called Component Rec ID in Init method>>>>"+component.get("v.ctrRecId"));
     },
    handleLoad : function (component, event , helper){        
       $A.util.addClass(component.find("Category"), "customRequired");
       $A.util.addClass(component.find("Detail"), "customRequired");
       $A.util.addClass(component.find("LocalChannel"), "customRequired");
       $A.util.addClass(component.find("ProductLine"), "customRequired");
       $A.util.addClass(component.find("Language"), "customRequired");     
   },
    closeFocusedTab : function(component, event, helper) {
        helper.handleCloseTab(component, event);
    },
   handleSuccess : function (component, event , helper){
        helper.callBRE(component, event);
       //Finally close the tab
       // helper.handleCloseTab(component, event);
   },
   transferTypeChange : function (component, event, helper){
      helper.showTransferType(component, event);
   },

})