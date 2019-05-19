import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import ASSETS from '@salesforce/resourceUrl/Assets';


export default class DatatableRow extends LightningElement {
    @api column;
    @api row;
    @api colname;
    @api isDesktop;
    @api hideColumns;
    @api hideValues;

    connectedCallback() {
        loadStyle(this, ASSETS + '/Assets/Styles/datatableRowExternalStyles.css');

    }
    get rowValue(){
        var row = JSON.parse(JSON.stringify(this.row));
        return row[this.column] ? row[this.column] : "-";
    }
}