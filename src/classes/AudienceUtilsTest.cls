@isTest(seeAllData = false)
public class AudienceUtilsTest {
    
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

        CMS.updateUserSettings(u.Id, clusterLeaf[0].Id, null, null, null, u.Id);
    }

    @isTest 
    static void filterRecords(){
        /* Comment: Checks if the method filterRecords filter the records received based on the Audiences of a User */

        //Given
        Audience__c audienceTest = [SELECT Id, Cluster__c, ExternalId__c FROM Audience__c WHERE Name = 'Test' AND RecordTypeId =: AudienceUtils.rtAudience];
        Audience__c audienceTest2 = [SELECT Id, Cluster__c, ExternalId__c FROM Audience__c WHERE Name = 'Test2' AND RecordTypeId =: AudienceUtils.rtAudience];
        List<Content__c> contentList = [SELECT Id, HTMLContent__c FROM Content__c];
        contentList[0].Audience__c = AudienceUtils.audienceGroupCreation(new List<String>{audienceTest.ExternalId__c}, audienceTest.Cluster__c);
        contentList[1].Audience__c = AudienceUtils.audienceGroupCreation(new List<String>{audienceTest2.ExternalId__c}, audienceTest2.Cluster__c);
        update contentList;
        List<Content__c> contentListToFilter = [SELECT Id, Name, Audience__r.ReferenceAudienceExternalIds__c FROM Content__c];

        //When
        Test.startTest();
        AudienceUtils.filterRecords(UserInfo.getUserId(), contentListToFilter, 'Audience__c');
        Test.stopTest();

        //Then
        System.assertEquals(1, contentListToFilter.size());
        System.assertEquals('Banner 0', contentListToFilter[0].Name);
    }

    @isTest 
    static void audienceGroupCreation(){
        /* Comment: Checks if the method audienceGroupCreation returns o creates and return an Audience Group based on a combination of Audiences */

        //Given
        Audience__c audienceTest = [SELECT Id, Cluster__c, ExternalId__c FROM Audience__c WHERE Name = 'Test' AND RecordTypeId =: AudienceUtils.rtAudience];
        Audience__c audienceTest2 = [SELECT Id, Cluster__c, ExternalId__c FROM Audience__c WHERE Name = 'Test2' AND RecordTypeId =: AudienceUtils.rtAudience];

        //When
        Test.startTest();
        //Creation of groups
        AudienceUtils.audienceGroupCreation(new List<String>{audienceTest.ExternalId__c}, audienceTest.Cluster__c);
        AudienceUtils.audienceGroupCreation(new List<String>{audienceTest2.ExternalId__c}, audienceTest2.Cluster__c);
        AudienceUtils.audienceGroupCreation(new List<String>{audienceTest.ExternalId__c, audienceTest2.ExternalId__c}, audienceTest2.Cluster__c);
        
        //Return the same audiences created previously
        AudienceUtils.audienceGroupCreation(new List<String>{audienceTest.ExternalId__c}, audienceTest.Cluster__c);
        AudienceUtils.audienceGroupCreation(new List<String>{audienceTest2.ExternalId__c}, audienceTest2.Cluster__c);
        AudienceUtils.audienceGroupCreation(new List<String>{audienceTest2.ExternalId__c, audienceTest.ExternalId__c}, audienceTest2.Cluster__c);
        Test.stopTest();

        //Then
        System.assertEquals(3, [SELECT Id FROM Audience__c WHERE RecordTypeId =: AudienceUtils.rtAudienceGroup].size());
    }

    @isTest 
    static void audienceUserCalculation(){
        /* Comment: Checks if the method audienceUserCalculation calculates the Audiences that apply for a User based on the Audiences Criteria */

        //Given
        User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
        Id clusterId = CMS.getUserSettings(UserInfo.getUserId()).Cluster__c;
        Audience__c audienceTest = [SELECT Id, Cluster__c, ExternalId__c FROM Audience__c WHERE Name = 'Test' AND RecordTypeId =: AudienceUtils.rtAudience];
        Audience__c audienceTest2 = [SELECT Id, Cluster__c, ExternalId__c FROM Audience__c WHERE Name = 'Test2' AND RecordTypeId =: AudienceUtils.rtAudience];
        Audience__c audienceTest3 = [SELECT Id, Cluster__c, ExternalId__c FROM Audience__c WHERE Name = 'Test3' AND RecordTypeId =: AudienceUtils.rtAudience];

        //When
        Test.startTest();
        CMS.updateUserSettings(u.Id, clusterId, null, null, null, u.Id);
        Test.stopTest();

        //Then
        System.assert(CMS.getUserAudiences(UserInfo.getUserId()).contains(audienceTest.ExternalId__c));
        System.assert(!CMS.getUserAudiences(UserInfo.getUserId()).contains(audienceTest2.ExternalId__c));
        System.assert(CMS.getUserAudiences(UserInfo.getUserId()).contains(audienceTest3.ExternalId__c));
    }

}