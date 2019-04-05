import { LightningElement, api, track, wire } from 'lwc';
import generalCancel from '@salesforce/label/c.General_Cancel';
import generalClose from '@salesforce/label/c.General_Close';
import generalError from '@salesforce/label/c.General_Error';
import generalSuccess from '@salesforce/label/c.General_Success';
import contentCreated from '@salesforce/label/c.ContentCreated';
import clusterField from '@salesforce/label/c.ContentLandingCluster';
import saveAndNext from '@salesforce/label/c.SaveAndNext';
import recordName from '@salesforce/label/c.ContentNameInput';
import contentCreateLabel from '@salesforce/label/c.Create';
import errorMessageLabel from '@salesforce/label/c.NewContentErrorMessage';
import templateLabel from '@salesforce/label/c.Template';
import requiredFieldMessage from '@salesforce/label/c.RequiredField';
import ClusterLookupPlaceholder from '@salesforce/label/c.ClusterLookupPlaceholder';
import getRecordTypeName from '@salesforce/apex/CreateNewContentModalController.getRecordTypeName';
import createNewContent from '@salesforce/apex/CreateNewContentModalController.createNewContent';
import getClusters from '@salesforce/apex/CreateNewContentModalController.getClusters';

import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'


export default class RecordTypeSelectionModal extends NavigationMixin(LightningElement) {

    @api recordTypeId; //type="String"
    @api isTemplate; //type="Boolean"
    @api componentId; //type="String"
    @api navigationUrl; //type="String"
    @api salesforceDomain; //type="String"
    // Use alerts instead of toast to notify user
    @api notifyViaAlerts = false;
    @api clusters;
    
    @track isMultiEntry = false;
    @api initialSelection = [
        //{id: 'idcluster', sObjectType: 'Cluster__c', icon: 'custom:custom26', title: 'Nombre cluster', subtitle:'Not a valid record'}
    ];
    @track errors = [];

    @track recordTypeLabel;
    @track modalTitle;
    @track isDisabled;

    recordNameValue;
    selectedClusterId;

    label = {
        generalClose,
        generalCancel,
        generalSuccess,
        generalError,
        contentCreated,
        saveAndNext,
        recordName,
        clusterField,
        contentCreateLabel,
        errorMessageLabel,
        templateLabel,
        requiredFieldMessage,
        ClusterLookupPlaceholder
    };

    //Reference used for the pubsub module
    @wire(CurrentPageReference) pageRef;

    @api
    show() {
        this.showHideModal();
        this.getRecordTypeName();
    }

    constructor(){
        super();
        this.recordNameValue = null;
    }

    connectedCallback() {
        registerListener('btncreatecontentclicked', this.handleClickBtnHeader, this);
        this.getClustersBelow();
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    //Handle event dispatched by other component and open modal.
    handleClickBtnHeader(event){
        this.recordTypeId = event.recordTypeId;
        this.isTemplate = event.isTemplate;
        this.componentId = event.componentId;
        this.navigationUrl = event.navigationUrl;
        this.onInit();
        this.showHideModal();
    }

    //Get Data of the component
    onInit(){
        this.getRecordTypeName();
    }

    //Get record type name from apex
    getRecordTypeName(){ 
        getRecordTypeName({ recordTypeId: this.recordTypeId})
            .then(result => {
                this.recordTypeLabel = result;
                this.assignTitle();
            })
            // eslint-disable-next-line handle-callback-err
            .catch( err => {
                this.recordTypeLabel = '';
                this.assignTitle();
            });
    }

    getClustersBelow(){
        getClusters()
            .then(result => {
                this.clusters = JSON.parse(result);
            })
            .catch( err => {
                if(err.body.message){
                    this.showToast(this.label.generalError, err.body.message, 'error');  // Use a custom label for toast title
                }
            });
    }

    handleSearch(event) {
        let results = [];
        let stringText = event.detail.searchTerm;
        var i;

        if(stringText === ''){
            results = this.clusters;
        } else {
            for(i=0; i<this.clusters.length; i++){
                if(this.clusters[i].title.toLowerCase().includes(stringText.toLowerCase())){
                    results.push(this.clusters[i]);
                }
            }
        }

        this.template.querySelector('c-lightning-lookup').setSearchResults(results);
        
    }

    handleSelectionChange() {
        const selection = JSON.parse(JSON.stringify(this.template.querySelector('c-lightning-lookup').getSelection()));
        this.selectedClusterId = ( selection.length > 0) ? selection[0].id : null;
    }

    //Sets the modal title.
    assignTitle(){
        this.modalTitle = this.label.contentCreateLabel + ' ' + this.recordTypeLabel;
        if(this.isTemplate){
            this.modalTitle += ' ' + this.label.templateLabel;
        }
    }

    //Open and hide modal. If the modal is open this class close it, but if it close open it.
    showHideModal(){
        var cmpTarget = this.template.querySelector('section.modalbox3');
        var cmpBack = this.template.querySelector('div.divBackdrop3');
       
        this.isDisabled = true;
        this.recordNameValue = null;

        cmpTarget.classList.toggle("slds-fade-in-open");
        cmpBack.classList.toggle("slds-backdrop_open");

    }

    //If input is not null, creates the record. Else error is returned.
    onNewRecord(){
        if(this.recordNameValue){
            this.setRecord();
        }else{
            this.showToast(this.label.generalError,this.label.requiredFieldMessage,"error");
        }
    }

    //Create the record.
    setRecord(){
        var contentModal = this;
        createNewContent({ 
            recordTypeId: this.recordTypeId, 
            isTemplate : this.isTemplate, 
            componentId :  this.componentId, 
            navigationUrl : this.navigationUrl, 
            recordName : this.recordNameValue, 
            clusterId : this.selectedClusterId
        }).then(result => {
            this.result = JSON.parse(JSON.stringify(result));
            if(result.isSuccess){
                this.showHideModal();
                if(this.salesforceDomain == null){
                    this.navigateToWebPage("/" + this.result.message);
                } else {
                    contentModal.dispatchEvent(new CustomEvent('contentcreated', {detail: { recordId: this.result.message }}));
                }
                this.showToast(this.label.generalSuccess, this.stringFormat(this.label.contentCreated, this.recordNameValue), "success");
            }else{
                this.showToast(this.label.generalError, this.result.message, "errror");
            }
        // eslint-disable-next-line handle-callback-err
        }).catch( err => {
            contentModal.showToast(this.label.generalError, this.label.errorMessageLabel, "errror");
        });
    }

    //Navigates to URL
    navigateToWebPage(url) {
        this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: url
                }
        });
        
    }

    //Sets value of the input to the var.
    setValue(event){
        this.recordNameValue = event.target.value;
        this.isDisabled = false;
    }

    //Sets value of the input to the var.
    setValueBlur(event){
        this.recordNameValue = event.target.value;
        if(this.recordNameValue){
            this.isDisabled = true;
        }else{
            this.isDisabled = false;
        }
    }

    showToast(toastTitle,toastMessage,toastVariant) {
        const event = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: toastVariant,
            mode: (toastVariant === "success") ? 'dismissable' : 'sticky'
        });
        this.dispatchEvent(event);
    }

    stringFormat(string) {
	    var outerArguments = arguments;
	    return string.replace(/\{(\d+)\}/g, function() {
	        return outerArguments[parseInt(arguments[1]) + 1];
	    });
	}
}
