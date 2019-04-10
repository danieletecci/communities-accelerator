import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

export default class TabItem extends LightningElement {
    @api item;
    @api index;
    //Selected item index
    @api activeIndex;
    //Reference used for the pubsub module
    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        //Check if its default and fires the click event
        if(this.item.defaultValue === 'true') {
            this.handleClick();
        }
    }
    //Fires an event to select the item
    handleClick() {
        const detail = { 
            index: this.index,
            tab: this.item
        }
        fireEvent(this.pageRef, 'tabItemClick', detail);
    }
    //Getter to calculate the classnames
    get classes() {
        return this.activeIndex === this.index.toString() ? "btn-tab-item slds-truncate active" : "btn-tab-item slds-truncate";
    }
}