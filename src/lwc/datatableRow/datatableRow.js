import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';


export default class DatatableRow extends LightningElement {
    @api column;
    @api row;
    @api colname;
    @api isDesktop;
    @api hideColumns;
    @api hideValues;

    connectedCallback() {
        loadStyle(this, '/sfsites/c/resource/Assets/Assets/Styles/datatableRowExternalStyles.css');

    }
    get rowValue(){
        var row = JSON.parse(JSON.stringify(this.row));
        return row[this.column] ? row[this.column] : "-";
    }
}