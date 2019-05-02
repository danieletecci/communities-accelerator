import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';


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

    isActive = [];

    connectedCallback() {
        loadStyle(this, 'sfsites/c/resource/Assets/Assets/Styles/datatableModalsExternalStyles.css');
    }

    renderedCallback() {
        this.setTypeModal();
        if (this.type === "detailModal" && this.rowData.length === 0) { this.dataDetailModal(); }
        if (this.type === "filterModal" && this.table.appliedFilters.length > 0) { 
            this.appliedFilters();
            this.showFilterModalFooter = true; 
        }
    }

    get filterTitleClass() {
        let sldsClass = this.isDesktop?'slds-size_4-of-4':'slds-size_4-of-4';
        return `filter-title slds-col ${sldsClass} slds-grid`;
    }

    get filterContainerClass(){
        let sldsClass = this.isDesktop?'slds-size_2-of-12':'';
        return `filterContainer slds-grid slds-wrap slds-gutters_x-small ${sldsClass}`;
    }

    get modalContentClass(){
        let sldsClass = this.isDesktop?'slds-grid slds-grid_align-end':'';
        return `modal__content ${sldsClass}`;
    }

    get filterItemClass(){
        let sldsClass = this.isDesktop?'':'slds-size_2-of-4';
        return `filterItemClass slds-col ${sldsClass}`;
    }

    get filterOptionsClass(){
        let sldsClass = 'slds-hide';
        return `filterOptions ${sldsClass}`;
    }

    get removeAllFiltersClass(){
        let sldsClass = this.isDesktop?'slds-size_1-of-2':'slds-size_1-of-1';
        return `removeAllFilters slds-col ${sldsClass}`;
    }

    get applyFilterClass(){
        let sldsClass = this.isDesktop?`slds-size_1-of-2`:`slds-size_1-of-1`;
        return `applyFilter slds-col ${sldsClass}`;
    }

    toggleOptions(event){
        this.hideFilterLists();
        return event.currentTarget.parentNode.querySelector('.filterOptions').classList.remove('slds-hide');
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
        var isNumber = ["number"];
        columns.forEach(col => {
            if(col.filtrable && (col.type === "DATE" || col.type === "DATETIME")) {
                col.filtrableValues = filterValues;
            } else if (col.filtrable && (col.type === "DOUBLE")) {
                col.filtrableValues = isNumber;
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
        if (filter.isActive) {
            this.isActive.push(filter);
        } else {
            let inactiveIndexFilter = this.isActive.findIndex(f => (f.filter === filter.filter));
            if (inactiveIndexFilter >= 0) {
                this.isActive.splice(inactiveIndexFilter, 1);
            }
        }
        this.showFilterModalFooter = (this.isActive.length > 0) ? true : false;
    }

    filterAllRemove() {
        var buttons = this.template.querySelectorAll('c-datatable-filters');
        buttons.forEach(btn => { btn.removeFilters(); });
        this.removeAllFilters = true;
        this.showFilterModalFooter = false;
    }

    filtersToApply() {
        let filters = this.template.querySelectorAll('c-datatable-filters');
        let values;
        this.activeFilters = [];
        filters.forEach(filter => { 
            values = (JSON.parse(JSON.stringify(filter.valueSelect())));
            if (values) {this.activeFilters.push(values);}
        });
    }

    hideFilterLists(){
        this.template.querySelectorAll('.filterOptions').forEach( (element) => !element.classList.contains('slds-hide')&&element.classList.add('slds-hide') );
    }

    applyFilter() {
        this.hideFilterLists();
        var activeFilters;
        var filters = [];   
        var filter;
        var dates = this.formatDate();
        this.filtersToApply();
        activeFilters = JSON.parse(JSON.stringify(this.activeFilters));   
        activeFilters.forEach(fil =>{
            let value1 = fil.value1;
            let value2 = fil.value2;
            if (fil.value1 === "Last Week") {
                value1 = dates.lastWeek;  //value1 = menor
                value2 = dates.now; //value2 = mayor
            } else if (fil.value1 === "Last Month") {
                    value1 = dates.lastMonth;
                    value2 = dates.now;
                } else if (fil.value1 === "Last Year") {
                        value1 = dates.lastYear;
                        value2 = dates.now;
                    } else if (fil.value1 && fil.value2 && fil.type === "DATE") {
                        value1 = fil.value1;
                        value2 = fil.value2;
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
        !this.isDesktop && this.closeModal();
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