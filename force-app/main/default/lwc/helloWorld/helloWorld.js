import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

//export default class HelloWorld extends LightningElement {
export default class HelloWorld extends NavigationMixin(LightningElement) {

    greeting = 'World';
    changeHandler(event) {
        this.greeting = event.target.value;
    }

    handleClick(event) {
        console.log('handleClick::');
        const defaultValues = encodeDefaultFieldValues({
            AccountId: '0012v0000308eC9AAI',
            FirstName: 'Sakthivel',
            LastName: 'Madesh',
            LeadSource: 'Other',
            Phone: '0404833600'
        });

        console.log(defaultValues);

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });

    }
}