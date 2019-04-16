import { LightningElement, api } from 'lwc';

export default class datatableRow extends LightningElement {
    @api column;
    @api row;
    @api colname;

    get rowValue(){
        var row = JSON.parse(JSON.stringify(this.row));
        return row[this.column] ? row[this.column] : "-";
    }
}