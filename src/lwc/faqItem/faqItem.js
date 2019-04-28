import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import Style from '@salesforce/resourceUrl/Assets';

export default class faqItem extends LightningElement {
    @api items;

    renderedCallback() {
        loadStyle(this, 'fsites/c/resource/Assets/Assets/Styles/faqItemExternalStyles.css');

    }

    openAccordion(){
        var button = this.template.querySelector("button.btn-accordion");
        var content = this.template.querySelector("div.content-accordion");
        button.classList.toggle("active");
        content.classList.toggle("scale-out-ver-top");
        content.scrollIntoView();
    }
}