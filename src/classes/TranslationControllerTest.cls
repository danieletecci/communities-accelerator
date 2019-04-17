@isTest
private class TranslationControllerTest {

	@testSetup
    static void setupTest(){
    	String nameRecordType = 'Banner';
    	MockupFactory.generateAcceleratorSetting();
        
        String name = 'Argentina';
        String nameGroup = 'Buenos Aires';
        List<Cluster__c> clusterRootList = MockupFactory.createCluster(name, null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster(nameGroup, cg.Id, 1, 'ClusterGroup', 'CGT');

    	List<Component__c> componentList = MockupFactory.createComponent(nameRecordType, 1);
    	List<Content__c> contentList = MockupFactory.createContent(nameRecordType, clusterList[0], 1);
    	List<ContentAssignment__c> contentAssignmentList = MockupFactory.createContentAssignment(contentList, componentList);
    }

	@isTest 
	static void getLanguagesTest() {
		Content__c cont = [SELECT id from Content__c where Cluster__c!=null LIMIT 1];
		Test.startTest();
		TranslationController.RecordsWrapper rw = TranslationController.getLanguages('[CMS}Content__c', '[CMS]Description__c, Name', cont.id);
		Test.stopTest();
		System.assertNotEquals(rw, null);
	}

	@isTest 
	static void changeLanguageTest() {
		Content__c cont = [SELECT id from Content__c where Cluster__c!=null LIMIT 1];
        Map<String,String> apiNameTypeMap = new Map<String,String>();
        apiNameTypeMap.put('Name','Text');
        MockUpFactory.createTranslation(cont, apiNameTypeMap, 'it');
		String parentLookupName = '[CMS]Content__c';
		TranslationController.RecordsWrapper rw = TranslationController.getLanguages(parentLookupName, '[CMS]Description__c, Name', cont.id);
		String queryStr = 'SELECT id FROM ' + parentLookupName + ' LIMIT 1';
		sObject sobj = Database.query(queryStr);

		Test.startTest();
		rw = TranslationController.changeLanguage(parentLookupName, 'it', (String)sobj.get('Id'), JSON.serialize(rw));
		Test.stopTest();
		System.assertEquals(rw.defaultLanguage, 'it');
		System.debug(rw);
	}

	@isTest 
	static void saveTranslationTest() {
		Content__c cont = [SELECT id from Content__c where Cluster__c!=null LIMIT 1];		
		String parentLookupName = '[CMS]Content__c';
		String fieldSet = '[CMS]Description__c, Name,[CMS]Extract__c';
		TranslationController.RecordsWrapper rw = TranslationController.getLanguages(parentLookupName, fieldSet, cont.id);
		String queryStr = 'SELECT id FROM ' + parentLookupName + ' LIMIT 1';
		sObject sobj = Database.query(queryStr);

		rw = TranslationController.changeLanguage(parentLookupName, 'it', (String)sobj.get('Id'), JSON.serialize(rw));
		for(Integer i = 0 ; i < rw.dataObject.size(); i++){
			rw.dataObject[i].value = 'Tutto Bouno';
		}

		Test.startTest();
		rw = TranslationController.saveTranslation(parentLookupName, (String)sobj.get('Id'), JSON.serialize(rw));
		List<Translation__c> translationList = [SELECT Id, FieldApiName__c FROM Translation__c];
		System.assertEquals(translationList.size(), fieldSet.split(',').size());

		rw.dataObject[2].value = 'Cambio';
		rw = TranslationController.saveTranslation(parentLookupName, (String)sobj.get('Id'), JSON.serialize(rw));
		Test.stopTest();
		System.assertEquals(rw.dataObject[2].value, 'Cambio');
	}	
	
}