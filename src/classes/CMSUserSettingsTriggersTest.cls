@isTest(seeAllData = false)
public class CMSUserSettingsTriggersTest {
    
    @testSetup
    static void generateCustomSettings(){
        User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];

        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusterRoot = MockupFactory.createCluster('Cluster Root', '', 1, 'ClusterRoot', 'CRT');
        List<Cluster__c> clusterGroup = MockupFactory.createCluster('Cluster Group', clusterRoot.get(0).id, 1, 'ClusterGroup', 'CGT');
        List<Cluster__c> clusterLeaf = MockupFactory.createCluster('Cluster Leaf', clusterGroup.get(0).id, 2, 'ClusterLeaf', 'CLT');
        List<Component__c> componentList = MockupFactory.createComponent('Banner', 1, clusterRoot[0]);
        List<Content__c> contentList = MockupFactory.createContent('Banner', clusterLeaf[0], 2);
        MockupFactory.createContentAssignment(contentList, componentList);

        //Apply Audience for User "All" 
        Audience__c audienceTest = new Audience__c(Cluster__c = clusterLeaf[0].Id, Name = 'Test', RecordTypeId = AudienceUtils.rtAudience, MatchCriteria__c = 'All');
        insert audienceTest;
        AudienceCriterion__c audCriterionTest = new AudienceCriterion__c(Audience__c = audienceTest.Id, FieldAPIName__c = 'Name', MainObjectType__c = 'User', Operator__c = 'equals', Order__c = 1, Value__c = u.Name, ValueType__c = 'Text');
        insert audCriterionTest;
        audienceTest.Status__c = 'Active';
        update audienceTest;

        //Not apply Audience for User "Any"
        Audience__c audienceTest2 = new Audience__c(Cluster__c = clusterLeaf[0].Id, Name = 'Test2', RecordTypeId = AudienceUtils.rtAudience, MatchCriteria__c = 'Any');
        insert audienceTest2;
        AudienceCriterion__c audCriterionTest2 = new AudienceCriterion__c(Audience__c = audienceTest2.Id, FieldAPIName__c = 'Name', MainObjectType__c = 'User', Operator__c = 'contains', Order__c = 1, Value__c = u.Name + ' some text', ValueType__c = 'Text');
        insert audCriterionTest2;
		AudienceCriterion__c audCriterionTest2_1 = new AudienceCriterion__c(Audience__c = audienceTest2.Id, FieldAPIName__c = 'Name', MainObjectType__c = 'User', Operator__c = 'not equals', Order__c = 2, Value__c = u.Name, ValueType__c = 'Text');
        insert audCriterionTest2_1;
		AudienceCriterion__c audCriterionTest2_2 = new AudienceCriterion__c(Audience__c = audienceTest2.Id, FieldAPIName__c = 'Name', MainObjectType__c = 'User', Operator__c = 'not contains', Order__c = 3, Value__c = u.Name, ValueType__c = 'Text');
        insert audCriterionTest2_2;
		AudienceCriterion__c audCriterionTest2_3 = new AudienceCriterion__c(Audience__c = audienceTest2.Id, FieldAPIName__c = 'IsActive', MainObjectType__c = 'User', Operator__c = 'not equals', Order__c = 4, Value__c = 'TRUE', ValueType__c = 'Checkbox');
        insert audCriterionTest2_3;
        audienceTest2.Status__c = 'Active';
        update audienceTest2;

        //Apply Audience for User "Custom"
        Audience__c audienceTest3 = new Audience__c(Cluster__c = clusterLeaf[0].Id, Name = 'Test3', RecordTypeId = AudienceUtils.rtAudience, MatchCriteria__c = 'Custom', AudienceCriteria__c = '1');
        insert audienceTest3;
        AudienceCriterion__c audCriterionTest3 = new AudienceCriterion__c(Audience__c = audienceTest3.Id, FieldAPIName__c = 'IsActive', MainObjectType__c = 'User', Operator__c = 'equals', Order__c = 1, Value__c = 'TRUE', ValueType__c = 'Checkbox');
        insert audCriterionTest3;
        audienceTest3.Status__c = 'Active';
        update audienceTest3;
    }

    @isTest 
    static void filterRecords(){
        /* Comment: Checks if the trigger of CMS User Settings calculate the Audiences */

        //Given
        Audience__c audienceTest = [SELECT Id, Cluster__c, ExternalId__c FROM Audience__c WHERE Name = 'Test' AND RecordTypeId =: AudienceUtils.rtAudience];
        Audience__c audienceTest3 = [SELECT Id, Cluster__c, ExternalId__c FROM Audience__c WHERE Name = 'Test3' AND RecordTypeId =: AudienceUtils.rtAudience];

        //When
        Test.startTest();
        CMSUserSettings__c cus = new CMSUserSettings__c(
            User__c = UserInfo.getUserId(),
            Cluster__c = audienceTest.Cluster__c,
            CustomRecordId__c = UserInfo.getUserId()
        );
        insert cus;
        Test.stopTest();

        //Then
        System.assertEquals(audienceTest.ExternalId__c + ';' + audienceTest3.ExternalId__c, [SELECT Id, Audiences__c FROM CMSUserSettings__c WHERE Id =: cus.Id].Audiences__c);
    }

    @isTest
    static void duplicatedUsers(){
        /* Comment: Checks if the trigger of CMS User Settings validates duplicated Users */

        //Given
        User user1 = MockupFactory.createUser('Tyrion778899@Lannister.com', 'Tyrion778899@Lannister.com');
        User user2 = MockupFactory.createUser('Varys112239@Eunuch.com', 'Varys112239@Eunuch.com');
        String insertErrorMessage, updateErrorMessage;

	    CMSUserSettings__c userSetting1 = new CMSUserSettings__c(User__c = user1.Id);
	    insert userSetting1;

        //When
        Test.startTest();
            // Insert
            try{
                CMSUserSettings__c userSetting2 = new CMSUserSettings__c(User__c = user1.Id);
                insert userSetting2;
            }
            catch (Exception e){
                insertErrorMessage = e.getMessage();
            }
            // Update
            try{
                CMSUserSettings__c userSetting2 = new CMSUserSettings__c(User__c = user2.Id);
                insert userSetting2;
                userSetting2.User__c = user1.Id;
                update userSetting2;
            }
            catch (Exception e) {
                updateErrorMessage = e.getMessage();
            }
        Test.stopTest();

        //Then
		System.Assert(insertErrorMessage.contains(Label.DuplicatedUserValidation));
        System.Assert(updateErrorMessage.contains(Label.DuplicatedUserValidation));
    }

}