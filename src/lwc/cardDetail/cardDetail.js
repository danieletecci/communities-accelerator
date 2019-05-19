import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import ASSETS from '@salesforce/resourceUrl/Assets';

export default class CardDetail extends LightningElement {

    @api details;

    // Best practice to know if the device is mobile.
    mobile = navigator.userAgent.toLowerCase().includes('mobi');

    renderedCallback() {
        loadStyle(this, ASSETS + '/Assets/Styles/cardDetailExternalStyles.css');
    }

    get isMobile() {
        return this.mobile ? 'mobile' : '';
    }

    get isEvent() {
        return this.details.type === 'Event';
    }

    get eventClass() {
        return this.isEvent ? 'date-container event' : 'date-container';
    }

    get bodyOnly() {
        return this.details.layout === 'Body Only';
    }
}