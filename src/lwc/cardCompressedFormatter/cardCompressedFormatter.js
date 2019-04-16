import { LightningElement, api } from 'lwc';
import { formatContentCompressed } from 'c/contentFormatter'


export default class CardCompressedHoc extends LightningElement {
    @api content;
    @api formatedContent;
    @api type;
   
    renderedCallback() {
        if(!this.formatedContent){
            this.formatedContent = formatContentCompressed(this.content, this.type);
        }
    }
}