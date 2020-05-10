import { LightningElement, track, api, wire } from 'lwc';
import getContentDocumentList from '@salesforce/apex/generateStoneWebPage.fetchContentDocument';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { getPicklistValues, getObjectInfo  } from 'lightning/uiObjectInfoApi';
import CONTENT_OBJECT from '@salesforce/schema/ContentVersion';
import ID_FIELD from '@salesforce/schema/ContentVersion.Id';
import CATEGORY_FIELD from '@salesforce/schema/ContentVersion.Category__c';
import { CurrentPageReference } from 'lightning/navigation';
export default class GenerateStoneWebPage extends LightningElement {
    @api recordId;
    @track documentList = [];
    @track documentSecondList = [];

    @track loaded = true;
    @track documentListFirstScreen = false;
    @track documentListSecondScreen = false;
    @track displayConfirmMessage = false;

    options = {};
    picklistInfo;
    dragIndex = -1;

    @wire(CurrentPageReference) pageRef;

    //To Get the ContentVersion Category Picklist Value
    @wire(getObjectInfo, { objectApiName: CONTENT_OBJECT })
    objectInfoContentVersion;
    @wire(getPicklistValues, { recordTypeId: '$objectInfoContentVersion.data.defaultRecordTypeId', fieldApiName: CATEGORY_FIELD})
    CategoryPicklistValues;

    connectedCallback() {
        console.log('connectedCallback');
        this.loaded = true;
        this.documentListFirstScreen = true;
        if(this.recordId) {
            this.getContentDocument(this.recordId);
        }
    }

    handleondragstart(event) {
        console.log('handleondragstart TargetID::',event.currentTarget.id);
        console.log('handleondragstart TargetID::',event.detail);
        console.log('handleondragstart TargetID::',event.id);
    }

    handleondrop(event) {
        console.log('handleondrop TargetID::',event.currentTarget.id);
        console.log('handleondrop TargetID::',event.detail);
        console.log('handleondrop TargetID::',event.id);
    }

    handleBackPage() {
        this.displayConfirmMessage = false;
        this.documentListSecondScreen = false;
        this.getContentDocument(this.recordId);
        this.documentListFirstScreen = true;
    }
    handlePushWebsite() {
        this.displayConfirmMessage = true;
    }
    handleCancel() {
        this.displayConfirmMessage = false;
    }
    handlePushingToWebsite() {
        this.displayConfirmMessage = false;
    }
    
    updateDocumentCategory(event) {
        this.displayConfirmMessage = false;
        event.preventDefault();
        event.stopPropagation();
        const fields = {};
        fields[ID_FIELD.fieldApiName] = event.target.name;
        fields[CATEGORY_FIELD.fieldApiName] = event.target.value;

        const recordInput = { fields };
        updateRecord(recordInput);
    }


    formatBytes(bytes, decimals = 2) {
        if (bytes === 0) return '0 Bytes';
    
        const k = 1024;
        const dm = decimals < 0 ? 0 : decimals;
        const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }

    handleSecondPage(event) {
        this.displayConfirmMessage = false;
        this.documentListFirstScreen = false;
        this.loaded = false;
        getContentDocumentList({ recordId: this.recordId})
        .then(result => {  
            console.log('length::'+result.length);
            if (result) {
                this.documentSecondList = [];
                let existingCategory;
                for(let i = 0; i < result.length; i++){
                    existingCategory = false;
                    let categoryName = result[i].Category__c;
                    console.log('categoryName::'+categoryName);
                    let row = {
                        Id : result[i].Id,
                        Title : result[i].Title,
                        Category : result[i].Category__c,
                        CreatedDate : result[i].CreatedDate,
                        FileSize : this.formatBytes(result[i].ContentSize),
                        FileType : result[i].FileType,
                        imageURL : 'https://sakthi-techforceservices-dev-ed--c.documentforce.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId='+result[i].Id+'&operationContext=CHATTER&contentId='+result[i].ContentBodyId
                    };

                    for(let k = 0; k < this.documentSecondList.length; k++) {
                        console.log('doc secondlist::'+this.documentSecondList[k].category);
                        if(this.documentSecondList[k].category === categoryName) {
                            this.documentSecondList[k].categoryResult.push(row);
                            existingCategory = true;
                        }
                    }
                    if(existingCategory === false) {
                        let categoryList = {category: categoryName, categoryResult: [row]};
                        this.documentSecondList.push(categoryList);
                    }
                }

                this.error = undefined;
            } else if (result.error) {
                this.error = result.error;
                this.documentSecondList = undefined;
            } 
            console.log('documentSecondList::'+JSON.stringify(this.documentSecondList));
            this.loaded = true; 
        })  
        .catch(error => {  
            this.error = error;  
            this.loaded = true; 
        });
        
        this.documentListSecondScreen = true;
    }

