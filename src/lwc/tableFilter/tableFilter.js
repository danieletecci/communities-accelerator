import { LightningElement, api,track,wire } from 'lwc';
import GeneralShowMore from '@salesforce/label/c.General_ShowMore';
import GeneralDelete from '@salesforce/label/c.General_Delete';
import GeneralView from '@salesforce/label/c.General_View';
import ContentLandingNewFromTemplate from '@salesforce/label/c.ContentLandingNewFromTemplate';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';

export default class TableFilter extends NavigationMixin(LightningElement) {
    @api tabledata; //Change to @api when Parent Component asign value
    @api filtersstatus;
    @api rendertable;

    @track showMore;

    viewLbl;
    deleteLbl;
    createFromTemplateLbl;

    @wire(CurrentPageReference) pageRef;

    constructor(){
        super();
        this.showMore = GeneralShowMore;
        this.viewLbl = GeneralView;
        this.deleteLbl = GeneralDelete;
        this.createFromTemplateLbl = ContentLandingNewFromTemplate;
    }

    showActions(event){
        if(!event.currentTarget.parentElement.classList.contains("slds-is-open")){
            event.currentTarget.parentElement.classList.toggle("slds-is-open");
        }
    }

    hideActions(){
        var divOpen = this.template.querySelector('div.divAction.slds-is-open');
        if(divOpen){
            divOpen.classList.toggle("slds-is-open");
        }
    }

    handleClick(event){
        var child = event.currentTarget.children[0];
        var label;
        var id;
        
        this.hideActions();

		if(child){
            if(child.tagName === "SPAN"){
                label = child.dataset.label;
                id = child.dataset.id;
            }
		}

        switch (label) {
            case this.viewLbl:
                this.navigateToWebPage("/" + id);
                break;
            case this.deleteLbl:
                this.deleteContent(id);
                break;
            case this.createFromTemplateLbl:
                this.createContentFromLanding(id);
                break;
            default:
        }
    }

    navigateToWebPage(url) {
        this.hideActions();
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url
            }
        });
    }

    deleteContent(idContent){
        var value = idContent;
        const deleteContentRecord = new CustomEvent('deletecontentrecord', {
        detail: value
        });
        this.dispatchEvent(deleteContentRecord);
        this.hideActions();
    }
    
    createContentFromLanding(idContent){
        var value = idContent;
        const createContent = new CustomEvent('createcontentrecord', {
        detail: value
        });
        this.dispatchEvent(createContent);
        this.hideActions();
    }
}