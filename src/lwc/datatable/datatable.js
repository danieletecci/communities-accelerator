import Assets from '@salesforce/resourceUrl/Assets';
import { loadStyle } from 'lightning/platformResourceLoader';

import { LightningElement, api, track } from 'lwc';

export default class Datatable extends LightningElement {
    @api table;

    @track orientation;
    @track isPhone = false;
    @track isTablet = false;
    @track isDesktop = false;
    @track columnsToShow;
    @track columnsToShowLength = 0;
    @track showFilterModal = false;
    // @track showFooterModal = false;
    @track showDetailModal = false;
    @track showActionModal = false;
    @track showCancelSearch = false;
    @track showFilterIcon = false;
    // @track isCustomDate = false;
    @track rowAction = [];
    @track globalAction = [];
    @track clickRow;

    numberOfColumns = 6;
    filterIcon = Assets + '/Assets/Icons/FilterIcon.svg';
    closeIcon = Assets + '/Assets/Icons/CloseIcon.svg';
    moreIcon = Assets + '/Assets/Icons/MoreIcon.svg';
    sortIcon = Assets + '/Assets/Icons/SortIcon.svg';

    constructor() {
        super();
        this.handleOrientation();
        this.setDevices();
    }

    setDevices(){
        let currentDeviceType = eval("$A.get('$Browser.formFactor')");
        let deviceTypeRef = 'is' + currentDeviceType[0] + currentDeviceType.slice(1).toLowerCase();
        this[deviceTypeRef] = true;
    }

    connectedCallback() {
        window.addEventListener("orientationchange", () => this.handleOrientation());
        loadStyle(this, Assets + '/Assets/Styles/roboto.css');
    }

    renderedCallback() {
        if (this.table && !this.columnsToShow) {
            this.columnsToShow = this.table.columns.slice(0, this.numberOfColumns);
            this.columnsToShowLength = this.columnsToShow.length;
        }
        if (this.table.actions.length > 0 && this.rowAction.length === 0 && this.globalAction.length === 0) {
            this.typeActions();
        }
    }

    get columnClass() {
        return this.orientation ? "slds-col slds-size_2-of-4" : "slds-col slds-size_1-of-4";
    }

    get appliedFilters() {
        return (this.table.appliedFilters.length > 0) ? true : false;
    }

    // get setDateFilter() {   
    //     var columns = JSON.parse(JSON.stringify(this.table.columns));
    //     var filterValues = ["Last Week", "Last Month", "Last Year", "Custom Range"]; 
    //     columns.forEach(col => {
    //         if(col.filtrable && (col.type === "DATE" || col.type === "DATETIME")) {
    //             col.filtrableValues = filterValues;
    //         }
    //     });
    //     return columns;
    // }

    openFilterModal() {
        this.showFilterModal = true;
    }

    closeFilterModal() {
        this.showFilterModal = false;
    } 

    openDetailModal(event) {
        this.showDetailModal = true;
        this.clickRow = event.currentTarget.dataset.key;
    }

    closeDetailModal() {
        this.showDetailModal = false;
    }

    openActionModal() {
        this.showActionModal = true;
    }

    closeActionModal() {
        this.showActionModal = false;
        //this.showDetailModal = false;
    }

    typeActions() {
        this.table.actions.forEach(act => {
            act.icon = Assets + '/Assets/Icons/' + act.icon +'.svg';
            if (act.recordType === "RowAction") {
                this.rowAction.push(act);
            } else {
                this.globalAction.push(act);
            }
        });
    }

    handleOrientation() {
        //TRUE = Portrail  
        this.orientation = (screen.orientation.angle === 0) ? true : false;
    }

    focusFilter() {
        this.showCancelSearch = true;
        this.showFilterIcon = true;
    }

    cancelFilter() {
        this.showCancelSearch = false;
        this.showFilterIcon = false;
    }

    deleteFilter(event) {
        var name = event.currentTarget.dataset.name;
        var value = event.currentTarget.dataset.value;
        var filters = JSON.parse(JSON.stringify(this.table.appliedFilters));
        this.table.appliedFilters.forEach((fil, index) => {
            if (fil.filter.name === name && fil.value1 === value) {
                filters.splice(index, 1);
            }
        });
        const values = JSON.stringify(filters);
        this.filterEvent(values);
    }

