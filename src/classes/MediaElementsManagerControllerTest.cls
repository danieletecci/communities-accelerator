@isTest
public class MediaElementsManagerControllerTest {
	@testSetup 
	static void setup(){
		// Given in all cases
		MockupFactory.generateAcceleratorSetting();
		MockupFactory.createCluster('global', null, 1, 'ClusterRoot', 'CRT');
	}
	@isTest 
	static void PA181_CASE_1(){
		// Comment: Se busca mediante un string, con una lista de places separados por coma, los media elements asignados al contenido que esten en el string

		// Given
		Cluster__c cluster = [SELECT id FROM Cluster__c LIMIT 1];
		List<Content__c> content = MockupFactory.createContent('Event', cluster, 1);
		List<MediaElement__c> medElement = MockupFactory.createMediaElement(1);

		insert new MediaElementAssignment__c (MediaElement__c = medElement[0].id, Content__c = content[0].id , Placement__c = 'icon');
		insert new MediaElementAssignment__c (MediaElement__c = medElement[0].id, Content__c = content[0].id , Placement__c = 'small');
		insert new MediaElementAssignment__c (MediaElement__c = medElement[0].id, Content__c = content[0].id , Placement__c = 'big');
		// When
		Test.startTest();
		list<MediaElementsManagerController.RecordsWrapper> rw = MediaElementsManagerController.getRecord(content[0].id, 'icon, big', 'Content__c', 'MediaElementAssignment__c');
		Test.stopTest();
		// Then
		System.assertEquals(2 ,rw.size());

	}
	@isTest 
	static void PA181_CASE_2(){
		// Comment:Se buscan todos los media elements sin filtro ni paginado

		// Given
		List<MediaElement__c> medElement = MockupFactory.createMediaElement(3);
		// When
		Test.startTest();
		list<MediaElementsManagerController.ContentWrapper> searchedList = MediaElementsManagerController.getData('0', '', '5', 'false');
		Test.stopTest();
		// Then
		System.assertEquals(searchedList.size(), medElement.size());
	}	
	@isTest 
	static void PA181_CASE_3(){
		// Comment: Se buscan todos los media elements que cumplan con un filtro, sin paginado

		// Given
		List<MediaElement__c> medElement = MockupFactory.createMediaElement(11);
		// When
		Test.startTest();
		list<MediaElementsManagerController.ContentWrapper> searchedList = MediaElementsManagerController.getData('0', '0', '15', 'false');
		Test.stopTest();
		// Then
		System.assertEquals( 2, searchedList.size());
	}
	@isTest 
	static void PA181_CASE_4(){
		// Comment: Search media element with pagging, without filter

		// Given
		List<ContentDocument> contentDocument = MockupFactory.createContentDocument('TestCD', 1);
		List<MediaElement__c> medElement = MockupFactory.createMediaElement(11);
		for(Integer i = 0; i < medElement.size(); i++){
			medElement[i].FileURLDesktop__c = 'https://test/' + contentDocument[0].id;
		}
		medElement[0].FileURLDesktop__c = 'https://test/dsdsd.jpg';
		update medElement;

		// When
		Test.startTest();
		list<MediaElementsManagerController.ContentWrapper> searchedList = MediaElementsManagerController.getData('0', '', '6', 'false');
		list<MediaElementsManagerController.ContentWrapper> searchedList2 = MediaElementsManagerController.getData('6', '', '6', 'true');
		Test.stopTest();
		// Then
		System.assertEquals(6, searchedList.size());
		System.assertEquals(2, searchedList2.size());
	}
	@isTest 
	static void PA181_CASE_5(){
		// Comment: Se relaciona un registro de mediaElement con un Content mediante un Junction Object, en este caso MediaElementAssignment

		// Given
		Cluster__c cluster = [SELECT id FROM Cluster__c LIMIT 1];
		List<Content__c> content = MockupFactory.createContent('Event', cluster, 1);
		List<MediaElement__c> medElement = MockupFactory.createMediaElement(1);
		// When
		Test.startTest();
		MediaElementsManagerController.assignMediaElementToId (content[0].Id, 'icon', 'Content__c','MediaElementAssignment__c', medElement[0].Id);
		Test.stopTest();

		List<MediaElementAssignment__c> junctionObjectRecord = [SELECT id, Placement__c FROM MediaElementAssignment__c WHERE Content__c = :content[0].Id AND MediaElement__c = :medElement[0].Id];
		// Then
		System.assertEquals( 1, junctionObjectRecord.size());
		System.assertEquals( 'icon', junctionObjectRecord[0].Placement__c);
	}
	@isTest 
	static void PA181_CASE_6(){
		// Comment: se elimina un registro de un Junction Object mediante un Id y el api name del objeto

		// Given
		Cluster__c cluster = [SELECT id FROM Cluster__c LIMIT 1];
		List<Content__c> content = MockupFactory.createContent('Event', cluster, 1);
		List<MediaElement__c> medElement = MockupFactory.createMediaElement(1);
		MediaElementAssignment__c junctionObjectRecord = new MediaElementAssignment__c (MediaElement__c = medElement[0].id, Content__c = content[0].id , Placement__c = 'icon');
		insert junctionObjectRecord;
		// When
		Test.startTest();
		MediaElementsManagerController.deleteJunctionObject(junctionObjectRecord.Id, 'MediaElementAssignment__c');
		Test.stopTest();
		// Then
		System.assertEquals( 0, [SELECT id FROM MediaElementAssignment__c].size()); 
	}
}