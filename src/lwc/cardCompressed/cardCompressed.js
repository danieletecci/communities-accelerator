import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import ASSETS from '@salesforce/resourceUrl/Assets';

export default class CardCompressed extends LightningElement {
    @api config; 
    //{id:string ,
    // type:sting,
    // headerText:string,
    // title:string,
    // imgSrc:string,
    // footer: { 
    //  description:string
    //  }
    //}

    connectedCallback() {
        loadStyle(this, ASSETS + '/Assets/Styles/cardCompressedExternalStyles.css');
    }

    navigateToDetail() {
        const values = JSON.stringify({ 
            id: this.config.externalId,
            url: this.config.navigateUrl,
            sfid: this.config.id
        });
        const naivgateEvent = new CustomEvent('navigatetodetail', { bubbles: true, composed: true, detail: { values } });
        this.dispatchEvent(naivgateEvent);
    }

    get headerClass() {
        return this.config.type === 'Event' ? 'header head-event' : 'header head-news'; 
    }
    
    get isEvent() {
        return this.config.type === 'Event';
    }

    get isEventRelated() {
        return this.config.type === 'EventsRelated';
    }

    get headerClassRelated() {
        return this.config.type === 'EventsRelated' ? 'header head-event' : 'header head-news'; 
    }
}