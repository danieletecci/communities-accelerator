import { LightningElement, api, track } from 'lwc';

export default class DatatableCustomDateType extends LightningElement {
    @api column;
    @api type;
    @api filter;
    @api appliedfilters;
    @api formartdate;
    @api isDesktop;

    isRemoveAll = false;

    @api removeFilters(){
        var activeBtn = this.template.querySelector("button.filter");
        activeBtn.classList.remove("active");
        this.isCustomDate = false;
    }

    @track isCustomDate = false;
    @track seletedDateFrom;
    @track seletedDateTo;

    isLastWeek = false;
    isLastMonth = false;
    isLastYear = false;
    isCustomRange = false;

    renderedCallback() {
        if (this.appliedfilters.length > 0) { 
            if (this.type === "DATE" || this.type === "DATETIME") { this.setAppliedFiltersForDate(); }
            //this.appliedFilters(); 
        }
    }

    changeDatepickerFrom(event) {
        this.seletedDateFrom = event.currentTarget.value;
    }

    changeDatepickerTo(event) {
        this.seletedDateTo = event.currentTarget.value;
    }

    setAppliedFiltersForDate() {
        var dates = JSON.parse(JSON.stringify(this.formartdate));
        var appliedFilters = JSON.parse(JSON.stringify(this.appliedfilters));
        appliedFilters.forEach(filter =>{
            if (filter.filter.type === "DATE" || filter.filter.type === "DATETIME") {
                this.isLastWeek = (filter.value1 === dates.lastWeek && filter.value2 === dates.now) ? true : false;
                this.isLastMonth = (filter.value1 === dates.lastMonth && filter.value2 === dates.now) ? true : false;
                this.isLastYear = (filter.value1 === dates.lastYear && filter.value2 === dates.now) ? true : false;
                this.isCustomRange = (!this.isLastWeek && !this.isLastMonth && !this.isLastYear) ? true : false;
            } 
        }); 
    }

    @api activeFilter(filter) {
        var button = this.template.querySelector("button.filter");
        if (filter.value1 === button.innerText || 
            (filter.filter.type === "DATE" && (this.isLastWeek && button.dataset.value === "Last Week") || (this.isLastMonth && button.dataset.value === "Last Month") 
                || (this.isLastYear && button.dataset.value === "Last Year") || (this.isCustomRange && button.dataset.value === "Custom Range"))) {
            button.classList.toggle("active");
            this.filterArray(button);
       }
    }

    filterArray(button) {
        var filter;
        var isActive;
        // var customDateFrom = this.template.querySelector("lightning-input.datefrom");
        // var customDateTo = this.template.querySelector("lightning-input.dateto");
        this.isCustomDate = (button.dataset.value === "Custom Range" && button.classList.contains("active") && this.type === "DATE") ? true : false;
        isActive = (button.classList.contains("active")) ? true : false;
        filter = { column: this.column,
                   type: this.type,
                   filter: this.filter,
                   active: isActive
                 }
        const values = filter;
        this.filterEvent(values);
    }
    
    filterSelected() {
        var filterButton = this.template.querySelector("button.filter");
        filterButton.classList.toggle("active");
        this.filterArray(filterButton);
    }

    filterEvent(values) {
        const filterValue = new CustomEvent('filter', { detail: {values} });
        this.dispatchEvent(filterValue);
    }
}