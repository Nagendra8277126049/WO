({

  tabInfo : function(component) {
    try{
      var workspaceAPI = component.find("workspace");
      workspaceAPI.getEnclosingTabId().then(function(tabId) { // 5129720 
        var focusedTabId = tabId;
        workspaceAPI.setTabLabel({
          tabId: focusedTabId,
          label: "Entitlements"
        });

        workspaceAPI.setTabIcon({
          tabId: focusedTabId,
          icon: "standard:entitlement",
          iconAlt: "Entitlements"
        });
      })
      .catch(function(error) {
          this.showToast(component,'Error', error, "Error");
      });
    }catch(Err){
      this.showToast(component,'Error', $A.get("$Label.c.EntitlementsDashboardErrorMessage"), "Error");
    }
  },
})