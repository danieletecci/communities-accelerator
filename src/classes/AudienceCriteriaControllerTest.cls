@isTest(seeAllData = false)
public class AudienceCriteriaControllerTest {
    
    @testSetup
    static void generateCustomSettings(){
        User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];

        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusterRoot = MockupFactory.createCluster('Cluster Root', '', 1, 'ClusterRoot', 'CRT');
        List<Cluster__c> clusterGroup = MockupFactory.createCluster('Cluster Group', clusterRoot.get(0).id, 1, 'ClusterGroup', 'CGT');
        List<Cluster__c> clusterLeaf = MockupFactory.createCluster('Cluster Leaf', clusterGroup.get(0).id, 2, 'ClusterLeaf', 'CLT');

        //Apply Audience for User "All"
        Audience__c audienceTest = new Audience__c(Cluster__c = clusterLeaf[0].Id, Name = 'Test', RecordTypeId = AudienceUtils.rtAudience, MatchCriteria__c = 'All');
        insert audienceTest;
        AudienceCriterion__c audCriterionTest = new AudienceCriterion__c(Audience__c = audienceTest.Id, FieldAPIName__c = 'Name', MainObjectType__c = 'User', Operator__c = 'equals', Order__c = 1, Value__c = u.Name, ValueType__c = 'Text');
        insert audCriterionTest;
        audienceTest.Status__c = 'Active';
        update audienceTest;

        CMS.updateUserSettings(u.Id, clusterLeaf[0].Id, null, null, u.Id);
    }

    @isTest 
    static void checkgetCriteriaAndSave(){
        /* Comment: Checks if the controller retieve the correct data and save the records */

        //Given
        Audience__c audienceTest = [SELECT Id, Cluster__c FROM Audience__c];
        Cluster__c cluster = [SELECT Id, AudienceCustomObjectType__c, AudienceFieldsCustomObject__c FROM Cluster__c WHERE Id =: audienceTest.Cluster__c];
        cluster.AudienceCustomObjectType__c = 'User';
        cluster.AudienceFieldsCustomObject__c = 'Name, UserName, Owner.Name, IsActive, LanguageLocaleKey';
        update cluster;

        //When
        Test.startTest();
        String criteriaWrapperJSON = AudienceCriteriaController.getCriteria(audienceTest.Id);
        AudienceCriteriaController.AudienceWrapper aw = (AudienceCriteriaController.AudienceWrapper)JSON.deserialize(criteriaWrapperJSON, AudienceCriteriaController.AudienceWrapper.class);
        aw.matchCriteria = 'Custom';
        aw.audienceCriteria = '1 OR 2';
        aw.criteria.add(new AudienceCriteriaController.CriterionWrapper(2, 'User.IsActive', 'equals', 'Checkbox', 'TRUE'));
        AudienceCriteriaController.saveCriteria(aw.audienceId, aw.matchCriteria, aw.audienceCriteria, JSON.serialize(aw.criteria));
        Test.stopTest();

        //Then
        System.assertEquals(2, [SELECT Id FROM AudienceCriterion__c WHERE Audience__c =: audienceTest.Id].size());
        Audience__c audienceTestPost = [SELECT Id, MatchCriteria__c, AudienceCriteria__c FROM Audience__c WHERE Id =: audienceTest.Id];
        System.assertEquals('Custom', audienceTestPost.MatchCriteria__c);
        System.assertEquals('1 OR 2', audienceTestPost.AudienceCriteria__c);
    }

}