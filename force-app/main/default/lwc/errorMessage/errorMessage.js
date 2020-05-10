import { LightningElement, api, track } from 'lwc';

export default class ErrorMessage extends LightningElement {
    @api genericErrorMessage;
    @track _errors;

    @api
    get errors() {
        return this._errors;
    }
    set errors(value) {
        this.setAttribute("errors", value);
        if (!value) {
            this._errors = undefined;
        } else if (value[0] && value[0].message) {
            this._errors = value;
        } else {
            this._errors = [];
        }
        if (value) {
            console.log('error', JSON.stringify(value, null, 2));
        }
    }
}