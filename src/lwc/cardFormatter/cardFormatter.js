import { LightningElement, api, wire } from 'lwc';
import { formatContent } from 'c/contentFormatter'
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class CardFormatter extends NavigationMixin(LightningElement) {
    @api content;
    @api formatedContent;
    @api type;
    @api urlToNavigate;
    @api parentComponentId;

    @wire(CurrentPageReference)
    currentPageReference;

    renderedCallback() {
        if(!this.formatedContent){
            this.formatedContent = formatContent(this.content, this.type);
        }
    }
}