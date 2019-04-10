@isTest
public with sharing class CG_ContentCatalogControllerTest {
	@testSetup
	public static void setParameters(){
        MockupFactory.generateAcceleratorSetting();
        MockupFactory.createCluster('Global', null, 1, 'ClusterRoot', 'CRT');
	}

	@isTest
	public static void getCatalogWrapperByBrand(){
		//Given
		Cluster__c cluster = [SELECT Id FROM Cluster__c LIMIT 1];
		String nameRecordType = 'Content Catalog';
		RecordType recordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Component__c' AND Name =: nameRecordType];
    	Component__c componentElem = new Component__c(Name = 'Test', Cluster__c = cluster.Id, RecordTypeId = recordType.Id, Datasource__c = 'Brands', CatalogContentType__c = 'Logo');
		List<Component__c> component =  new List<Component__c>();
		component.add(componentElem);
		insert component;
		List<Content__c> content = MockupFactory.createContent('Brand Detail', cluster, 1);
		content[0].Description__c = 'Soy un test';
		update content[0];
		List<Brand__c> brand = MockupFactory.createBrand('brandTest', 1, cluster.Id);
		brand[0].BrandContent__c = content[0].Id;
		update brand[0];
		List<Category__c> category = MockupFactory.createCategory('categoryTest', 1, cluster.Id);
		List<CategoryAssignment__c> categoryAssignment = MockupFactory.createCategoryAssignment(category,component); 
		List<Tag__c> tag = MockupFactory.createTag('tagTest','#testingmethod', 1, cluster.Id);
		List<TagAssignment__c> tagAssignment = MockupFactory.createTagAssignment(tag, component, content);
		
		//When
		test.startTest();
		Component__c c = [SELECT ExternalId__c FROM Component__c WHERE Id =: component LIMIT 1];
		String componentToWrap = c.ExternalId__c;
		String brandToWrap = String.valueOf(brand[0]);
		String categoryToWrap = String.valueOf(category[0].Id);
		String tagToWrap = String.valueOf(tag[0].Id);
		Set<Id> setCategory = new Set<Id>();
		
		for(Content__c cont : content){
			setCategory.add(category[0].Id);	
		}

		CG_ContentCatalogController.CatalogWrapper catWrapperMain = CG_ContentCatalogController.getCatalogWrapper(componentToWrap, '', '', brandToWrap, tagToWrap, categoryToWrap, '');
		test.stopTest();

		//Then
	}

	@isTest
	public static void getContentWrapper(){
		//Given
		Cluster__c cluster = [SELECT Id FROM Cluster__c LIMIT 1];
		String nameRecordType = 'Content Catalog';
		RecordType recordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Component__c' AND Name =: nameRecordType];
    	Component__c componentElem = new Component__c(Name = 'Test', Cluster__c = cluster.Id, RecordTypeId = recordType.Id, Datasource__c = 'Brands');
		List<Component__c> component =  new List<Component__c>();
		component.add(componentElem);
		insert component;
		List<Content__c> content = MockupFactory.createContent('Brand Detail', cluster, 1);
		content[0].Title__c = 'Soy un test';
		update content[0];
		List<Brand__c> brand = MockupFactory.createBrand('brandTest', 1, cluster.Id);
		brand[0].BrandContent__c = content[0].Id;
		update brand[0];
		List<Category__c> category = MockupFactory.createCategory('categoryTest', 1, cluster.Id);
		List<CategoryAssignment__c> categoryAssignment = MockupFactory.createCategoryAssignment(category,component); 
		List<Tag__c> tag = MockupFactory.createTag('tagTest','#testingmethod', 1, cluster.Id);
		List<TagAssignment__c> tagAssignment = MockupFactory.createTagAssignment(tag, component, content);
		List<MediaElement__c> mediaElement = MockupFactory.createMediaElement(1);
		List<MediaElementAssignment__c> mediaElementAssignment = MockupFactory.createMediaElementAssignment(content, mediaElement);
		
		//When
		test.startTest();
		Set<Id> contentId = new Set<Id>();
		contentId.add(content[0].Id);

		List<CG_ContentCatalogController.QueryContentWrapper> contWrapper = CG_ContentCatalogController.getContentWrapper(contentId, 'Title__c ASC', 1 , true, 1);
		test.stopTest();
		//Then
	}
}