import { LightningElement, api, wire, track } from 'lwc';
import getFilters from	'@salesforce/apex/ContentSearchFiltersController.getFilters';
import getObjectLabel from	'@salesforce/apex/ContentLandingHeaderController.getObjectLabel';
import getPicklistValues from	'@salesforce/apex/ContentLandingHeaderController.getPicklistValues';
import hasCreateTemplateButton from	'@salesforce/apex/ContentLandingHeaderController.hasCreateTemplateButton';
import hasCreateContentButton from	'@salesforce/apex/ContentLandingHeaderController.hasCreateContentButton';
import getTableWrapper from	'@salesforce/apex/ContentLandingRecordListController.getTableWrapper';
import getUpdatedTableWrapper from	'@salesforce/apex/ContentLandingRecordListController.getUpdatedTableWrapper';
import deleteContent from	'@salesforce/apex/ContentLandingRecordListController.deleteContent';
import ContentLandingAll from '@salesforce/label/c.ContentLandingAll';
import ContentLandingContentType from '@salesforce/label/c.ContentLandingContentType';
import ContentLandingCluster from '@salesforce/label/c.ContentLandingCluster';
import ContentLandingCategory from '@salesforce/label/c.ContentLandingCategory';
import ContentLandingTags from '@salesforce/label/c.ContentLandingTags';
import SidebarFilterTitle from '@salesforce/label/c.SidebarFilterTitle';
import ContentLandingNew from '@salesforce/label/c.ContentLandingNew';
import ContentLandingTemplate from '@salesforce/label/c.ContentLandingTemplate';
import TemplateLabel from '@salesforce/label/c.Template';
import ContentDetailContent from '@salesforce/label/c.ContentDetailContent';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ContentContainer extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api filtersValues;
    @api tabledata;
    @api headerButtonsPrimary;
    @api headerButtonsSecondary;
    @api optionsFilterRadioButtonGroup;

    @api reloadTable(){
        this.tableDataDelete(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
    }
    
    @track renderHeader;
    @track renderFilterSidebar;
    @track renderTable;
    @track SidebarFilterTitle;
    
    filters;
    filtersStatus;
    objectLabel;
    haveObjectLabel;
    haveFilterStatus;
    statusValue;
    searchInputValue;
    contentTypeValue;
    radioButtonGroupValue;
    lblContent;
    recordOffset;
    isAddingRecords;
    recordLimit;
    hasPermissionCreateTemplateButton;
    hasPermissionCreateContentButton;

    //Reference used for the pubsub module
    @wire(CurrentPageReference) pageRef;

    // Get Sidebar filters from APEX CLASS
    @wire(getFilters, { sObjectType: '$objectApiName' })
    wiredFilters({ error, data }) {
        if (error) {
            this.filters = null
            this.setRenderFilterSidebar(false);
            console.log(error);
        } else if (data) {
            this.filters = JSON.parse(JSON.stringify(data.filters));
            this.adaptDataFilters();
            this.setRenderFilterSidebar(true);
        }
    }

    // Get Object Label from APEX CLASS
    @wire(getObjectLabel, { sObjectType: '$objectApiName' })
    wiredObjectLabel({ error, data }) {
        if (error) {
            this.objectLabel = null;
            this.haveObjectLabel = false;
            this.setRenderHeader(this.haveFilterStatus && this.haveObjectLabel);
            console.log(error);
        } else if (data) {
            this.objectLabel = data;
            this.haveObjectLabel = true;
            this.setRenderHeader(this.haveFilterStatus && this.haveObjectLabel);
        }
    }

    // Get Status filters from APEX CLASS
    @wire(getPicklistValues, { sObjectType: '$objectApiName', fieldApiName:"[CMS]Status__c"})
    wiredFilterStatus({ error, data }) {
        if (error) {
            this.filtersStatus = null;
            this.haveFilterStatus = false;
            this.setRenderHeader(this.haveFilterStatus && this.haveObjectLabel);
            console.log(error);
        } else if (data) {
            this.filtersStatus = JSON.parse(JSON.stringify(data));
            this.haveFilterStatus = true;
            this.adaptDataStatus();
            this.setRenderHeader(this.haveFilterStatus && this.haveObjectLabel);
        }
    }

    // Get data of the table from APEX CLASS
    @wire(getTableWrapper, { contentTypeId: null, clusterId: null, categoryId: null, tagIds: null, status: ContentLandingAll, searchText: null,isTemplate: false, recordOffset:0, recordLimit:20 })
    wiredTableData({ error, data }) {
        if (error) {
            this.tabledata = null;
            this.setRenderTable(false);
            console.log(error);
        } else if (data) {
            this.tabledata = JSON.parse(data);
            // this.haveTableData = true;
            this.setRenderTable(true);
        }
    }

    // Get if the user has permission to create template from APEX CLASS
    @wire(hasCreateTemplateButton)
    wiredPermissionTemplate({ error, data }) {
        if (error) {
            this.hasPermissionCreateTemplateButton = false;
            this.headerButtonsSecondary = null;
            console.log(error);
        } else if (data) {
            this.hasPermissionCreateTemplateButton = data;
            if(this.hasPermissionCreateTemplateButton === true){
                this.headerButtonsSecondary = [
                    {
                        type: 'secondary',
                        label: ContentLandingTemplate,
                        labelAlternative: null,
                        action: 'handleOnClickCreateTemplate',
                        typeAction: 'dispatchEvent',
                        show: true
                    }
                ];
            }else{
                this.headerButtonsSecondary = null;
            }
        }
    }
    
    // Get if the user has permission to create content from APEX CLASS
    @wire(hasCreateContentButton)
    wiredPermissionContent({ error, data }) {
        if (error) {
            this.hasPermissionCreateContentButton = false;
            this.headerButtonsPrimary = null;
            console.log(error);
        } else if (data) {
            this.hasPermissionCreateContentButton = data;
            if(this.hasPermissionCreateContentButton === true){
                this.headerButtonsPrimary = [
                    {
                        type: 'primary',
                        label: ContentLandingNew,
                        labelAlternative: null,
                        action: 'handleOnClick',
                        typeAction: 'dispatchEvent',
                        show: true
                    }
                ]
            }else{
                this.headerButtonsPrimary = null;
            }
        }
    }

    constructor() {
        super();
        this.statusValue = ContentLandingAll;
        this.searchInputValue = null;
        this.radioButtonGroupValue = false;
        this.filtersValues = 
        [ 
            {label: ContentLandingCluster, value: null, id: null, hasRightBar: true},
            {label: ContentLandingCategory, value: null, id: null, hasRightBar: true},
            {label: ContentLandingTags, value: null, id: null, hasRightBar: false},
        ];
        this.SidebarFilterTitle = SidebarFilterTitle;
        this.lblContent = ContentDetailContent.charAt(0) + ContentDetailContent.slice(1).toLowerCase();
        this.optionsFilterRadioButtonGroup = [
            { name: "filterRadio", label: this.lblContent, value: false, checked: true },
            { name: "filterRadio", label: TemplateLabel, value: true, checked: false },
        ];
        this.recordOffset = 0;
        this.recordLimit = 20;
    }

    connectedCallback() {
        //Workaround
        var html = document.getElementsByTagName('html')[0];
        var body = document.body;
        var lwc = this;
        registerListener('tabItemClick', this.handleTabChange, this);
        body.onscroll = function(){
            if (html.clientHeight + html.scrollTop + 400 >= html.scrollHeight && !lwc.isAddingRecords) {
                //Call your helper method to show more items
                lwc.recordOffset += lwc.recordLimit;
                lwc.isAddingRecords = true;
                lwc.tableDataFilter(lwc.filtersValues[0].id, lwc.filtersValues[1].id, lwc.filtersValues[2].id, lwc.recordOffset);
            }
        }
        
    }

    //Delete all pubsub events
    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    //Set var to indicate if the header component can render or not
    setRenderHeader(bool){
        this.renderHeader = bool;
    }

    //Set var to indicate if the filter sidebar component can render or not
    setRenderFilterSidebar(bool){
        this.renderFilterSidebar = bool;
    }

    //Set var to indicate if the table component can render or not
    setRenderTable(bool){
        this.renderTable = bool;
    }

    adaptDataStatus(){
        this.filtersStatus.forEach(element => {
            if (element.defaultValue === "true"){
                element.defaultValue = "false";
            }
        });
        this.filtersStatus = [{"defaultValue": "true", "label": ContentLandingAll, "value": ContentLandingAll}, ...this.filtersStatus];
    }

    adaptDataFilters(){
        this.filters.forEach(element => {
            if (!element.isMultiPicklist){
                element.values = [{"id": ContentLandingAll, "isSelected": false, "label": ContentLandingAll}, ...element.values];
            }
        });
    }

    //Change value of sidebar filter when is selected
    filterMap(currentFilters, ContentLanding, value, multipleSelection) {        
        var filtersValue = currentFilters.map(element => {
             if(element.label === ContentLanding){
                if(multipleSelection){
                    if(value.check) {
                       if(!element.value){
                           element.value = value.label;
                           element.id = value.value;
                       } else {
                           let values = element.value.split(', ');
                           let ids = element.id.split(', ');
                           values.push(value.label);
                           ids.push(value.value);
                           element.value = values.join(', ');
                           element.id = ids.join(',');
                       }
                    }else{
                        let values = element.value.split(', ');
                        let ids = element.id.split(',');
                        if(values.length < 2){
                            element.value = null;
                            element.id = null;
                        } else {
                            ids.splice(ids.findIndex(x => x === value.value),1);
                            values.splice(values.findIndex(x => x === value.label),1);
                            element.value = values.join(', ');
                            element.id = ids.join(',');
                        }
                    }
                }else{
                    if(value.label === ContentLandingAll){
                        element.value = null;
                        element.id = null;
                    }else{
                        element.value = value.label;
                        element.id = value.value;
                    }
                }
            }
            return element;
        });
        this.filtersValues = filtersValue;
    }

    //Handler sidebar events
    handlerFilterSidebarEvent(event){
        var value = JSON.parse(JSON.parse(JSON.stringify(event.detail)).value);
        var filters = JSON.parse(JSON.stringify(this.filtersValues));
        if(value){
            switch (value.accordeon) {
                case ContentLandingCluster:
                this.filterMap(filters, ContentLandingCluster, value, false);
                // Get data of the table from APEX CLASS
                this.tableDataFilter(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
                break;
                case ContentLandingContentType:
                    if(value.value === ContentLandingAll){
                            this.contentTypeValue = null;
                    }else{
                            this.contentTypeValue = value.value;
                    }
                this.tableDataFilter(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
                break;
                case 'Categories':
                this.filterMap(filters, ContentLandingCategory, value, false);
                this.tableDataFilter(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
                break;
                case ContentLandingTags:
                this.filterMap(filters, ContentLandingTags, value, true);
                this.tableDataFilter(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
                break;
                default:
                this.tableDataFilter(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
            }
            this.filtersValues = filters;
        }else {
            this.contentTypeValue = null;
            this.filtersValues = 
            [ 
                {label: ContentLandingCluster, value: null, id: null},
                {label: ContentLandingCategory, value: null, id: null},
                {label: ContentLandingTags, value: null, id: null},
            ];
           this.tableDataFilter();
        }
        this.filtertHandler();
    }

    filtertHandler() {
        const selectedEvent = new CustomEvent('filtervalues', { detail: this.filtersValues });
        this.dispatchEvent(selectedEvent);
    }

    //Handler Status events
    handleTabChange(event) {
        this.statusValue = event.tab.label;
        this.tableDataFilter(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
    }

    onSearchEvent(event){
        var value = JSON.parse(JSON.parse(JSON.stringify(event.detail)).value).value;
        this.searchInputValue = value === '' ? null : value;
        this.tableDataFilter(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
    }


    tableDataFilter(clusterId, categoryId, tagIds, recordOffset){
        var tabledata;
        if(!recordOffset){
            recordOffset = 0;
            this.recordOffset = 0;
            this.setRenderTable(false);
        }
        getTableWrapper({ contentTypeId: this.contentTypeValue, clusterId: clusterId, categoryId: categoryId , tagIds: tagIds, status: this.statusValue, searchText: this.searchInputValue,isTemplate: this.radioButtonGroupValue, recordOffset:recordOffset, recordLimit:this.recordLimit })
            .then(result => {
                if(recordOffset === 0){
                    this.tabledata = JSON.parse(result);
                }else{
                    tabledata = JSON.parse(JSON.stringify(this.tabledata));
                    if(JSON.parse(result).contentWrappers != null)
                        tabledata.contentWrappers = tabledata.contentWrappers.concat(JSON.parse(result).contentWrappers);
                    this.tabledata = tabledata;
                    this.isAddingRecords = false;
                }
                this.setRenderTable(true);
            })
            .catch( err => {
                console.log(err);
                this.tabledata = null;
                this.setRenderTable(false);
            });
    }

    tableDataDelete(clusterId, categoryId, tagIds){
        this.setRenderTable(false);
        getUpdatedTableWrapper({ contentTypeId: this.contentTypeValue, clusterId: clusterId, categoryId: categoryId , tagIds: tagIds, status: this.statusValue, searchText: this.searchInputValue,isTemplate: this.radioButtonGroupValue, recordOffset: this.recordOffset, recordLimit: this.recordLimit })
            .then(result => {
                this.tabledata = JSON.parse(result);
                this.setRenderTable(true);
            })
            .catch( err => {
                console.log(err);
                this.tabledata = null;
                this.setRenderTable(false);
            });
    }

    handleDeleteContent(event){
        var idContent = event.detail;
        event.stopPropagation();
        deleteContent({ contentId: idContent})
            .then(result => {
                //this.tableDataDelete(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
                this.removeContentFromTableData(idContent);
            })
            .catch( err => {
                console.log(err);
            });
    }

    handleRadioButtonGroupEvent(event){
        this.radioButtonGroupValue = event.detail;
        this.tableDataFilter(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
    }  

     //Open toast with a message
     showToast(toastTitle,toastMessage,toastVariant) {
        const event = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: toastVariant,
            mode: (toastVariant === "success") ? 'dismissable' : 'sticky'
        });
        this.dispatchEvent(event);
    }

    removeContentFromTableData(contentId){
        var tabledata = JSON.parse(JSON.stringify(this.tabledata));
        for(var i = 0 ; i < tabledata.contentWrappers.length ; i++){
            if(tabledata.contentWrappers[i].contentId === contentId){
                tabledata.contentWrappers.splice(i, 1);
                this.tabledata = tabledata;
                this.recordOffset--;
            }
        }
    }

    handleCreateContent(event){
        var idContent = event.detail.templateId;
        var recordTypeId = event.detail.recordTypeId;
        event.stopPropagation();

        const eventDetail = { 
            recordTypeId : recordTypeId,
            isTemplate : false,
            componentId : null,
            navigationId : null,
            templateId : idContent
        }
        this.dispatchEventFromTemplateModal(eventDetail);
    }

	//Fire event to notify LC that general content is selected
	dispatchEventFromTemplateModal(eventDetail) {
		fireEvent(this.pageRef, 'btncreatecontentclicked', eventDetail);
	}

}