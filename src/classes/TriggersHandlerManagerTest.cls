@isTest
public class TriggersHandlerManagerTest {
    
    @testSetup
    static void setup(){
        MockupFactory.generateAcceleratorSetting();

        User u = MockupFactory.createUser('test__user@test.com', 'test__user@test.com');
        u.TriggersDebugs__c = 'triggerCanDebug';
        u.TriggersDebugs__c = 'triggerCanDebugButBypassed';
        u.TriggersByPass__c = 'triggerBypassedInUser';
        update u;

        List<Cluster__c> clusters = MockupFactory.createCluster('TestCluster', null, 10, 'ClusterRoot', 'CRT');
        Id clusterId = clusters[0].Id;
        MockupFactory.createCluster('ClusterLevel2', clusterId, 10, 'ClusterGroup', 'CGT');

    }

    @isTest
    static void bypassTriggerTest(){
        //Comment: Add Trigger to bypass

        //When
        TriggersHandlerManager.byPassTrigger('testTrigger');

        //Then
        system.assert(TriggersHandlerManager.isByPassTrigger('testTrigger'));

        //Remove the trigger from bypass
        //When
        TriggersHandlerManager.removeByPassTrigger('testTrigger');
        //Then
        system.assert(!TriggersHandlerManager.isByPassTrigger('testTrigger'));
    }

    @isTest
    static void canAutoDebugTest(){
        //Comment: 

        //Given
        User u = [SELECT Id, TriggersDebugs__c FROM User WHERE username = 'test__user@test.com'];

        //When
        Boolean canDebug;
        system.runAs(u){
            canDebug = TriggersHandlerManager.canAutoDebug('triggerCanDebug');
        }

        //Then
        system.assert(canDebug);
    }

    @isTest
    static void cannotAutoDebugTest(){
        //Comment: 

        //Given
        User u = [SELECT Id, TriggersDebugs__c FROM User WHERE username = 'test__user@test.com'];
        TriggersHandlerManager.byPassTrigger('triggerCanDebugButBypassed');

        //When
        Boolean canDebug;
        system.runAs(u){
            canDebug = TriggersHandlerManager.canAutoDebug('triggerCanDebugButBypassed');
        }

        //Then
        system.assert(!canDebug);
    }

    @isTest
    static void canTriggerTest(){
        //Comment: 

        //Given
        User u = [SELECT Id, TriggersDebugs__c FROM User WHERE username = 'test__user@test.com'];
        TriggersHandlerManager.byPassTrigger('triggerBypassed');

        //When
        Boolean canRun1;
        Boolean canRun2;
        Boolean canRun3;
        system.runAs(u){
            canRun1 = TriggersHandlerManager.canTrigger('triggerBypassed');
            canRun2 = TriggersHandlerManager.canTrigger('triggerBypassedInUser');
            canRun3 = TriggersHandlerManager.canTrigger('triggerCanRun');   
        }

        //Then
        system.assert(!canRun1);
        system.assert(!canRun2);
        system.assert(canRun3);
    }

    @isTest
    static void getTriggerListFilteredTest(){
        //Comment: 
        
        //Given
        TriggersHandlerManager.triggerOld = Database.query('SELECT Id, ParentCluster__c, name FROM Cluster__c WHERE name LIKE \'%Cluster%\'');

        TriggersHandlerManager.triggerNew = Database.query('SELECT Id, ParentCluster__c, name FROM Cluster__c WHERE name LIKE \'%Cluster%\'');

        //When
        TriggersHandlerManager.TriggerFiltered filteredResultName = TriggersHandlerManager.getTriggerListFiltered('name');
        TriggersHandlerManager.TriggerFiltered filteredResultParentCluster = TriggersHandlerManager.getTriggerListFiltered('ParentCluster__c');
        TriggersHandlerManager.TriggerFiltered filteredResultNull = TriggersHandlerManager.getTriggerListFiltered(null);

        //Then
        system.assertEquals(20,filteredResultName.triggerNewFiltered.keySet().size());
        system.assertEquals(20,filteredResultName.triggerOldFiltered.keySet().size());
        system.assertEquals(2,filteredResultParentCluster.triggerNewFiltered.keySet().size());
        system.assertEquals(2,filteredResultParentCluster.triggerOldFiltered.keySet().size());
        system.assert(filteredResultNull.triggerNewFiltered.keySet().isEmpty());
        system.assert(filteredResultNull.triggerOldFiltered.keySet().isEmpty());
    }

}