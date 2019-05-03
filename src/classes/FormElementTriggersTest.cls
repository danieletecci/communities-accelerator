@isTest(seeAllData = false)
public class FormElementTriggersTest {
	
	@isTest 
	static void insertFormElementTest(){
		//Given
		MockupFactory.generateAcceleratorSetting();
        Cluster__c cluster = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT')[0];
		//When
		Test.startTest();
		MockupFactory.createForm('testName', 'testName', 'testRetrieval', cluster.id);		
		Test.stopTest();
		//Then
		FormElement__c formElement = [SELECT id, ExternalId__c FROM FormElement__c LIMIT 1];
        System.assert(formElement.ExternalId__c != null);

	}

	@isTest
	static void updateFormElement(){
		//Given
		MockupFactory.generateAcceleratorSetting();
        Cluster__c cluster = MockupFactory.createCluster('Argentina', null, 2, 'ClusterRoot', 'CRT')[0];
        MockupFactory.createForm('testName', 'testName', 'testRetrieval', cluster.id);
		//When
		Test.startTest();
		FormElement__c formElement = [SELECT id, name FROM FormElement__c LIMIT 1];
        formElement.name = 'updated';
        update formElement;
        Test.stopTest();
		//Then
		formElement = [SELECT id, ExternalId__c FROM FormElement__c LIMIT 1];
        System.assert(formElement.ExternalId__c != null);

	}
    
    @isTest
	static void incorrectObjectApiNameTest(){
		//Given
		MockupFactory.generateAcceleratorSetting();
        Cluster__c cluster = MockupFactory.createCluster('Argentina', null, 2, 'ClusterRoot', 'CRT')[0];
        MockupFactory.createForm('testName', 'testName', 'testRetrieval', cluster.id);
		//When
		Test.startTest();
		FormElement__c formElement = [SELECT id, name FROM FormElement__c LIMIT 1];
        formElement.ObjectApiName__c = 'wrongApiName';
        try{
            update formElement;
        
        //Then
        }catch(DMLException e){
            system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        Test.stopTest();

	}
    
    @isTest
	static void incorrectFieldApiNameTest(){
		//Given
		MockupFactory.generateAcceleratorSetting();
        Cluster__c cluster = MockupFactory.createCluster('Argentina', null, 2, 'ClusterRoot', 'CRT')[0];
        MockupFactory.createForm('testName', 'testName', 'testRetrieval', cluster.id);
		//When
		Test.startTest();
		FormElement__c formElement = [SELECT id, name FROM FormElement__c LIMIT 1];
        formElement.ObjectApiName__c = '';
        try{
            update formElement;
        
        //Then
        }catch(DMLException e){
            system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        Test.stopTest();

	}
}
