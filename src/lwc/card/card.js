import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import Style from '@salesforce/resourceUrl/Assets';

export default class Card extends LightningElement {
    @api config; 
    //{id:string ,
    // externalId,
    // navigateUrl,
    // type:sting,
    // headerText:string,
    // title:string,
    // bodyText:string,
    // imgSrc:string,
    // footer: { 
    //  description: { 
    //           descPrimary:string,
    //           descSecondary:string
    //       },
    //  controls: [{ label:string, action:string, icon:boolean }]
    //  }
    //}
    @api variant;
    @track orientation;

    constructor() {
        super();
        this.handleOrientation();
    }

    connectedCallback() {
        window.addEventListener("orientationchange", () => this.handleOrientation());
        loadStyle(this, Style + '/Assets/Styles/roboto.css');
        loadStyle(this, 'sfsites/c/resource/Assets/Assets/Styles/roboto.css');
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

    navigateToDetail() {
        const values = JSON.stringify({ id: this.config.externalId, url: this.config.navigateUrl});
        const naivgateEvent = new CustomEvent('navigatetodetail', { bubbles: true, composed: true, detail: { values } });
        this.dispatchEvent(naivgateEvent);
    }

    get isEvent() {
        return this.config.type === 'Event'
    }

    get headerClass() {
        return this.isEvent? 'header head-event' : 'header head-news'; 
    }

    get primaryDescClass() {
        return this.isEvent? 'desc-normal' : 'desc-highlight'; 
    }

    get secondaryDescClass() {
        return this.isEvent? 'desc-highlight' : 'desc-normal'; 
    }

}