    // filterActive(event) {
    //     event.currentTarget.classList.toggle("active");
    //     this.showFooterModal = true;

    //     if(event.currentTarget.dataset.value === "Custom Range") {
    //         this.isCustomDate = true;
    //     }
    // }

    filterAllRemove() {
        var tableFooter = this.template.querySelector("div.table__footer");
        var filters = [];
        const values = JSON.stringify(filters);
        tableFooter.classList.toggle("hidden");
        this.filterEvent(values);
        this.showFilterIcon = false;
    }

    // formatDate() {
    //     var today = new Date();
    //     var dates = [];
    //     dates = {
    //         now: today.getFullYear() + '-' + String(today.getMonth()+1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0'),
    //         lastWeek: today.getFullYear() + '-' + String(today.getMonth()+1).padStart(2, '0') + '-' + String(today.getDate()-7).padStart(2, '0'),
    //         lastMonth: today.getFullYear() + '-' + String((today.getMonth()+1)-1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0'),
    //         lastYear: (today.getFullYear()-1) + '-' + String(today.getMonth()+1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0')
    //     };
    //     return dates;
    // }

    // dataFilter() {
    //     var button = this.template.querySelectorAll("button.active");
    //     var customDateFrom = this.template.querySelector("input[type='date'].datefrom");
    //     var customDateTo = this.template.querySelector("input[type='date'].dateto");
    //     var filters = [];   
    //     var filter;
    //     var dates = this.formatDate();
    //     var value1;
    //     var value2;

    //     button.forEach(fil =>{
    //         value1 = fil.dataset.value;
    //         value2 = null;
    //         if (fil.dataset.value === "Last Week") {
    //             value1 = dates.lastWeek;  //value1 = menor
    //             value2 = dates.now; //value2 = mayor
    //         } else if (fil.dataset.value === "Last Month") {
    //                 value1 = dates.lastMonth;
    //                 value2 = dates.now;
    //             } else if (fil.dataset.value === "Last Year") {
    //                     value1 = dates.lastYear;
    //                     value2 = dates.now;
    //                 } else if (fil.dataset.value === "Custom Range") {
    //                     value1 = customDateFrom.value;
    //                     value2 = customDateTo.value;
    //                 }

    //         filter = {filter: {
    //                         name: fil.dataset.column, 
    //                         type: fil.dataset.type
    //                     },
    //                     value1: value1,
    //                     value2: value2
    //                 };
    //         filters.push(filter);
    //     });
    //     const values = JSON.stringify(filters);
    //     this.filterEvent(values);
    //     this.closeFilterModal();
    //     this.showCancelSearch = false;
    // }

    filterEvent(values) {
        const filterItemSelected = new CustomEvent('filter', { detail: {values} });
        this.dispatchEvent(filterItemSelected);
    }

    rowActionEvent(event) {
        var actions = { recordId: event.currentTarget.dataset.id,
                       componentName: event.currentTarget.dataset.component,
                       showAsModal: event.currentTarget.dataset.modal
                     };
        var navigation = event.currentTarget.dataset.navigation ? event.currentTarget.dataset.navigation : " ";
        var isExternal = navigation.split('.');
        if (navigation !== " ") {    
            if (isExternal.length > 1) {
                window.location.assign("http://"+ navigation);
            } else {
                window.location.href = navigation;
            } 
        } else {
            const values = JSON.stringify(actions);
            const actionValue = new CustomEvent('action', { detail: {values} });
            this.dispatchEvent(actionValue);
        }
    }

    searchEvent(event) {
        const values = event.target.value;
        const searchValue = new CustomEvent('search', { detail: {values} });
        this.dispatchEvent(searchValue);
    }

    clearFilterEvent() {
        const clearFilter = new CustomEvent('clearfilter');
        this.dispatchEvent(clearFilter);
        this.filterRemove();
    }

    sortByColumn(event){
        console.log(event);
        debugger;
    }
}