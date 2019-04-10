import { LightningElement, api, wire } from 'lwc';
import General_Search from '@salesforce/label/c.General_Search';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

export default class HeaderListViewPage extends LightningElement {
    @api objectlabel; //Change to @api when Parent Component asign value
    @api filterselected;
    @api filtersstatus;
    @api headerbuttonsprimary;
    @api headerbuttonssecondary;

    //Reference used for the pubsub module
    @wire(CurrentPageReference) pageRef;

    label = {
        General_Search,
    };

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
        const eventDetail = { 
            value : value
        }
        if(typeOfAction === "dispatchEvent"){
            fireEvent(this.pageRef, 'btnheaderlistviewclicked', eventDetail);
        }
        // else if (typeOfAction === "redirect"){
            
        // }
    }
    
    handleOnClickCreateTemplate(event){
        var typeOfAction = event.currentTarget.dataset.typeaction;
        var value = event.currentTarget.dataset.label;
        const eventDetail = { 
            value : value
        }

        if(typeOfAction === "dispatchEvent"){
            fireEvent(this.pageRef, 'btnheaderopencreatetemplate', eventDetail);
        }
        // else if (typeOfAction === "redirect"){
            
        // }
    }

    filterhandler(event) {
        const filters = event.detail;
        this.filterselected = filters;
    }

}