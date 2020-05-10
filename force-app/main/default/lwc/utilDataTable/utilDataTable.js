import { LightningElement, api, track } from 'lwc';

export default class UtilDataTable extends LightningElement {
    columns;
    @track data;
    @track noRecord;
}