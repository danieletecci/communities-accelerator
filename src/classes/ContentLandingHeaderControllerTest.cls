@isTest
public with sharing class ContentLandingHeaderControllerTest {
	
	@isTest 
	static void getObjectLabel() {
		ContentLandingHeaderController.getObjectLabel('[CMS]Content__c');
	}

	@isTest 
	static void getPicklistValues() {
		ContentLandingHeaderController.getPicklistValues('[CMS]Content__c','[CMS]Status__c');
	}

	@isTest 
	static void hasCreateTemplateButton() {
		ContentLandingHeaderController.hasCreateTemplateButton();
	}
	
	@isTest 
	static void hasCreateContentButton() {
		ContentLandingHeaderController.hasCreateContentButton();
	}

}