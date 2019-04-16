import { LightningElement, api } from 'lwc';

export default class faqItem extends LightningElement {
    @api items;

    openAccordion(){
        var button = this.template.querySelector("button.btn-accordion");
        var content = this.template.querySelector("div.content-accordion");
        button.classList.toggle("active");
        content.classList.toggle("scale-out-ver-top");
        content.scrollIntoView();
    }
}