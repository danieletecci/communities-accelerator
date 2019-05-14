import { LightningElement, api } from 'lwc';
import { formatContentCompressed } from 'c/contentFormatter'


export default class CardCompressedFormatter extends LightningElement {
    @api content;
    @api formatedContent;
    @api type;
    @api formfactor;
   
    renderedCallback() {
        if(!this.formatedContent){
            this.formatedContent = formatContentCompressed(this.content, this.type, this.formfactor);
        }
    }
}