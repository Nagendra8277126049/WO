({
    openNewTab : function(url, sfid) {
        var openInNewTabEvent = $A.get("e.c:OpenInNewTab");
        openInNewTabEvent.setParams({
            url: url ? url.replace(/&/g, "%26") : url,
            recordId: sfid
        })
        openInNewTabEvent.fire();
    }
})