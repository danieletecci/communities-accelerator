@isTest
private class CG_ContentToolsControllerTest {
	@testSetup
    static void setupTest(){
    	String nameRecordType = 'Banner';
    	Integer quantity = 1;
    	MockupFactory.generateAcceleratorSetting();
        
        String name = 'Argentina';
        List<Cluster__c> clusterRootList = MockupFactory.createCluster(name, null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('BuenosAires', cg.Id, 1, 'ClusterGroup', 'CGT');

    	List<Component__c> componentList = MockupFactory.createComponent(nameRecordType, 1);
    	List<Content__c> contentList = MockupFactory.createContent(nameRecordType, clusterList[0], quantity);
    	List<ContentAssignment__c> contentAssignmentList = MockupFactory.createContentAssignment(contentList, componentList);
    	List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(quantity);
    	List<MediaElementAssignment__c> mediaElementAssList = MockupFactory.createMediaElementAssignment(contentList, mediaElementList);
    	List<ContentDocument> contentDocumentList = MockupFactory.createContentDocument('Test', quantity);
    	
    	for (Integer i = 0; i < mediaElementList.size(); i++){
    		mediaElementList[i].FileURLDesktop__c = 'testing/' + contentDocumentList[i].id;
    	}
    	update mediaElementList;
    }

	@isTest 
	static void initDataTest() {
		//When
		Content__c cont = [SELECT id FROM Content__c WHERE Cluster__c != NULL LIMIT 1];
		
		//Given
		Test.startTest();
		CG_ContentToolsController.ContentWrapper contentWr = CG_ContentToolsController.initData(cont.id);
		Test.stopTest();

		//Then
		System.assertEquals(contentWr.contentId, cont.Id);
	}
	
	@isTest 
	static void addToCartsTest() {
		//When
		Content__c cont = [SELECT id FROM Content__c WHERE Cluster__c != NULL LIMIT 1];
		CG_ContentToolsController.ContentWrapper contentWr = CG_ContentToolsController.initData(cont.id);
		
		//Given
		Test.startTest();
		contentWr = CG_ContentToolsController.addToCarts(JSON.serialize(contentWr));
		Test.stopTest();

		//Then
		System.assertEquals(contentWr.contentId, cont.Id);
	}

	@isTest 
	static void imageToBase64Test() {
		//When
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		//Given
		Test.startTest();
		String url = CG_ContentToolsController.imageToBase64('http://example.com/example/test');
		Test.stopTest();

		//Then
		System.assertNotEquals(url, NULL);
	}
}