@isTest
public class ComponentUtilsTest {
	
	@isTest static void getComponentTest_Extid(){
		/* Comment: Comprueba que dado un String correspondiente a ExternalId de un componente, un fieldSet
		representado por un Set<String>, y un device, el método getComponent de la clase ComponentUtils, retorne el
		componente representado por dado External Id. */

		//Given
		String componentExternalId1 = 'BannerComponent_0';
        MockupFactory.createComponent('Banner', 1);
        
		set<String> bannerFieldSet = new set<String>();
        bannerFieldSet.add('Name');
        bannerFieldSet.add('[CMS]ExternalId__c');
        bannerFieldSet.add('[CMS]Datasource__c');
        bannerFieldSet.add('[CMS]Status__c');
        bannerFieldSet.add('RecordTypeId');
		
		//When
		Test.startTest();
		String test1 = ComponentUtils.getComponent(componentExternalId1, bannerFieldSet, 'Desktop').ExternalId__c;
		Test.stopTest();

		//Then
		System.assertEquals(componentExternalId1, test1);
	
	}

	@isTest static void getComponentTestwithId(){
		/* Comment: Comprueba que dado un String correspondiente a el Id de un componente, un fieldSet
		representado por un Set<String>, y un device, el método getComponent de la clase ComponentUtils, retorne el
		componente representado por dado Id. */

		//Given
        MockupFactory.createComponent('Banner', 1);
		List<Component__c> component1 = [SELECT Id from Component__c LIMIT 1];
		Id componentId1 = component1[0].Id;
		set<String> bannerFieldSet = new set<String>();
        bannerFieldSet.add('Name');
        bannerFieldSet.add('[CMS]ExternalId__c');
        bannerFieldSet.add('[CMS]Datasource__c');
        bannerFieldSet.add('[CMS]Status__c');
        bannerFieldSet.add('RecordTypeId');
		
		
		//When
		Test.startTest();
		String test1 = ComponentUtils.getComponent(componentId1, bannerFieldSet, 'Desktop').Id;
		Test.stopTest();

		//Then
		System.assertEquals(componentId1, test1);
	}
}