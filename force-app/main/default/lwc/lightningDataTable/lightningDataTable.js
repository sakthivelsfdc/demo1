import { LightningElement, track } from 'lwc';
import searchAccounts from '@salesforce/apex/AccountController.searchAccount';
import getAccount from '@salesforce/apex/AccountController.getAccount';
import getAllAccount from '@salesforce/apex/AccountController.getAllAccount';

const columnList = [
    {label: 'Id', fieldName: 'Id'},
    {label: 'Name', fieldName: 'Name'},
    {label: 'Website', fieldName: 'Website'},
    {label: 'Industry', fieldName: 'Industry'}
];

export default class LightningDataTable extends LightningElement {
    @track accountList;
    @track columnList = columnList;
    @track noRecordsFound = true;

    connectedCallback(){
        this.defaultFetchRecentAccounts();
    }

    defaultFetchRecentAccounts() {
        getAccount ()
        .then(result => {
            this.accountList = result;
            this.noRecordsFound = false;
        })
        .catch(error => {
            console.log('error::'+error);
            this.noRecordsFound = true;
        })
    }

    findAccountResult(event) {
        const accName = event.target.value;

        if(accName) {
            searchAccounts ( {accName}) 
            .then(result => {
                this.accountList = result;
                this.noRecordsFound = false;
            })
        } else {
            this.accountList = undefined;
            this.noRecordsFound = true;
        }
    }

    showAll(event) {

        var inputCmp = this.template.querySelector(".inputCheckbox");
        var checkboxSelection = inputCmp.checked;
        console.log('checkboxSelection::'+checkboxSelection);

        getAllAccount ()
        .then(result => {
            this.accountList = result;
            this.noRecordsFound = false;
        })
        .catch(error => {
            console.log('error::'+error);
            this.noRecordsFound = true;
        })
    }
}