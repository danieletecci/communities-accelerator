import { LightningElement, api, track } from 'lwc';

export default class DatatableCustomDateType extends LightningElement {
    @api column;
    @api type;
    @api filter;
    @api appliedfilters;
    @api formartdate;
    @api isDesktop;

    @api removeFilters(){
        var activeBtn = this.template.querySelector("button.filter");
        var numeroMin = this.template.querySelectorAll("input.min");
        var numeroMax = this.template.querySelectorAll("input.max");
        if (activeBtn) { activeBtn.classList.remove("active"); }
        this.isCustomDate = false;
    }

    @api activeFilter(filter) {
        var button = this.template.querySelector("button.filter");
        var numeroMin = this.template.querySelectorAll("input.min");
        var numeroMax = this.template.querySelectorAll("input.max");
        if (button && (filter.value1 === button.dataset.value || 
            (filter.filter.type === "DATE" && (this.isLastWeek && button.dataset.value === "Last Week") || (this.isLastMonth && button.dataset.value === "Last Month") 
                || (this.isLastYear && button.dataset.value === "Last Year") || (this.isCustomRange && button.dataset.value === "Custom Range")))) {
            button.classList.toggle("active");
            this.filterArray(button);
       }
    }

    @api valueSelect() {
        var filterButton = this.template.querySelector("button.filter");
        var numeroMin = this.template.querySelectorAll("input.min");
        var numeroMax = this.template.querySelectorAll("input.max");
        var filter;
        if (filterButton && filterButton.classList.contains("active") && filterButton.dataset.value === "Custom Range") {
            if (this.selectedDateFrom && this.selectedDateTo) {
                filter = {  column: this.column,
                            type: this.type,
                            value1: this.selectedDateFrom,
                            value2: this.selectedDateTo                      
                        }
            }
        } else if (filterButton && filterButton.classList.contains("active")) {
            filter = {      column: this.column,
                            type: this.type,
                            value1: this.filter,
                            value2: null                    
                        } 
        } else if (this.typeIsNumber) {
            if (this.selectedMin && this.selectedMax) {
                filter = {  column: this.column,
                            type: this.type,
                            value1: this.selectedMin,
                            value2: this.selectedMax                      
                        }
            } 
        }  
        return (filter) ? filter : false; 
    }

    @track isCustomDate = false;
    @track typeIsNumber = false;
    @track typeIsPicklist = false;
    @track typeIsDate = false;
    @track selectedDateFrom;
    @track selectedDateTo;
    @track selectedMin;
    @track selectedMax;

    isLastWeek = false;
    isLastMonth = false;
    isLastYear = false;
    isCustomRange = false;
    isRemoveAll = false;
    

    renderedCallback() {
        this.typeOfFilter();
        if (this.appliedfilters.length > 0) { 
            if (this.typeIsDate) { this.setAppliedFiltersForDate(); }
        }
    }

    get showButton() {
        return (this.typeIsPicklist || this.typeIsDate) ? true : false;
    }

    typeOfFilter() {
        this.typeIsNumber = (this.type === "DOUBLE") ? true : false;
        this.typeIsPicklist = (this.type === "PICKLIST") ? true : false;
        this.typeIsDate = (this.type === "DATE" || this.type === "DATETIME") ? true : false;
    }

    changeDatepickerFrom(event) {
        this.selectedDateFrom = event.currentTarget.value;
    }

    changeDatepickerTo(event) {
        this.selectedDateTo = event.currentTarget.value;
    }

    changeInputMin(event) {
        this.selectedMin = event.currentTarget.value;
    }

    changeInputMax(event) {
        this.selectedMax = event.currentTarget.value;
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

    filterArray(button) {
        var filter;
        var isActive;
        this.isCustomDate = (button.dataset.value === "Custom Range" && button.classList.contains("active") && this.typeIsDate) ? true : false;
        isActive = (button.classList.contains("active")) ? true : false;
        filter = { filter: button.dataset.value,
                   isActive: isActive
                 }
        const values = filter;
        this.filterEvent(values);
    }

    filterEvent(values) {
        const filterValue = new CustomEvent('filter', { detail: {values} });
        this.dispatchEvent(filterValue);
    }

    filterSelected() {
        var filterButton = this.template.querySelector("button.filter");
        filterButton.classList.toggle("active");
        this.filterArray(filterButton);
    }


    select () {
        var filterButton = this.template.querySelector("button.filter");
        var numeroMin = this.template.querySelectorAll("input.min");
        var numeroMax = this.template.querySelectorAll("input.max");
        var isActive;
        var filter;
        filterButton.classList.toggle("active");
        isActive = (filterButton.classList.contains("active")) ? true : false;
        this.isCustomDate = (filterButton.dataset.value === "Custom Range" && isActive && this.typeIsDate) ? true : false;
        filter = {
            filter: filterButton.dataset.value,
            isActive: isActive,
        }
        const values = filter;
        this.filterEvent(values);
    }   
}