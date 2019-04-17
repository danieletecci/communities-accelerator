@isTest
public with sharing class ContentRecordTypeModalControllerTest {
	
	@isTest 
	static void getObjectLabel() {
		ContentRecordTypeModalController.getObjectLabel('[CMS]Content__c');
	}

	@isTest 
	static void getRecordTypes() {
        MockupFactory.generateAcceleratorSetting();
		ContentRecordTypeModalController.getContentRecordTypes('[CMS]Content__c');
		ContentRecordTypeModalController.getTemplateRecordTypes('[CMS]Content__c');
	}
}