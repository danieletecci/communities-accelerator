@isTest(seeAllData = false)
public class MediaElementUploadControllerTest {
	
	@isTest 
	static void getMediaElementTest(){
		/* Comment: Comprueba que dado un String correspondiente a un id de un mediaElement el método getMedia
		de la clase MediaElemetUploaderController retorne el media element correspondiente. */

		//Given
		List<MediaElement__c> listMedia= MockupFactory.createMediaElement(1);
		MediaElement__c media = listMedia.get(0);

		//When
		Test.startTest();
		MediaElement__c test1 = MediaElementUploadController.getMedia(media.Id);
		Test.stopTest();

		//Then
		System.assertEquals(media.Id, test1.Id);

	}

	@isTest 
	static void getMediaElementInWrapperTest(){
		/* Comment: Comprueba que dado un String correspondiente a un id de un mediaElement el método getRecord
		de la clase MediaElemetUploaderController retorne el media element correspondiente dentro de un Wrapper. */

		//Given
		List<MediaElement__c> listMedia= MockupFactory.createMediaElement(1);
		MediaElement__c media = listMedia.get(0);
		//When
		Test.startTest();
		MediaElementUploadController.MediaElementWrapper test1 = MediaElementUploadController.getRecord(media.Id);
		Test.stopTest();

		//Then
		System.assertEquals(media.Id, test1.mediaElement.Id);

	}


	@isTest 
	static void getFileByIdTest(){
		/* Comment: Comprueba que dado un String correspondiente a un id de un archivo el método getFileById
		de la clase MediaElemetUploaderController retorne un String base64 de la imagen almacenada en el
		ContentVersion correspondiente al id dado. */

		//Given
		List<MediaElement__c> listMedia= MockupFactory.createMediaElement(1);
		MediaElement__c media = listMedia.get(0);

        List<ContentDocumentLink> contentDocList = MockupFactory.createContentDocumentLink(listMedia);
        ContentDocumentLink contentLink = contentDocList.get(0);
		
		ContentVersion contv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId =: contentLink.contentDocumentId];
		String vdata=EncodingUtil.base64Encode(contv.VersionData);
		//When
		Test.startTest();
		String result = MediaElementUploadController.getFileById(contv.ContentDocumentId);
		Test.stopTest();

