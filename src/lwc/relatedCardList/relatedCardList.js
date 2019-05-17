import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';


export default class RelatedCardList extends LightningElement {
    @api contents;
    @api type;
    @api formfactor;
    @track orientation;
    mobile = navigator.userAgent.toLowerCase().includes('mobi');

    constructor() {
        super();
        this.handleOrientation();
    }

    connectedCallback() {
        window.addEventListener("orientationchange", () => this.handleOrientation());
        loadStyle(this, '/sfsites/c/resource/Assets/Assets/Styles/relatedCardListExternalStyles.css');
    }
    disconnectedCallback() {
        window.removeEventListener("orientationchange")
    }

    handleOrientation() {
        if(screen.orientation.angle === 0) {
            this.orientation = true
        } else {
            this.orientation = false;
        }
    }

    get columnWidth() {
        return this.mobile ? this.orientation ? 'slds-col slds-size_4-of-4' : 'slds-col slds-size_2-of-4 column-spacer' : 'slds-col slds-size_1-of-4 card-padding';
    }

    get typeWrapper() {
        //return this.type.toLowerCase() + 's';
        if(this.type === 'ArticlesRelated')
            return 'news';
        else if(this.type === 'EventsRelated')
            return 'events';
        else
            return this.type.toLowerCase() + 's';
    }
    
}