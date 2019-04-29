import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';


export default class datatableRow extends LightningElement {
    @api column;
    @api row;
    @api colname;

    connectedCallback() {
        loadStyle(this, 'sfsites/c/resource/Assets/Assets/Styles/datatableRowExternalStyles.css');

    }
    get rowValue(){
        var row = JSON.parse(JSON.stringify(this.row));
        return row[this.column] ? row[this.column] : "-";
    }
}