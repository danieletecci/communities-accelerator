@isTest
public class CG_BrandDetailControllerTest {

	@testSetup
	static void testSetup(){
		MockupFactory.generateAcceleratorSetting();
		Cluster__c cluster = MockupFactory.createCluster('ClusterTest', null, 1, 'ClusterRoot', 'CRT')[0];
		Brand__c brandMaster = MockupFactory.createBrand('TestBrandMaster', 1, cluster.Id)[0];
		Brand__c brandVariant = MockupFactory.createBrand('TestBrandVariant', 1, cluster.Id)[0];
		Component__c component = MockupFactory.createComponent('Brand Detail', 1)[0];
		Content__c content = MockupFactory.createContent('Brand Detail', cluster, 1)[0];
        MediaElement__c mediaElement = MockupFactory.createMediaElement(1)[0];
        MediaElementAssignment__c mediaElementAssignment = MockupFactory.createMediaElementAssignment(new List<Content__c>{content}, new List<MediaElement__c>{mediaElement})[0]; 

        RecordType rt1 = [SELECT Id FROM RecordType WHERE Name = 'Brand'];
        brandMaster.RecordTypeId = rt1.Id;
        brandMaster.BrandContent__c = content.Id;
        update brandMaster;        
        RecordType rt2 = [SELECT Id FROM RecordType WHERE Name = 'Brand Variant'];
        brandVariant.RecordTypeId = rt2.Id;
        brandVariant.MasterBrand__c = brandMaster.Id;
        brandVariant.BrandContent__c = content.Id;
        update brandVariant;
        content.Description__c = 'DescriptionTest';
        content.Title__c = 'TitleTest';
        update content;
		mediaElement.FileURLDesktop__c = 'FileURLDesktopTest';
		update mediaElement;
		mediaElementAssignment.Placement__c = 'BrandImageBanner';
		update mediaElementAssignment;
	}

	@isTest
	static void getBrandWrapperBrand(){

		// Given
		Brand__c brand = [SELECT Id FROM Brand__c WHERE RecordType.Name = 'Brand' LIMIT 1];
		Brand__c variant = [SELECT Id FROM Brand__c WHERE RecordType.Name = 'Brand Variant' LIMIT 1];
        Component__c component = [SELECT Id, ExternalId__c FROM Component__c LIMIT 1];
        
        // When
        Test.startTest();
		CG_BrandDetailController.BrandDetailWrapper wrapper = CG_BrandDetailController.getBrandWrapper(brand.Id, component.ExternalId__c);
        Test.stopTest();

		// Then
		System.assertEquals('DescriptionTest', wrapper.description);
		System.assertEquals(null, wrapper.title);
		System.assertEquals('FileURLDesktopTest', wrapper.imageBannerURL);
		System.assertEquals(null, wrapper.imageLogoURL);
		System.assertEquals(false, wrapper.isVariant);
		System.assertEquals('TitleTest', wrapper.variants[0].title);
		System.assertEquals('FileURLDesktopTest', wrapper.variants[0].imageURL);
		System.assertEquals(variant.Id, wrapper.variants[0].Id);
	}

	@isTest
	static void getBrandWrapperBrandVariant(){

		// Given
		Brand__c brand = [SELECT Id FROM Brand__c WHERE RecordType.Name = 'Brand Variant' LIMIT 1];
        Component__c component = [SELECT Id, ExternalId__c FROM Component__c LIMIT 1];
        
        // When
        Test.startTest();
		CG_BrandDetailController.BrandDetailWrapper wrapper = CG_BrandDetailController.getBrandWrapper(brand.Id, component.ExternalId__c);
        Test.stopTest();

		// Then
		System.assertEquals('DescriptionTest', wrapper.description);
		System.assertEquals('TitleTest', wrapper.title);
		System.assertEquals(true, wrapper.isVariant);
	}

}