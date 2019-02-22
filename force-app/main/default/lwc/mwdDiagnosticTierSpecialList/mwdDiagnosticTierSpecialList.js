import { LightningElement,wire,track } from 'lwc';
import getSpecialIssues from '@salesforce/apex/MWDDiagnosticTeirController.getSpecialIssues';

export default class MwdDiagnosticTierSpecialList extends LightningElement {
    @track specialIssues;
    @wire(getSpecialIssues, {})
    wiredSpecialIssues({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.specialIssues = data;
        }
    }
    get options() {
        var options = [];
        var specialIssue = this.specialIssues;
        if(specialIssue){
            specialIssue.forEach(function (val) {
                if(val.Special_Issue__c){
                    options.push(
                        { label: val.Special_Issue__c, value: val.Id }
                    );
                }
            });
        }
        return options;
    }
    handleChange(event) {
        var filters;
        var i = 0;
        var specialIssue = this.specialIssues;
        this.value = event.detail.value;
        if(this.value){
            for (; i < specialIssue.length; i++) {
                if(specialIssue[i].Id === this.value){
                    filters = {
                        teir1: specialIssue[i].Tier_1__c,
                        teir2: specialIssue[i].Tier_2__c,
                        teir3: specialIssue[i].Tier_3__c,
                        reasonCode: specialIssue[i].Reason_Code__c,
                        specialIssue: specialIssue[i].Special_Issue__c
                    };
                    break;
                }
            }
        }
        const selectChangeEvent = new CustomEvent('selectedItems', {
            detail: { filters },
        });
        // Fire the custom event
        this.dispatchEvent(selectChangeEvent);
    }
}