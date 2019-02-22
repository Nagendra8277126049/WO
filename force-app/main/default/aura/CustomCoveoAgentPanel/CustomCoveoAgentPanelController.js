({
    init : function(component, event, helper) {
        var panel = component.find('panel');
       var searchUi = panel.get('v.searchUI')
        
        helper.getUserLanguage(component, event, helper);
        
        searchUi.registerBeforeInit(function(searchUiCmp, root, Coveo) {
            var userLanguage = component.get('v.userLanguage');
            
            searchUi.setSearchInterfaceOptions({
/*
                ResultLink: {
                    onClick: function(e, result) {
                        if(result.raw.sfid || result.raw.sfcaseid) {
                            component.openTab(null, result.raw.sfid || result.raw.sfcaseid)
                        } else {
                            window.open(result.clickUri);
                        }
                    }
                },
*/
                Facet : {
                    valueCaption : {
                        'Dell - Inquira' : 'OKB'
                    }
                }
            })
            
            searchUi.proxyAddEventListener("preprocessResults", function(e, args) {
                var caseStatus = "";
                var record = component.get("v.record");
                if (record && record.fields && record.fields.Status) {
                    caseStatus = record.fields.Status.value || "";
                }
                args.results.results.forEach(function(result) {
                    result.raw.currentcaserecordstatus = caseStatus;
                });
            });
            
            searchUi.proxyAddEventListener("doneBuildingQuery", function(e, data) {
                var record = component.get("v.record");

                if (typeof data.queryBuilder.context == "undefined") {
                    data.queryBuilder.context = {};
                }

                if (record && record.fields && record.fields.Product__c) {
                    data.queryBuilder.context['Case_Product__c'] = record.fields.Product__c.value || "";
                }
                if (record && record.fields && record.fields.Model__c) {
                    data.queryBuilder.context['Case_Model__c'] = record.fields.Model__c.value || "";
                }
                if (userLanguage) {
                    data.queryBuilder.context['User_Language'] = userLanguage.split('_')[0] || "";
                }
            });
/*            
            Coveo.DomUtils.getQuickviewHeader = function (result, options, bindings) {
                var date = '';
                var header = Coveo.$$('div');
                header.el.innerHTML = "<div class='coveo-quickview-right-header'>\n        <span class='coveo-quickview-time'>" + date + "</span>\n        <span class='coveo-quickview-close-button'>\n          <span class='coveo-icon coveo-sprites-common-clear'></span>\n        </span>\n      </div>\n      <div class='coveo-quickview-left-header'>\n <a class='coveo-quickview-pop-up-reminder' target='_blank' style='pointer-events: none; cursor: text;'> " + (options.title || '') + "</a>\n      </div>";
                new Coveo[Coveo['Salesforce'] ? 'ResultLink' : 'ResultLink'](header.find('.coveo-quickview-pop-up-reminder'), undefined, bindings, result);
                return header;
            };
*/            
        });
    },
/*    
    openTab: function(component, event, helper) {
        console.log("debugging  ================= ")
        var params = event.getParams().arguments;
        helper.openNewTab(params.url, params.sfid);
    },
*/
    handleRecordUpdated: function(component, event, helper) {
                                var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            // record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.");
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    }
})