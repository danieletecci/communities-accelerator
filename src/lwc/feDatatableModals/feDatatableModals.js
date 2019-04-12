import { LightningElement, api, track } from 'lwc';

export default class FeDatatableModals extends LightningElement {
    @api table;
    @api closeicon;
    @api rowkey;
    @api type;
    @api rowaction;

    @track rowData = [];
    @track actionmodal;
    @track detailmodal;

    renderedCallback() {
        if (this.type === "detailModal" && this.rowData.length === 0) {
            this.dataDetailModal();
        }
        if (this.type) {
            this.setTypeModal();
        } 
    }

    setTypeModal() {
        if (this.type === "detailModal") {
            this.actionmodal = false;
            this.detailmodal = true;
        } else if (this.type === "actionModal") {
            this.actionmodal = true;
            this.detailmodal = false;
        }
    }
        
    dataDetailModal() {
        var row = JSON.parse(JSON.stringify(this.table.tableData)).find(r => (r.Id === this.rowkey));
        var data;
        this.table.columns.forEach(col => {
            let rowValue = row[col.fieldName];
            if (!row[col.fieldName]) {
                rowValue = "-";
            }
            data = {  column: col.label, 
                      row: rowValue }
            this.rowData.push(data);
        });
    }

    closeDetailModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}