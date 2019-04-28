import { LightningElement, api } from 'lwc';

export default class DatatableRow extends LightningElement {
    @api column;
    @api row;
    @api colname;
    @api isDesktop;
    @api hideColumns;
    @api hideValues;

    get rowValue(){
        var row = JSON.parse(JSON.stringify(this.row));
        return row[this.column] ? row[this.column] : "-";
    }
}