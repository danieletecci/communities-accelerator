import { LightningElement, api, wire, track } from 'lwc';
import General_Search from '@salesforce/label/c.General_Search';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';
import HeaderComponentTitle from '@salesforce/label/c.HeaderComponentTitle';

export default class HeaderListViewPage extends LightningElement {
    @api objectlabel; //Change to @api when Parent Component asign value
    @api filterselected;
    @api headerbuttonsprimary;
    @api headerbuttonssecondary;
    @track HeaderComponentTitle;

    //Reference used for the pubsub module
    @wire(CurrentPageReference) pageRef;

    label = {
        General_Search,
    };

    constructor(){
        super();
        this.HeaderComponentTitle = HeaderComponentTitle;
    }

    searchEnter(event) {
        if (event.which === 13 || event.keyCode === 13) {
            this.searchOnFocusOut(event);
        }
    }

    searchOnFocusOut(event){
        let value = JSON.stringify({ 
            'value': event.target.value
        });
        this.eventDispatch(value);
    }
    
    searchOnIconClick(event){
        let value = JSON.stringify({ 
            'value': event.currentTarget.previousSibling.value
        });
        this.eventDispatch(value);
    }

    eventDispatch(value){
        const filterItemSelected = new CustomEvent('searchenter', {bubbles:"true",
        detail: {value}
        });
        this.dispatchEvent(filterItemSelected);
    }

    handleOnClick(event){
        var typeOfAction = event.currentTarget.dataset.typeaction;
        var value = event.currentTarget.dataset.label;

        if(typeOfAction === "dispatchEvent"){
            fireEvent(this.pageRef, 'btnheaderlistviewclicked', value);
        }
        // else if (typeOfAction === "redirect"){
            
        // }
    }
    
    handleOnClickCreateTemplate(event){
        var typeOfAction = event.currentTarget.dataset.typeaction;
        var value = event.currentTarget.dataset.label;

        if(typeOfAction === "dispatchEvent"){
            fireEvent(this.pageRef, 'btnheaderopencreatetemplate', value);
        }
        // else if (typeOfAction === "redirect"){
            
        // }
    }
}