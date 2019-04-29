import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';


export default class faqItem extends LightningElement {
    @api items;

    renderedCallback() {
        loadStyle(this, 'sfsites/c/resource/Assets/Assets/Styles/faqItemExternalStyles.css');

    }

    openAccordion(){
        var button = this.template.querySelector("button.btn-accordion");
        var content = this.template.querySelector("div.content-accordion");
        button.classList.toggle("active");
        content.classList.toggle("scale-out-ver-top");
        content.scrollIntoView();
    }
}