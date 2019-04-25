import { LightningElement, api, track } from 'lwc';

export default class DatatableCustomDateType extends LightningElement {
    @api column;
    @api type;
    @api filter;

    @track isCustomDate = false;
    @track seletedDateFrom;
    @track seletedDateTo;

    changeDatepickerFrom(event) {
        this.seletedDateFrom = event.currentTarget.value;
    }

    changeDatepickerTo(event) {
        this.seletedDateTo = event.currentTarget.value;
    }
    
    filterEvent(event) {
        var filter;
        var isActive;
        // var customDateFrom = this.template.querySelector("lightning-input.datefrom");
        // var customDateTo = this.template.querySelector("lightning-input.dateto");
        event.currentTarget.classList.toggle("active");
        this.isCustomDate = (event.currentTarget.dataset.value === "Custom Range" && event.currentTarget.classList.contains("active") && this.type === "DATE") ? true : false;
        isActive = (event.currentTarget.classList.contains("active")) ? true : false;
        filter = { column: this.column,
                   type: this.type,
                   filter: this.filter,
                   active: isActive
                 }
        const values = filter;
        const filterValue = new CustomEvent('filter', { detail: {values} });
        this.dispatchEvent(filterValue);
    }
}