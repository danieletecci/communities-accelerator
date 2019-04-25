import { LightningElement, api, track } from 'lwc';

export default class DatatableModals extends LightningElement {
    @api table;
    @api closeicon;
    @api rowkey;
    @api type;
    @api rowaction;

    // @track isCustomDate = false;
    @track showFilterModalFooter = false;
    //@track isCustomDate = false;
    @track rowData = [];
    @track activeFilters = [];
    @track actionModal;
    @track detailModal;
    @track filterModal;
    @track seletedDateFrom;
    @track seletedDateTo;

    firstRender = true;
    removeAllFilters = false;
    isLastWeek = false;
    isLastMonth = false;
    isLastYear = false;
    isCustomRange = false;
    filterTypeDate;

    renderedCallback() {
        this.setTypeModal();
        if (this.type === "detailModal" && this.rowData.length === 0) {
            this.dataDetailModal();
        }
        if (this.type === "filterModal" && this.table.appliedFilters.length > 0 && !this.removeAllFilters && this.firstRender) {
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
    
    changeDatepickerFrom(event) {
        this.seletedDateFrom = event.currentTarget.value;
    }

    changeDatepickerTo(event) {
        this.seletedDateTo = event.currentTarget.value;
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
        var filterButtons = this.template.querySelectorAll("button.filter");
        var appliedFilters = JSON.parse(JSON.stringify(this.table.appliedFilters));
        if(filterButtons.length !== 0) {
            this.firstRender = false;
        }
        this.setAppliedFiltersForDate();
        filterButtons.forEach(button => {
            appliedFilters.forEach(filter => {
               if (filter.value1 === button.innerText || 
                    (filter.filter.type === "DATE" && (this.isLastWeek && button.innerText === "Last Week") || (this.isLastMonth && button.innerText === "Last Month") 
                        || (this.isLastYear && button.innerText === "Last Year") || (this.isCustomRange && button.innerText === "Custom Range"))) {
                    button.classList.toggle("active");
               }
           })
        });
    }

    filterElement(event) {
        // var button;
        // var evt = event.currentTarget;
        // evt.classList.toggle("active");
        // button = this.template.querySelectorAll("button.active");
        // if (evt.dataset.type === "DATE" || evt.dataset.type === "DATETIME") {
        //     button.forEach(btn => {
        //         if (evt.dataset.value !== btn.dataset.value && (btn.dataset.type === "DATE" || btn.dataset.type === "DATETIME")) { 
        //             btn.classList.remove("active");
        //         }
        //     });
        // }
        // this.isCustomDate = (evt.dataset.value === "Custom Range" && evt.classList.contains("active")) ? true : false;
        // this.showFilterModalFooter = (button.length === 0) ? false : true;
        //var filter = JSON.parse(JSON.parse(JSON.stringify(event.detail)).value)
        const filter = JSON.parse(JSON.stringify(event.detail)).values;
        if (filter.active) {
            this.activeFilters.push(filter);
        } else {
            let inactiveFilter = JSON.parse(JSON.stringify(this.activeFilters)).findIndex(f => (f.filter === filter.filter));
            if (inactiveFilter) {
                console.log(inactiveFilter);
                console.log(JSON.parse(JSON.stringify(this.activeFilters)));
            }
            // this.table.appliedFilters.forEach((fil, index) => {
            //     if (fil.filter.name === name && fil.value1 === value) {
            //         filters.splice(index, 1);
        }
    }

    filterAllRemove() {
        var button = this.template.querySelectorAll("button.active");
        button.forEach(fil =>{
            fil.classList.remove("active");
        });
        this.removeAllFilters = true;
        this.isCustomDate = false;
        this.showFilterModalFooter = false;
    }

    applyFilter() {
        var button = this.template.querySelectorAll("button.active");
        var customDateFrom = this.template.querySelector("lightning-input.datefrom");
        var customDateTo = this.template.querySelector("lightning-input.dateto");
        var filters = [];   
        var filter;
        var dates = this.formatDate();
        
        button.forEach(fil =>{
            let value1 = fil.dataset.value;
            let value2 = null;
            if (fil.dataset.value === "Last Week") {
                value1 = dates.lastWeek;  //value1 = menor
                value2 = dates.now; //value2 = mayor
            } else if (fil.dataset.value === "Last Month") {
                    value1 = dates.lastMonth;
                    value2 = dates.now;
                } else if (fil.dataset.value === "Last Year") {
                        value1 = dates.lastYear;
                        value2 = dates.now;
                    } else if (fil.dataset.value === "Custom Range") {
                        value1 = customDateFrom.value;
                        value2 = customDateTo.value;
                    }
            filter = {filter: {
                            name: fil.dataset.column, 
                            type: fil.dataset.type
                        },
                        value1: value1,
                        value2: value2
                    };
            filters.push(filter);
        });
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