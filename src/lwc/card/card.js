import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import ASSETS from '@salesforce/resourceUrl/Assets';

export default class Card extends LightningElement {
    @api config;  
    @api variant;
    @api viewmode;
    @api formfactor; 
    @track orientation;

    connectedCallback() {
        window.addEventListener("orientationchange", () => this.handleOrientation());
        loadStyle(this, ASSETS + '/Assets/Styles/cardExternalStyles.css');

    }

    renderedCallback() {
        this.handleOrientation(); 
    }

    disconnectedCallback() {
        window.removeEventListener("orientationchange");
    }

    handleOrientation() {
        let varFormFactor = this.formfactor ? this.formfactor.toLowerCase() : 'desktop';
        if(varFormFactor === 'desktop') {
            /*if(this.viewmode === 'Landscape') {
                this.orientation = varFormFactor + '-portrait';
            } else {
                this.orientation = varFormFactor + '-landscape';
            }*/
            this.orientation = varFormFactor + '-landscape';
        } else  if(varFormFactor === 'tablet') {
            this.orientation = varFormFactor + '-portrait';
        } else {
            // PORTRAIT
            if(screen.orientation.angle === 0) {
                this.orientation = varFormFactor + '-portrait';
            } else {
                this.orientation = varFormFactor + '-landscape';
            }
        }
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

    get isEvent() {
        return this.config.type === 'EventList';
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

    get isContentLandscapeInDesktop() {
        //return this.formfactor === 'DESKTOP' && this.viewmode === 'Landscape';
        return false;
    }

    get isLandscapeNotInDesktopOrIsNotTablet() {
        return (this.formfactor !== 'DESKTOP' && screen.orientation.angle === 90) && (this.formfactor !== 'TABLET');
    }

    get show() { 
        return /*this.viewmode &&*/ this.formfactor;
    }

    get containerClass() {
        let typeClass = this.orientation;
        return `container-${typeClass}`;
    }

    get bodyClass() {
        let typeClass = this.orientation;
        return `body body-${typeClass}`;
    }

    get imgContainerClass() {
        let typeClass = this.orientation;
        return `img-container-${typeClass}`;
    }

    get imgClass() { 
        let typeClass = this.orientation;
        return `img-${typeClass}`; 
    }

    get imgClassEvent() { 
        let typeClass = this.orientation;
        return `img-${typeClass}-event`; 
    }

    get footerClass() {
        let typeClass = this.orientation;
        return `footer-${typeClass}`;
    }

    get containerGridClass() {
        let typeClass = this.orientation;
        return `container-${typeClass} slds-grid`;
    }

    get locationHref() {
        return 'https://www.google.com/maps/search/' + this.config.footer.description.descSecondary;
    }
}