@isTest
private class CG_ContentCartControllerTest {
	@testSetup
    static void setupTest(){
    	String nameRecordType = 'Banner';
    	Integer quantity = 3;
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
    	List<ContentCartItem__c> contentCartItemList = MockupFactory.createContentCartItem(new List<Content__c> {contentList[0], contentList[1]});
		List<ContentDocument> contentDocumentList = MockupFactory.createContentDocument('Test', quantity);
    	
    	for (Integer i = 0; i < mediaElementList.size(); i++){
    		mediaElementList[i].FileURLDesktop__c = 'http://example.com/example/test' + contentDocumentList[i].id;
    	}
    	mediaElementList[1].FileURLDesktop__c = 'http://example.com/example/test';
    	update mediaElementList;

    	List<ContentDistribution> contentDistributionList = new List<ContentDistribution>();
    	for(ContentVersion contentVers : [SELECT id FROM ContentVersion WHERE contentdocumentid IN: contentDocumentList]){
	        contentDistributionList.add(new ContentDistribution(
	        Name = 'Test' + contentVers.Id,
	        ContentVersionId = contentVers.Id,
	        PreferencesAllowOriginalDownload = true,
	        PreferencesAllowPDFDownload = false,
	        PreferencesAllowViewInBrowser = true,
	        PreferencesExpires = false,
	        PreferencesLinkLatestVersion = true));
    	}
        insert contentDistributionList;
    }

	@isTest 
	static void initDataTest() {
		//When
		
		//Given
		Test.startTest();
		CG_ContentCartController.ContentCartWrapper contentCartWr = CG_ContentCartController.initData('0','2');
		Test.stopTest();

		//Then
		System.assertEquals(contentCartWr.cartItemList.size(), 2);
	}

	@isTest 
	static void infiniteScrollTest() {
		//When

		//Given
		Test.startTest();
		CG_ContentCartController.ContentCartWrapper contentCartWr = CG_ContentCartController.initData('1','1');
		Test.stopTest();

		//Then
		System.assertEquals(contentCartWr.cartItemList.size(), 1);
	}
	
	@isTest 
	static void addContentToCartTest() {
		//When
		List<Cluster__c> clusterList = [SELECT id FROM Cluster__c];
		CG_ContentCartController.initData('0','2');
		List<Content__c> contentList = MockupFactory.createContent('News', clusterList[0], 1);
    
		//Given
		Test.startTest();
		Boolean addedToCart = CG_ContentCartController.addContentToCart(contentList[0].id);
		
		//Then
		System.assertEquals(true, addedToCart);
	}

	@isTest 
	static void deleteCartItemsTest() {
		//When
		List<ContentCartItem__c> contentCart = [SELECT id FROM ContentCartItem__c];
		CG_ContentCartController.ContentCartWrapper contentCartWr = CG_ContentCartController.initData('0','2');
		
		//Given
		Test.startTest();
		contentCartWr = CG_ContentCartController.deleteCartItems(contentCart[0].id, JSON.serialize(contentCartWr), false);
		Test.stopTest();

		//Then
		System.assertEquals(contentCartWr.cartItemList.size(), contentCart.size()-1);
	}

	@isTest 
	static void deleteAllCartItemsTest() {
		//When
		CG_ContentCartController.ContentCartWrapper contentCartWr = CG_ContentCartController.initData('0','2');
		
		//Given
		Test.startTest();
		contentCartWr = CG_ContentCartController.deleteCartItems('', JSON.serialize(contentCartWr), true);
		Test.stopTest();

		//Then
		System.assertEquals(contentCartWr.cartItemList.size(), 0);
	}

	@isTest 
	static void downloadAllItemsTest() {
		//When
		CG_ContentCartController.ContentCartWrapper contentWr = CG_ContentCartController.initData('0','2');
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		//Given
		Test.startTest();
		Map <String, String> imagenMap = CG_ContentCartController.downloadAllItems(JSON.serialize(contentWr));
		Test.stopTest();
		
		//Then
		System.assertEquals(imagenMap.keySet().size(), 2);
	}	

	@isTest 
	static void initDataExternalTest() {
		//When
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		List<MediaElement__c> mediaElementList = [SELECT Id FROM MediaElement__c];

        for(MediaElement__c media : mediaElementList){
        	media.FileURLDesktop__c='https://www.google.com/logos/doodles/2018/gottfried-wilhelm-leibnizs-372nd-birthday-4525892901535744-2x';
        }
        update mediaElementList;

        CG_ContentCartController.ContentCartWrapper contentWr = CG_ContentCartController.initData('0','10');
		//Given
		Test.startTest();
		Map <String, String> imagenMap = CG_ContentCartController.downloadAllItems(JSON.serialize(contentWr));
		Test.stopTest();
		
		//Then
		System.assertEquals(imagenMap.keySet().size(), 1);
	}	
}