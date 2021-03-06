import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';


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

    connectedCallback() {
        loadStyle(this, 'sfsites/c/resource/Assets/Assets/Styles/cardListExternalStyles.css');

    }

    get containerClass() {
        let mobile = navigator.userAgent.toLowerCase().includes('mobi');
        let iscarrousel = this.isCarrousel ? ' carrousel': '';
        return mobile ?  'list-container' + iscarrousel : 'list-container slds-grid slds-wrap' + iscarrousel;
    }
    get cardWrapperClass() {
        let mobile = navigator.userAgent.toLowerCase().includes('mobi');
        return mobile ? 'slds-col slds-size_4-of-4' : 'slds-col slds-size_1-of-' + this.numberofcolumns;
    }
    
    get isCarrousel() {
        let iscarousel = this.pagingtype === 'Carousel' & this.showpaging;
        return iscarousel;
    }
    
    get isPagingBottom() {
        let ispagingbottom = this.pagingtype === 'Paging Bottom' & this.showpaging;
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
}