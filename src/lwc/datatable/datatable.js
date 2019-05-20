import { loadStyle } from 'lightning/platformResourceLoader';
import ASSETS from '@salesforce/resourceUrl/Assets';

import { LightningElement, api, track } from 'lwc';

import GeneralCancel from '@salesforce/label/c.General_Cancel';
import GeneralSearch from '@salesforce/label/c.General_Search';
import RemoveAllFilters from '@salesforce/label/c.RemoveAllFilters';
import GeneralShowMore from '@salesforce/label/c.General_ShowMore';
import GeneralApply from '@salesforce/label/c.General_Apply';



export default class Datatable extends LightningElement {
    @api table;

    // Responsiveness
    @track orientation;
    @track isPhone = false;
    @track isTablet = false;
    @track isDesktop = false;

    // Table
    @track columnsToShow;
    @track hideTable = false;
    @track hasMoreRows = true;

    // Modals
    @track showFilterModal = false;
    @track showDetailModal = false;
    @track showActionModal = false;
    
    // Filters
    @track searchTerm = '';
    @track showCancelSearch = false;
    @track showFilterIcon = false;
    @track hasFilters = false;
    @track hasSearchables = false;

    // Actions
    @track hasGlobalActions = false;
    @track hasRowActions = false;
    @track hasExtraRowActions = false;
    @track rowAction = [];
    @track FIRST_LEVEL_ROW_ACTION_AMOUNT;
    @track firstLevelRowAction = [];
    @track globalAction = [];
    @track clickRow;

    // Custom Labels
    @track GeneralSearch = GeneralSearch;
    @track GeneralCancel = GeneralCancel;
    @track RemoveAllFilters = RemoveAllFilters;
    @track GeneralShowMore = GeneralShowMore;
    @track GeneralApply = GeneralApply;

    NUMBER_OF_COLUMNS = 6;
    hasSearched = false;

    filterIcon = ASSETS + '/Assets/Icons/FilterIcon.svg';
    closeIcon = ASSETS + '/Assets/Icons/CloseIcon.svg';
    moreIcon = ASSETS + '/Assets/Icons/MoreIcon.svg';
    moreHorizontalIcon = ASSETS + '/Assets/Icons/MoreHorizontalIcon.svg';
    sortIcon = ASSETS + '/Assets/Icons/SortIcon.svg';
    arrowIcon = ASSETS + '/Assets/Icons/arrow.svg';

    constructor() {
        super();
        this.handleOrientation();
        this.setDevices();
        this.FIRST_LEVEL_ROW_ACTION_AMOUNT = this.isPhone ? 3 : 2;
    }
    
    setDevices(){
        let currentDeviceType = eval("$A.get('$Browser.formFactor')");
        let deviceTypeRef = 'is' + currentDeviceType[0] + currentDeviceType.slice(1).toLowerCase();
        this[deviceTypeRef] = true;
    }
    
    connectedCallback() {
        window.addEventListener("orientationchange", () => this.handleOrientation());
        loadStyle(this, ASSETS + '/Assets/Styles/datatableExternalStyles.css');
        this.hasFilters = this.table.columns.filter(f => f.filtrable).length > 0;
        this.hasSearchables = this.table.columns.filter(f => f.searchable).length > 0;
    }

    renderedCallback() {
        if (this.table && !this.columnsToShow) {
            this.NUMBER_OF_COLUMNS = this.table.numberOfColumns > this.NUMBER_OF_COLUMNS ? this.NUMBER_OF_COLUMNS : this.table.numberOfColumns;
            this.columnsToShow = this.table.columns.slice(0, this.NUMBER_OF_COLUMNS);
        }
        if (this.table.actions.length > 0 && this.rowAction.length === 0 && this.globalAction.length === 0) {
            this.typeActions();
        }
        if(this.table.tableData.length === this.table.totalRows || (this.table.tableData.length / this.table.recordsPerPage) % 1 !== 0){
            this.hasMoreRows = false;
        }else {
            this.hasMoreRows = true;
        }
    }

