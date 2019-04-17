import { LightningElement, api, track, wire } from 'lwc';
import getContentRecordTypes from	'@salesforce/apex/ContentRecordTypeModalController.getContentRecordTypes';
import getTemplateRecordTypes from	'@salesforce/apex/ContentRecordTypeModalController.getTemplateRecordTypes';
import Create from '@salesforce/label/c.Create';
import TemplateLabel from '@salesforce/label/c.Template';
import General_Close from '@salesforce/label/c.General_Close';
import GeneralContents from '@salesforce/label/c.GeneralContents';
import StructureContent from '@salesforce/label/c.StructureContent';
import StructureContentDescription from '@salesforce/label/c.StructureContentDescription';
import General_Cancel from '@salesforce/label/c.General_Cancel';
import General_Next from '@salesforce/label/c.General_Next';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterAllListeners,fireEvent } from 'c/pubsub';

export default class RecordTypeSelectionModal extends NavigationMixin(LightningElement) {

	@api objectapiname; //type="String"
	@api rtDevNameList; //type="List"
	@api options; //type="List"
	@api option; //type="List"
	@api value; //type="String"
	@api clusterId; //type="String"
	@api clusterName; //type="String"
	
	@track create;
	@track templateLabel;
	@track generalClose;
	@track generalContents;
	@track structureContent;
	@track structureContentDescription;
	@track generalCancel;
	@track generalNext;
	@track isTemplate;

	//Reference used for the pubsub module
	@wire(CurrentPageReference) pageRef;

	constructor(){
		super();
		this.create = Create + ' ';
		this.templateLabel = TemplateLabel;
		this.generalClose = General_Close;
		this.generalContents = GeneralContents;
		this.structureContent = StructureContent;
		this.structureContentDescription = StructureContentDescription;
		this.generalCancel = General_Cancel;
		this.generalNext = General_Next;
		this.isTemplate = null;
	}

	connectedCallback() {
		registerListener('btnheaderlistviewclicked', this.handleClickBtnHeader, this);
		registerListener('btnheaderopencreatetemplate', this.handleClickBtnHeaderCreateTemplate, this);
	}

	disconnectedCallback() {
		unregisterAllListeners(this);
	}

	//Get record types from apex
	getRecordType(){ 
		getContentRecordTypes({ sObjectType: this.objectapiname})
			.then(result => {
				var opt = [];
				var structureContent;
				this.options = JSON.parse(JSON.stringify(result));
				structureContent = {Id: 'structureContent',
									Name: "Structure Content", 
									Description: this.structureContentDescription};
				opt.push(structureContent);
				this.option = JSON.parse(JSON.stringify(opt));
			})
			.catch( err => {
				console.log(err);
				this.options = null;
				this.option = null;
			});
	}

	//Get template record types availables from apex
	getRecordTypeTemplate(){ 
		getTemplateRecordTypes({ sObjectType: this.objectapiname})
			.then(result => {
				this.options = JSON.parse(JSON.stringify(result));
			})
			.catch( err => {
				console.log(err);
				this.options = null;
			});
	}

	//Get Data of the component
	onInit(){
		this.value = null;
		if(this.isTemplate){
			this.getRecordTypeTemplate();
		}else{
			this.getRecordType();
		}
		this.deselectRadioButtons();
	}

	//Open and hide modal. If the modal is open this class close it, but if it close open it.
	showHideModal(){
		var cmpTarget = this.template.querySelector('section.modalbox2');
		var cmpBack = this.template.querySelector('div.divBackdrop2');

		cmpTarget.classList.toggle("slds-fade-in-open");
		cmpBack.classList.toggle("slds-backdrop_open");

	}

	onNewRecord(){
		this.goToNewRecord();
		this.showHideModal();
	}

	//Set attribute value when click on radio button option
	optionSelected(event){
		var recordTypeId = event.target.getAttribute("value");
		this.value = recordTypeId;
	}

	//If structure content is selected handle an event to notify contentLandingContainer.
	//If general content is selected handle an event to notify create content modal.
	goToNewRecord(){
		if(this.isTemplate){
			const eventDetail = { 
				recordTypeId : this.value,
				isTemplate : true,
				componentId : null,
				navigationId : null,
				templateId : null
			}
			this.dispatchEventTemplateModal(eventDetail);
		}else{
			if(this.value === "structureContent"){
				this.navigateToWebPage("/lightning/n/Sitemap");
			} else{
				const eventDetail = { 
					recordTypeId : this.value,
					isTemplate : false,
					componentId : null,
					navigationId : null,
					templateId : null
				}
				this.dispatchEventTemplateModal(eventDetail);
			}
		}
	}

	//Fire event to notify LC that general content is selected
	dispatchEventTemplateModal(eventDetail) {

		fireEvent(this.pageRef, 'btncreatecontentclicked', eventDetail);
	}

	//Get if the button is disabled or not
	get isDisabled(){
		return this.value === null;
	}

	//Navigate to a URL
	navigateToWebPage(url) {
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url
            }
        });
    }

	//Handle event dispatched when create content button is clicked on the headerListViewComponent
	handleClickBtnHeader(event){
		this.value = event.value;
		this.isTemplate = false;
		this.onInit();
		this.showHideModal();
	}

	//Handle event dispatched when create template button is clicked on the headerListViewComponent
	handleClickBtnHeaderCreateTemplate(event){
		this.value = event.value;
		this.isTemplate = true;
		this.onInit();
		this.showHideModal();
	}

	//Deselect all radio buttons
	deselectRadioButtons(){
		var inputs = this.template.querySelectorAll('input');

		if(inputs){
			inputs.forEach(element => {
				if(element.tagName === "INPUT" && element.type === "radio"){
					element.checked = false;
				}
			});
		}
	}

}