import { LightningElement, api } from 'lwc';

export default class CardList extends LightningElement {
    @api contents;
    @api type;
    @api title;
    @api numberofcards;
    @api urlToNavigate;

    get containerClass() {
        let mobile = navigator.userAgent.toLowerCase().includes('mobi');
        return mobile ?  'list-container' : 'list-container slds-grid slds-wrap';
    }
    get cardWrapperClass() {
        let mobile = navigator.userAgent.toLowerCase().includes('mobi');
        return mobile ? '' : `slds-col slds-size_${12 / this.numberofcards < 3? '3' : 12 / this.numberofcards}-of-12`;
    }
}