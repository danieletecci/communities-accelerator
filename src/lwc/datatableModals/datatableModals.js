import { LightningElement, api, track } from 'lwc';

export default class DatatableModals extends LightningElement {
    @api table;
    @api closeicon;
    @api rowkey;
    @api type;
    @api rowaction;
    @api isDesktop;
    
    @track showFilterModalFooter = false;
    @track rowData = [];
    @track activeFilters = [];
    @track actionModal;
    @track detailModal;
    @track filterModal;
    @track formartDate = this.formatDate();

    firstRender = true;
    removeAllFilters = false;
    filterTypeDate;

    renderedCallback() {
        this.setTypeModal();
        if (this.type === "detailModal" && this.rowData.length === 0) { this.dataDetailModal(); }
        if (this.type === "filterModal" && this.table.appliedFilters.length > 0) { 
            this.appliedFilters();
            this.showFilterModalFooter = true; 
        }
    }

    setTypeModal() {
        if (this.type === "detailModal") {
            this.actionModal = false;
            this.filterModal = false;
            this.detailModal = true;
        } else if (this.type === "actionModal") {
            this.actionModal = true;
            this.filterModal = false;
            this.detailModal = false;
        } else if (this.type === "filterModal") {
            this.actionModal = false;
            this.filterModal = true;
            this.detailModal = false;
        }
    }

    //-----          FILTER'S MODAL         ------//    

    get setFilters() {   
        var columns = JSON.parse(JSON.stringify(this.table.columns));
        var filterValues = ["Last Week", "Last Month", "Last Year", "Custom Range"]; 
        columns.forEach(col => {
            if(col.filtrable && (col.type === "DATE" || col.type === "DATETIME")) {
                col.filtrableValues = filterValues;
            }
        });
        return columns;
    }

    formatDate() {
        var today = new Date();
        var dates = [];
        dates = {
            now: today.getFullYear() + '-' + String(today.getMonth()+1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0'),
            lastWeek: today.getFullYear() + '-' + String(today.getMonth()+1).padStart(2, '0') + '-' + String(today.getDate()-7).padStart(2, '0'),
            lastMonth: today.getFullYear() + '-' + String((today.getMonth()+1)-1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0'),
            lastYear: (today.getFullYear()-1) + '-' + String(today.getMonth()+1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0')
        };
        return dates;
    }

    setAppliedFiltersForDate() {
        var dates = this.formatDate();
        var appliedFilters = JSON.parse(JSON.stringify(this.table.appliedFilters));
        appliedFilters.forEach(filter =>{
            if (filter.filter.type === "DATE" || filter.filter.type === "DATETIME") {
                this.isLastWeek = (filter.value1 === dates.lastWeek && filter.value2 === dates.now) ? true : false;
                this.isLastMonth = (filter.value1 === dates.lastMonth && filter.value2 === dates.now) ? true : false;
                this.isLastYear = (filter.value1 === dates.lastYear && filter.value2 === dates.now) ? true : false;
                this.isCustomRange = (!this.isLastWeek && !this.isLastMonth && !this.isLastYear) ? true : false;
            } 
        }); 
    }

    appliedFilters() {
        var filterButtons = this.template.querySelectorAll('c-datatable-filters');
        var appliedFilters = JSON.parse(JSON.stringify(this.table.appliedFilters));
        filterButtons.forEach(button => {
            appliedFilters.forEach(filter => {
                button.activeFilter(filter);
           })
        });
    }

    filterElement(event) {
        const filter = JSON.parse(JSON.stringify(event.detail)).values;
        if (filter.active) {
            this.activeFilters.push(filter);
        } else {
            let inactiveIndexFilter = JSON.parse(JSON.stringify(this.activeFilters)).findIndex(f => (f.filter === filter.filter));
            if (inactiveIndexFilter >= 0) {
                this.activeFilters.splice(inactiveIndexFilter, 1);
            }
        }
        this.showFilterModalFooter = (this.activeFilters.length > 0) ? true : false;
    }

    filterAllRemove() {
        var buttons = this.template.querySelectorAll('c-datatable-filters');
        buttons.forEach(btn => { btn.removeFilters(); });
        this.removeAllFilters = true;
        this.showFilterModalFooter = false;
    }

    applyFilter() {
        // var button = this.template.querySelectorAll("button.active");
        var activeFilters = JSON.parse(JSON.stringify(this.activeFilters));
        var customDateFrom = this.template.querySelector("lightning-input.datefrom");
        var customDateTo = this.template.querySelector("lightning-input.dateto");
        var filters = [];   
        var filter;
        var dates = this.formatDate();
        
        activeFilters.forEach(fil =>{
            let value1 = fil.filter;
            let value2 = null;
            if (fil.filter === "Last Week") {
                value1 = dates.lastWeek;  //value1 = menor
                value2 = dates.now; //value2 = mayor
            } else if (fil.filter === "Last Month") {
                    value1 = dates.lastMonth;
                    value2 = dates.now;
                } else if (fil.filter === "Last Year") {
                        value1 = dates.lastYear;
                        value2 = dates.now;
                    } else if (fil.filter === "Custom Range") {
                        value1 = customDateFrom.value;
                        value2 = customDateTo.value;
                    }
            filter = {filter: {
                            name: fil.column, 
                            type: fil.type
                        },
                        value1: value1,
                        value2: value2
                    };
            filters.push(filter);
        });
        if (this.removeAllFilters) { filters = []; }
        const values = JSON.stringify(filters);
        this.filterEvent(values);
        this.closeModal();
    }

    filterEvent(values) {
        const filterItemSelected = new CustomEvent('filter', { bubbles: true, composed: true, detail: {values} });
        this.dispatchEvent(filterItemSelected);
    }

    //-----         DETAIL'S MODAL         ------//
        
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

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}