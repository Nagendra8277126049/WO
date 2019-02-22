({
	init : function(component, event, helper) {
		var list = JSON.parse(component.get('v.output') || "[]");
        component.set('v.ItemList', list);
	},
    changeTaxes: function(component, event, helper) {
        var country = event.getSource().get('v.value');
        
        if(country){ 
            var onSuccess = (result)=> component.set('v.countryTaxes', JSON.parse(result));
            var onError = (msg)=> console.log(msg);
            $A.enqueueAction(helper.getTaxesByCountry(component, onSuccess, onError, {"country": country}));
        }
        else{
            component.set('v.countryTaxes', []);
        }
    },
    addItem: function(component, event, helper) {
        var list = component.get('v.ItemList');
        list.push({ item : { description : "", amount :'' }, taxes : [] });

        component.set('v.ItemList', list);
    },
    removeItem : function(component, event, helper) {
        var list = component.get('v.ItemList');
        var index = event.getSource().get("v.name");
        list.splice(index, 1);
        component.set('v.ItemList', list);
    },
    removeTax : function(component, event, helper) {
        var list = component.get('v.ItemList');
        var index = event.getSource().get("v.name").split('-');
        list[index[0]].taxes.splice(index[1], 1);
        component.set('v.ItemList', list);
    },
    addItemTax: function(component, event, helper) {
        var list = component.get('v.ItemList');
        
        var index = event.getSource().get("v.name");
        
        list[index].taxes.push({ description: "", amount: '', taxRate : '', taxType: '' });
        
        component.set('v.ItemList', list);
    },
    flowAction :function(cmp, event, helper) {
        if(!helper.validate(cmp)) return;
        
        helper.serializeItems(cmp);
        
        var settlementAmount = cmp.get('v.inputMaximumAmount');
        var list = cmp.get('v.ItemList');
        
        if(!list.length) {
            helper.setError(cmp, '	Invoice must have items!');
        	return;
        }
        
        var accCalc = (acc, item) => acc + parseFloat(item.amount);
        
        var itemValidation = list.map((elem, index) => {
                return {
                    amount : parseFloat(elem.item.amount) + elem.taxes.reduce(accCalc, 0),
                    duplicatedTaxesMessage : elem.taxes
            			.map(tx=> tx.taxType)
                        .filter( (tx, i, arr) => arr.indexOf(tx) !== i)
                        .reduce((acc,taxType)=> acc + 'Tax '+ taxType +' duplicated inside item '+ (index + 1) +'\n',"")
                }
            })
            .reduce((prev,item) => {
                prev.totalAmount += item.amount;
                prev.duplicatedTaxesMessage += item.duplicatedTaxesMessage;
                return prev;
                
            }, {totalAmount : 0, duplicatedTaxesMessage : ''});
       
        if(settlementAmount != itemValidation.totalAmount){
            helper.setError(cmp, '	Total amount should be equal to settlement amount!');
        	return;
        }
        
        if(itemValidation.duplicatedTaxesMessage){
            helper.setError(cmp, itemValidation.duplicatedTaxesMessage);
        	return;
        }
		
        var country = cmp.get('v.country');
        if(country == 'CA' || country == 'US') cmp.set('v.bankBranch', null);
    
        var actionClicked = event.getSource().getLocalId();
    
        var navigate = cmp.get('v.navigateFlow');
    
        navigate(actionClicked);
   }
})