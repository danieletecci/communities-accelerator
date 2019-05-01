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
    @track searchTerm = '';
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
    setSearchTerm(event){
        this.searchTerm = event.currentTarget.value;
    }

    focusFilter() {
        this.showCancelSearch = true;
        this.showFilterIcon = true;
    }

    cancelFilter() {
        this.searchTerm = "";
        this.showCancelSearch = false;
        this.showFilterIcon = false;
        this.closeFilterModal();
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

    filterAllRemove() {
        var tableFooter = this.template.querySelector("div.table__footer");
        var filters = [];
        const values = JSON.stringify(filters);
        tableFooter.classList.toggle("hidden");
        this.filterEvent(values);
        this.showFilterIcon = false;
    }


    filterEvent(values) {
        const filterItemSelected = new CustomEvent('filter', { detail: {values} });
        this.dispatchEvent(filterItemSelected);
    }

    sortEvent(values){
        const sortIndex = new CustomEvent('sort', { detail:values });
        this.dispatchEvent(sortIndex);
    }

    sortByColumn(event){
        let direction = event.currentTarget.dataset.direction === 'ASC'?'DESC':'ASC';
        event.currentTarget.dataset.direction = direction;
        let currentState = JSON.parse(JSON.stringify(event.currentTarget.dataset));
        let configObject = Object.assign({}, currentState, {direction});
        this.sortEvent(configObject);
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
}