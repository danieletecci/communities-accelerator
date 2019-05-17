import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import ViewMoreLabel from '@salesforce/label/c.CardsViewMore';


export default class CardList extends LightningElement {
    @api contents;
    @api type;
    @api title;
    @api numberofcards;
    @api numberofcolumns;
    @api showpaging;
    @api pagingtype;
    @api pagenumbers;
    @api urlToNavigate;
    @api viewmode;
    @api formfactor;
    @api allContentsQuantity;

    viewMoreLabel;
    mobile;

    constructor(){
        super();
        this.viewMoreLabel = ViewMoreLabel;
        this.mobile = navigator.userAgent.toLowerCase().includes('mobi');
    }
    connectedCallback() {
        loadStyle(this, 'sfsites/c/resource/Assets/Assets/Styles/cardListExternalStyles.css');
    }

    get containerClass() {
        let iscarrousel = this.isCarrousel ? ' carrousel': '';
        return this.mobile ?  'list-container' + iscarrousel : 'list-container slds-grid slds-wrap' + iscarrousel;
    }
    get cardWrapperClass() {
        if(this.formfactor === 'TABLET')
            return 'slds-col slds-size_2-of-4';
        return this.mobile ? 'slds-col slds-size_4-of-4' : 'slds-col slds-size_1-of-' + this.numberofcolumns;
    }
    
    get isCarrousel() {
        let iscarousel = this.pagingtype === 'Carousel' && this.showpaging && !this.mobile ;
        return iscarousel;
    }

    get isViewMoreAndHasHidedElements() {
        let isViewMore = (this.pagingtype === 'View More' && this.showpaging) || this.mobile;
        let hasHiddenElements = this.contents.length < this.allContentsQuantity;
        return isViewMore && hasHiddenElements;
    }
    
    get isPagingBottom() {
        let ispagingbottom = this.pagingtype === 'Paging Bottom' && this.showpaging && !this.mobile;
        return ispagingbottom;
    }

    DispatchNextEvent(){
        const nextPageEvent = new CustomEvent('nextpage');
        this.dispatchEvent(nextPageEvent);
    }

    DispatchPrevEvent(){
        const prevPageEvent = new CustomEvent('prevpage');
        this.dispatchEvent(prevPageEvent);
    }

    DispatchGoToPageEvent(event){
        var numberofpage = event.currentTarget.value;
        const goToPageEvent = new CustomEvent('gotopage', {detail: {numberofpage}});
        this.dispatchEvent(goToPageEvent);
    }

    DispatchShowMoreEvent(){
        const nextPageEvent = new CustomEvent('showmore');
        this.dispatchEvent(nextPageEvent);
    }

    get spacerClass() {
        let typeClass = 'desktop';
        if(this.formfactor)
            typeClass = this.formfactor.toLowerCase();

        return `spacer-${typeClass}`;
    }
}