    getContentDocument(recordId) {
        this.loaded = false;
        getContentDocumentList({ recordId: recordId})
        .then(result => {  
            console.log('result::'+JSON.stringify(result));
            console.log('length::'+result.length);
            if (result) {
                this.documentList = [];
                for(let i = 0; i < result.length; i++){
                    let row = {
                        Id : result[i].Id,
                        Title : result[i].Title,
                        Category : result[i].Category__c,
                        CreatedDate : result[i].CreatedDate,
                        FileSize : this.formatBytes(result[i].ContentSize),
                        FileType : result[i].FileType,
                        imageURL : 'https://sakthi-techforceservices-dev-ed--c.documentforce.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId='+result[i].Id+'&operationContext=CHATTER&contentId='+result[i].ContentBodyId
                    };
                    this.documentList.push(row);
                }
                this.error = undefined;
            } else if (result.error) {
                this.error = result.error;
                this.documentList = undefined;
            }
            console.log('documentList::'+JSON.stringify(this.documentList));
            this.loaded = true; 
        })  
        .catch(error => {  
            this.error = error;  
            this.loaded = true; 
        });
    }

    onDragStart(event){
        event.dataTransfer.dropEffect = "move";
        event.dataTransfer.setData('text', event.target.dataset.id);
    }

    allowDrop(event) {
        event.preventDefault();
    }
    
    onDrop(event) {
        event.preventDefault();
    }

    allowDrop(ev) {
		// on dragover I swap the elements
		this.swapElement(ev.target);

		ev.preventDefault();
		ev.stopPropagation();
		ev.dataTransfer.dropEffect = "move";
		ev.target.classList.add('dragover');
	}

	dropItem(ev) {
        console.log("dropping");
		ev.preventDefault();
		ev.stopPropagation();
        const data = JSON.parse(ev.dataTransfer.getData("text/plain"));
        console.log(data.category);
		this.swapElement(ev.target, data.category);

		ev.dataTransfer.clearData('text/plain');
		this.dragIndex = -1;
		ev.target.classList.remove('dragover');

	}

	swapElement(el, category) {		
		var idxSource = this.dragIndex;
		var idxTarget = parseInt(el.dataset.index);
		this.swapDataElement(idxSource, idxTarget, category);
		this.toggleDraggableClass();

		this.dragIndex = idxTarget;
		
		//this.dispatchEvent(new CustomEvent('listchanged', { /* detail: this.items */ }));
	}
	startDrag(ev) {
        console.log("Starting From : " + parseInt(ev.target.dataset.index) );
		this.dragIndex = parseInt(ev.target.dataset.index);
		ev.dataTransfer.setData('text/plain', JSON.stringify(
            {
                index: this.dragIndex,
                category: ev.target.dataset.category
            }
        ));
		ev.dataTransfer.dropEffect = "move";
	}

	swapDataElement(idx1, idx2, category) {
        console.log("swapping " + idx1 + '  ' + idx2);
        console.log(idx1);
        console.log(idx2);
        if(category){
            let documentSecondList = [];
            console.log(this.documentSecondList);
            this.documentSecondList.forEach(function(group){
                let groupObj = Object.assign({}, group);
                groupObj.categoryResult = [];
                group.categoryResult.forEach(function(result){
                    groupObj.categoryResult.push(Object.assign({}, result));
                });
                documentSecondList.push(groupObj);
            });
            console.log(documentSecondList);
            documentSecondList.forEach(function(group){
                if(group.category === category){
                    let one = group.categoryResult[idx1];
                    group.categoryResult[idx1] = group.categoryResult[idx2];
                    group.categoryResult[idx2] = one;
                }
            });
            this.documentSecondList = documentSecondList;
        }
        console.log(this.documentSecondList);
		//[this._items[idx1], this._items[idx2]] = [this._items[idx2], this._items[idx1]];
	}

	dragLeave(ev) {
		var el = ev.target;
		if (el) {
			el.classList.remove('dragover');
		}
	}

	dragEnd(ev) {
		this.dragIndex = -1;
		this.toggleDraggableClass();
	}

	touchEnd(ev) {
		//console.log('Touch ended. Index: ' + ev.target.index);
		this.dragIndex = -1;	
		this.toggleDraggableClass();
		ev.preventDefault();
		ev.stopPropagation();
	}

	touchStart(ev) {	
		//console.log('Touch started. Index: ' + ev.target.index);
		this.dragIndex = parseInt(ev.target.dataset.index);
		this.toggleDraggableClass();

		ev.preventDefault();
		ev.stopPropagation();
	}

	touchMove (ev) {		
		var el = this.template.elementFromPoint(ev.touches[0].clientX, ev.touches[0].clientY);
		if (el === ev.target){
			console.log('Touch over the same element' );
			return;
		}
		if (el.nodeName !== 'C-DRAGGABLE-ITEM') {
			console.log('Touch over another element: ' + el.nodeName);
			return;
		}

		console.log('Drag index: ' + this.dragIndex);		

		this.swapElement(el);

		ev.preventDefault();
		ev.stopPropagation();
	}

	touchCancel(ev) {
		this.dragIndex = -1;
		ev.preventDefault();
		ev.stopPropagation();

		console.log('Touch canceled');
	}

	toggleDraggableClass() {
		var elms = this.template.querySelectorAll('.c-draggable');
		elms.forEach(el => {
			if (el.dataset && el.dataset.index === this.dragIndex) {
				el.classList.add('dragover');
			} else {
				el.classList.remove('dragover');
			}
		});
	}
}