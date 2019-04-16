@isTest
public with sharing class ContentRecordTypeModalControllerTest {
	
	@isTest 
	static void getObjectLabel() {
		ContentRecordTypeModalController.getObjectLabel('Content__c');
	}

	@isTest 
	static void getRecordTypes() {
        MockupFactory.generateAcceleratorSetting();
		ContentRecordTypeModalController.getContentRecordTypes('Content__c');
		ContentRecordTypeModalController.getTemplateRecordTypes('Content__c');
	}
}