    get columnClass() {
        return this.orientation ? "slds-col slds-size_2-of-4" : "slds-col slds-size_1-of-4";
    }

    get appliedFilters() {
        return (this.table.appliedFilters.length > 0) ? true : false;
    }

    get extraRowActionContainerClass(){
        return 'extraRowActionContainer';
    }

    get hasMore(){
        return this.hasMoreRows;
    }

    openFilterModal() {
        this.showFilterModal = true;
    }

    closeFilterModal() {
        this.showFilterModal = false;
    } 

    openDetailModal(event) {
        this.showDetailModal = true;
        this.hideTable = true;
        this.clickRow = event.currentTarget.dataset.key;
    }

    closeDetailModal() {
        this.showDetailModal = false;
        this.hideTable = false;
    }

    openActionModal() {
        this.showActionModal = true;
    }

    closeActionModal() {
        this.showActionModal = false;
    }

    typeActions() {
        this.table.actions.forEach( (act, index, actionList) => {
            act.icon = ASSETS + '/Assets/Icons/' + act.icon +'.svg';
            if (act.recordType === "RowAction") {
                this.hasRowActions = true;
                this.rowAction.push(act);
            } else {
                this.hasGlobalActions = true;
                this.globalAction.push(act);
            }
            if(index === (actionList.length-1)){
                this.hasExtraRowActions = this.FIRST_LEVEL_ROW_ACTION_AMOUNT < this.rowAction.length;
                this.firstLevelRowAction = this.rowAction.slice(0, this.FIRST_LEVEL_ROW_ACTION_AMOUNT);
            }
        });

    }

    handleOrientation() {
        //TRUE = Portrait
        this.orientation = (screen.orientation.angle === 0) ? true : false;
    }
    setSearchTerm(event){
        this.searchTerm = event.currentTarget.value;
        if (event.which === 27){
            event.target.blur();
            this.cancelFilter();
        }
    }

    focusFilter() {
        this.showCancelSearch = true;
        if (this.isPhone) {
            this.showFilterIcon = true;
        }
        if (this.isDesktop) {
            this.showFilterModal = true;
        }
    }

    cancelFilter() {
        this.searchTerm = "";
        this.showCancelSearch = false;
        this.showFilterIcon = false;
        this.searchEventOnBlur({target:{value: ''}});
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
        const sortIndex = new CustomEvent('sort', { detail: values });
        this.dispatchEvent(sortIndex);
    }

    sortByColumn(event){
        let direction = event.currentTarget.dataset.direction === 'ASC'?'DESC':'ASC';
        event.currentTarget.dataset.direction = direction;
        let currentState = JSON.parse(JSON.stringify(event.currentTarget.dataset));
        let configObject = Object.assign({}, currentState, {direction});
        this.sortEvent(configObject);
    }

    getPage(){
        var actualPage = this.table.tableData.length / this.table.recordsPerPage;
        const sortIndex = new CustomEvent('getpage', { detail: {page:actualPage} });
        this.dispatchEvent(sortIndex);
    }

    get noRecordsToDisplay () {
        return this.table.tableData.length <= 0
    }

    showMoreRowActions(event){
        let hasClass = event.currentTarget.parentElement.parentElement.classList.contains('active');
        this.template.querySelectorAll(`td.extraRowActionContainer.active`).forEach(item => item.classList.remove('active'));
        if(!hasClass){
            event.currentTarget.parentElement.parentElement.classList.add('active');
        }else{
            event.currentTarget.parentElement.parentElement.classList.remove('active');
        }
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
        this.hasSearched = true;
        this.dispatchEvent(searchValue);
    }

    searchEventOnBlur(event) {
        if(this.hasSearched){
            this.hasSearched = false;
            const value = event.target.value;
            if (value === null || value === '') this.searchEvent(event);
        }
        // this.closeFilterModal();
        this.showCancelSearch = false;
    }

    clearFilterEvent() {
        const clearFilter = new CustomEvent('clearfilter');
        this.dispatchEvent(clearFilter);
    }

}