		//Then
		System.assertEquals(vdata, result);

	}


	@isTest 
	static void createFileTest(){

		/* Comment: Comprueba que se asigne el file dado al media element correspondiente segun los parametros pasados. */

		//Given
		
		List<MediaElement__c> listMedia= MockupFactory.createMediaElement(1);
		MediaElement__c media = listMedia.get(0);
        
        List<ContentDocumentLink> contentDocList = MockupFactory.createContentDocumentLink(listMedia);
        ContentDocumentLink contentLink = contentDocList.get(0);
		
		ContentVersion contv = [SELECT Id, ContentDocumentId, VersionData, Title, FileExtension FROM ContentVersion WHERE ContentDocumentId =: contentLink.contentDocumentId];
		
		String vdata=EncodingUtil.base64Encode(contv.VersionData);

		//When
		Test.startTest();
		String result = MediaElementUploadController.createFile(media.Id, contv.ContentDocumentId, vdata, contv.Title, '2', '2', 'Desktop');
		Test.stopTest();

		//Then
		MediaElement__c mediaResult = [SELECT Id, ExternalId__c, FileNameDesktop__c, FileURLDesktop__c,
							 		WidthDesktop__c, HeightDesktop__c, DesktopFileExtension__c
							  		FROM MediaElement__c WHERE id =: result];

		System.assertEquals(mediaResult.FileNameDesktop__c, contv.Title);
		System.assertNotEquals(mediaResult.FileURLDesktop__c, null);
		System.assertEquals(mediaResult.WidthDesktop__c, Decimal.valueOf(2));
		System.assertEquals(mediaResult.HeightDesktop__c, Decimal.valueOf(2));
		System.assertEquals(mediaResult.DesktopFileExtension__c, contv.FileExtension);
	}


	@isTest 
	static void createFileWihtOutFileIdTest(){
		/* Comment: Comprueba que se asigne el file dado al media element correspondiente segun los parametros pasados. */

		//Given
		List<MediaElement__c> listMedia= MockupFactory.createMediaElement(1);
		MediaElement__c media = listMedia.get(0);
		
		 String base64Data = 'iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==';

		//When
		Test.startTest();
		String resultTablet = MediaElementUploadController.createFile(media.Id, null, base64Data, 'Title_test_Tablet', '2', '2', 'Tablet');
		String resultMobile = MediaElementUploadController.createFile(media.Id, null, base64Data, 'Title_test_Mobile', '2', '2', 'Mobile');
		Test.stopTest();

		//Then
		MediaElement__c mediaResultT = [SELECT Id, ExternalId__c, FileNameTablet__c, FileURLTablet__c,
										WidthTablet__c, HeightTablet__c, TabletFileExtension__c 
										FROM MediaElement__c WHERE id =: resultTablet];

		System.assertEquals(mediaResultT.FileNameTablet__c, 'Title_test_Tablet');
		System.assertNotEquals(mediaResultT.FileURLTablet__c, null);
		System.assertEquals(mediaResultT.WidthTablet__c, Decimal.valueOf(2));
		System.assertEquals(mediaResultT.HeightTablet__c, Decimal.valueOf(2));

		MediaElement__c mediaResultM = [SELECT Id, ExternalId__c, FileNameMobile__c,
										FileURLMobile__c, WidthMobile__c, HeightMobile__c
										 FROM MediaElement__c WHERE id =: resultMobile];

		System.assertEquals(mediaResultM.FileNameMobile__c, 'Title_test_Mobile');
		System.assertNotEquals(mediaResultM.FileURLMobile__c, null);
		System.assertEquals(mediaResultM.WidthMobile__c, Decimal.valueOf(2));
		System.assertEquals(mediaResultM.HeightMobile__c, Decimal.valueOf(2));

	}


	@isTest 
	static void deleteFileDesktopTest(){
		/* Comment: Comprueba que dado un String correspondiente a un ID de un MediaElement el método deleteFileDesktop
		de la clase MediaElemetUploaderController elimine dicho ContentDocument y su referencia del media element correspondiente. */

		//Given
		List<MediaElement__c> listMedia= MockupFactory.createMediaElement(1);
		MediaElement__c media = listMedia.get(0);

        List<ContentDocumentLink> contentDocList = MockupFactory.createContentDocumentLink(listMedia);
        ContentDocumentLink contentLink = contentDocList.get(0);

		ContentVersion contv = [SELECT Id, ContentDocumentId, VersionData, Title FROM ContentVersion WHERE ContentDocumentId =: contentLink.contentDocumentId];
		String vdata=EncodingUtil.base64Encode(contv.VersionData);

		MediaElementUploadController.createFile(media.Id, contv.ContentDocumentId, vdata, contv.Title, '2', '2', 'Desktop');
		
		//When
		Test.startTest();
		MediaElementUploadController.deleteFileDesktop(media.Id);
		Test.stopTest();

		//Then
		ContentVersion contvResult;
		try{
			 contvResult= [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId =: contentLink.contentDocumentId];
		}catch(QueryException e){
			contvResult= null;
		}
		MediaElement__c mediaResult = [SELECT Id, ExternalId__c, FileURLDesktop__c, 
							DesktopFileExtension__c, FileNameDesktop__c, HeightDesktop__c,
							WidthDesktop__c FROM MediaElement__c 
							WHERE id =: media.Id];

		System.assertEquals(contvResult, null);
		System.assertEquals(mediaResult.DesktopFileExtension__c, null);
		System.assertEquals(mediaResult.FileNameDesktop__c, null);
		System.assertEquals(mediaResult.FileURLDesktop__c, null);
		System.assertEquals(mediaResult.HeightDesktop__c, null);
		System.assertEquals(mediaResult.WidthDesktop__c, null);
	}

	@isTest 
	static void deleteFileTabletTest(){
		/* Comment: Comprueba que dado un String correspondiente a un ID de un MediaElement el método deleteFileTablet
		de la clase MediaElemetUploaderController elimine dicho ContentDocument y su referencia del media element correspondiente. */

		//Given
		List<MediaElement__c> listMedia= MockupFactory.createMediaElement(1);
		MediaElement__c media = listMedia.get(0);

        List<ContentDocumentLink> contentDocList = MockupFactory.createContentDocumentLink(listMedia);
        ContentDocumentLink contentLink = contentDocList.get(0);

		ContentVersion contv = [SELECT Id, ContentDocumentId, VersionData, Title FROM ContentVersion WHERE ContentDocumentId =: contentLink.contentDocumentId];
		String vdata=EncodingUtil.base64Encode(contv.VersionData);

		MediaElementUploadController.createFile(media.Id, contv.ContentDocumentId, vdata, contv.Title, '2', '2', 'Tablet');
		//When
		Test.startTest();
		MediaElementUploadController.deleteFileTablet(media.Id);
		Test.stopTest();

		//Then
		ContentVersion contvResult;
		try{
			 contvResult= [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId =: contentLink.contentDocumentId];
		}catch(QueryException e){
			contvResult= null;
		}
		MediaElement__c mediaResult = [SELECT Id, ExternalId__c, FileURLTablet__c, 
							TabletFileExtension__c, FileNameTablet__c, HeightTablet__c,
							WidthTablet__c FROM MediaElement__c 
							WHERE id =: media.Id];

		System.assertEquals(contvResult, null);
		System.assertEquals(mediaResult.TabletFileExtension__c, null);
		System.assertEquals(mediaResult.FileNameTablet__c, null);
		System.assertEquals(mediaResult.FileURLTablet__c, null);
		System.assertEquals(mediaResult.HeightTablet__c, null);
		System.assertEquals(mediaResult.WidthTablet__c, null);
	}
	

		@isTest 
	static void deleteFileMobileTest(){

		/* Comment: Comprueba que dado un String correspondiente a un ID de un MediaElement el método deleteFileMobile
		de la clase MediaElemetUploaderController elimine dicho ContentDocument y su referencia del media element correspondiente. */

		//Given
		List<MediaElement__c> listMedia= MockupFactory.createMediaElement(1);
		MediaElement__c media = listMedia.get(0);

        List<ContentDocumentLink> contentDocList = MockupFactory.createContentDocumentLink(listMedia);
        ContentDocumentLink contentLink = contentDocList.get(0);

		ContentVersion contv = [SELECT Id, ContentDocumentId, VersionData, Title FROM ContentVersion WHERE ContentDocumentId =: contentLink.contentDocumentId];
		String vdata=EncodingUtil.base64Encode(contv.VersionData);

				MediaElementUploadController.createFile(media.Id, contv.ContentDocumentId, vdata, contv.Title, '2', '2', 'Mobile');
		//When
		Test.startTest();
		MediaElementUploadController.deleteFileMobile(media.Id);
		Test.stopTest();

		//Then
		ContentVersion contvResult;
		try{
			 contvResult= [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId =: contentLink.contentDocumentId];
		}catch(QueryException e){
			contvResult= null;
		}
		MediaElement__c mediaResult = [SELECT Id, ExternalId__c, FileURLMobile__c, 
							MobileFileExtension__c, FileNameMobile__c, HeightMobile__c,
							WidthMobile__c FROM MediaElement__c 
							WHERE id =: media.Id];

		System.assertEquals(contvResult, null);
		System.assertEquals(mediaResult.MobileFileExtension__c, null);
		System.assertEquals(mediaResult.FileNameMobile__c, null);
		System.assertEquals(mediaResult.FileURLMobile__c, null);
		System.assertEquals(mediaResult.HeightMobile__c, null);
		System.assertEquals(mediaResult.WidthMobile__c, null);
	}			
}