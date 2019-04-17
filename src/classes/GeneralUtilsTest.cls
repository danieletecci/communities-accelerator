@isTest
private class GeneralUtilsTest {
    
	@testSetup
    static void setupTest(){
    	String nameRecordType = 'Banner';
    	MockupFactory.generateAcceleratorSetting();
        
        String name = 'Argentina';
        List<Cluster__c> clusterRootList = MockupFactory.createCluster(name, null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('BuenosAires', cg.Id, 1, 'ClusterGroup', 'CGT');
    }

	@isTest
	static void replaceDynamicFieldsTest() {
		//Given
		List<SObject> sObjectList = Database.query(GeneralUtils.prefix('SELECT Id, name FROM [CMS]Cluster__c'));

		//When
		Test.startTest();
		String result = GeneralUtils.replaceDynamicFields(GeneralUtils.prefix('[![CMS]cluster__c.name]'), GeneralUtils.prefix('[CMS]Cluster__c'), (String)sObjectList[0].get('id'), false);
		String result2 = GeneralUtils.replaceDynamicFields(GeneralUtils.prefix('[![CMS]cluster__c.name]'), GeneralUtils.prefix('[CMS]Cluster__c'), (String)sObjectList[0].get('id'), true);
		Test.stopTest();

		//Then
		System.assertEquals(result, 'Argentina00');
		System.assertEquals(result2, '\'Argentina00\'');
	}

	@isTest
	static void getGroupKeyAndGroupTypeTest() {
		//Given
		String name = 'Test_Group_Name';
		//When
		Test.startTest();
		Map<String,String> result = GeneralUtils.getGroupKeyAndGroupType(name, 'RW', 'RO');
		Test.stopTest();

		//Then
		System.assertEquals(result.size(), 2);
		System.assertEquals(result.get('groupKey'), name);
	}

	@isTest
	static void getNetworkTest() {
		//Given
		
		//When
		Test.startTest();
		Network result = GeneralUtils.getNetwork('');
		Test.stopTest();

		//Then
		System.assertEquals(result, null);
	}

    @isTest
	static void isSafeFieldTest() {
		//Given

		//When
		Test.startTest();
		Boolean result = GeneralUtils.isSafeField(GeneralUtils.prefix('[CMS]Cluster__c'), 'name', true);
		Boolean result2 = GeneralUtils.isSafeField(GeneralUtils.prefix('[CMS]Test__c'), 'id', true);
		Test.stopTest();

		//Then
		System.assertEquals(result, true);
		System.assertEquals(result2, false);
	}

    @isTest
	static void isSafeObjectTest() {
		//Given

		//When
		Test.startTest();
		Boolean result = GeneralUtils.isSafeObject(GeneralUtils.prefix('[CMS]Cluster__c'), true);
		Boolean result2 = GeneralUtils.isSafeObject(GeneralUtils.prefix('[CMS]Test__c'), true);
		Test.stopTest();

		//Then
		System.assertEquals(result, true);
		System.assertEquals(result2, false);
	}

	@isTest
	static void getSubstringTest() {
		//Given
		String str = 'TestSubstring';
		String strShort = 'Test';
		Integer leng = 4;

		//When
		Test.startTest();
		String result = GeneralUtils.getSubstring(str, leng);
		String result2 = GeneralUtils.getSubstring(strShort, leng);
		Test.stopTest();

		//Then
		System.assertEquals(result.length(), leng);
		System.assertEquals(strShort, result2);
	}

 	@isTest
	static void getFilesByParentIdTest() {
		//Given
		String nameRecordType = 'Banner';
		Integer quantity = 3;
		List<Cluster__c> clusterList = [SELECT Id, name FROM Cluster__c];
		List<Component__c> componentList = MockupFactory.createComponent(nameRecordType, 1);
    	List<Content__c> contentList = MockupFactory.createContent(nameRecordType, clusterList[0], quantity);
    	List<ContentAssignment__c> contentAssignmentList = MockupFactory.createContentAssignment(contentList, componentList);
    	List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(quantity);
    	List<MediaElementAssignment__c> mediaElementAssList = MockupFactory.createMediaElementAssignment(contentList, mediaElementList);
    	List<ContentDocumentLink> contentDocumentLinkList = MockupFactory.createContentDocumentLink(mediaElementList);
    	Set<Id> contentDocIdList = new Set<Id>();
    	for(ContentDocumentLink cdl : contentDocumentLinkList){
    		contentDocIdList.add(cdl.Id);
    	}

		//When
		Test.startTest();
		Map<Id, List<ContentVersion>> idContentVersionMap = GeneralUtils.getFilesByParentId(contentDocIdList);
		Test.stopTest();

		//Then
		System.assertEquals(quantity, idContentVersionMap.size());
	}

    @isTest
	static void getFieldValueTest() {
		//Given
		List<SObject> sObjectList = Database.query(GeneralUtils.prefix('[CMS]SELECT Id, name FROM Cluster__c'));

		//When
		Test.startTest();
		Object result = GeneralUtils.getFieldValue(sObjectList[0], 'name');
		Test.stopTest();

		//Then
		System.assertEquals(result, sObjectList[0].get('name'));
	}

	@isTest
	static void joinFieldsTest() {
		//Given
		List<String> words = new List<String>{'Test', 'Test1', 'Test2'};

		//When
		Test.startTest();
		String result = GeneralUtils.joinFields(words);
		Test.stopTest();

		//Then
		System.assertEquals(words.size(), result.split(', ').size());
	}

	@isTest
	static void generateExternalIdTest() {
		/* Comment: Comprueba que dado un String, el metodo generateExternalId de la clase General Utils,
		retorne el valor del String recibido como parámetro, sin espacios, y con los carácteres especiales
		cambiados por guiones bajos. Y que dado el caso de que el contenido tenga el Cluster como parámetro
		tambien, entonces retorne un valor con formato: "Cluster_Nombre" */

		//Given
		String name1 = 'FrancoFolatelli';
		String name2 = 'Special°**° Characters';
		String name3 = 'Number123 space';
		String name4 = 'Number123 space';
		String name5 = 'Cachaça';
		String res1 = 'FrancoFolatelli';
		String res2 = 'Special____Characters';
		String res3 = 'Number123space';
		String res4 = name4.deleteWhitespace();
		
		String res5 = name5.deleteWhitespace();
		

		Cluster__c clusterC = [SELECT id, ExternalId__c FROM Cluster__c LIMIT 1];

		// When
		Test.startTest();
		String test1 = GeneralUtils.generateExternalId(name1, null, null);
		String test2 = GeneralUtils.generateExternalId(name2, null, null);
		String test3 = GeneralUtils.generateExternalId(name3, null, null);
		String test4 = GeneralUtils.generateExternalId(name4, clusterC.id, null);
		String test5 = GeneralUtils.generateExternalId(name5, clusterC.id, GeneralUtils.prefix('[CMS]Content__c'));
		Test.stopTest();
		String dateString = String.valueOf(datetime.now());
                 
        dateString = dateString.replaceAll('-','');
        dateString = dateString.replaceAll(':','');
        dateString = dateString.replaceAll(' ','');

		//Then
		System.assertEquals(test1, res1);
		System.assertEquals(test2, res2);
		System.assertEquals(test3, res3);
		System.assertEquals(test4, clusterC.ExternalId__c+'_'+res4.replaceAll('[^a-zA-Z0-9]', '_'));
		System.assertEquals(test5, clusterC.ExternalId__c+'_'+res5.replaceAll('[^a-zA-Z0-9]', '_')+'_'+ dateString);
	}

	@isTest
	static void hasSObjectFieldTest() {
		//Given
		List<Cluster__c> clusterList = [SELECT Id FROM Cluster__c LIMIT 1];
		//When
		Test.startTest();
		Boolean result = GeneralUtils.hasSObjectField('Id', clusterList[0]);
		Boolean result2 = GeneralUtils.hasSObjectField('Name', clusterList[0]);
		Test.stopTest();

		//Then
		System.assertEquals(result, true);
		System.assertEquals(result2, false);
	}

	@isTest
	static void getObjectFieldNamesTest() {
		//Given

		//When
		Test.startTest();
		Set<String> result = GeneralUtils.getObjectFieldNames(GeneralUtils.prefix('[CMS]Cluster__c'));
		Test.stopTest();

		//Then
		System.assertNotEquals(result.size(), 0);
	}
    
   @isTest
	static void getNavigationIdWhitExistingRecordTest() {
		// Given 
        Navigation__c nav = new Navigation__c(Name = 'NavTest', URL__c = 'testNav');
        insert nav;

		// When
		test.startTest();
		String navId = GeneralUtils.getNavigationId('/s/testNav');
		test.stopTest();

		// Then
		System.assertEquals(navId, nav.id);


	}

	  @isTest
	static void getNavigationIdWhitOutExistingRecordTest() {
		// Given 

		// When
		test.startTest();
		String navId = GeneralUtils.getNavigationId('/s/testNav');
		test.stopTest();

		// Then
		System.assertEquals(navId, '');


	}

		@isTest
	static void getNavigationIdBlankUrlTest() {
		// Given 
		//Navigation Record
        Navigation__c nav = new Navigation__c(Name = 'NavTest', URL__c = 'testNav');
        insert nav;


		// When
		test.startTest();
		String navId = GeneralUtils.getNavigationId('');
		test.stopTest();

		// Then
		System.assertEquals(navId, '');
	}
	
		@isTest
	static void getNavigationIdWrongUrlTest() {
		// Given 
		//Navigation Record
        Navigation__c nav = new Navigation__c(Name = 'NavTest', URL__c = 'testNav');
        insert nav;


		// When
		test.startTest();
		String navId = GeneralUtils.getNavigationId('wrongTestNav');
		test.stopTest();

		// Then
		System.assertEquals(navId, '');
	}
}