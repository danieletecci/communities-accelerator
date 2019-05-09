@isTest(seeAllData = false)
public with sharing class SecurityUtilsTest {
	private static final String USERNAME = 'TestUserSecurityUtils@test.com';
	private static final String TEST_OBJECT = 'Account';
	private static final String TEST_FIELD = 'Name';

    @testSetup
    static void generateCustomSettings(){
        MockupFactory.generateAcceleratorSetting();
        MockupFactory.createUser(USERNAME, USERNAME);
    }

    @isTest 
    static void permissionsTest(){
        //Given
        User testUser = [SELECT Id FROM User WHERE Username =: USERNAME LIMIT 1][0];
        Boolean hasCustomPermission;
		Boolean isObjectAccessible;
		Boolean isObjectCreateable;
		Boolean isObjectUpdateable;
		Boolean isFieldAccessible;
		Boolean isFieldCreateable;
		Boolean isFieldUpdateable;
		Boolean isRecordTypeAvailable;

        //When
        Test.startTest();
	        System.runAs(testUser){
	        	hasCustomPermission = SecurityUtils.hasCustomPermission(GeneralUtils.prefix('[CMS]ContentCreateTemplate'));
		        isObjectAccessible = SecurityUtils.isObjectAccessible(TEST_OBJECT);
		        isObjectCreateable = SecurityUtils.isObjectCreateable(TEST_OBJECT);
		        isObjectUpdateable = SecurityUtils.isObjectUpdateable(TEST_OBJECT);
		        isFieldAccessible = SecurityUtils.isFieldAccessible(TEST_OBJECT, TEST_FIELD);
		        isFieldCreateable = SecurityUtils.isFieldCreateable(TEST_OBJECT, TEST_FIELD);
		        isFieldUpdateable = SecurityUtils.isFieldUpdateable(TEST_OBJECT, TEST_FIELD);
		        isRecordTypeAvailable = SecurityUtils.isRecordTypeAvailable(GeneralUtils.prefix('[CMS]Content__c'), 'Banner');
			}
        Test.stopTest();

        //Then
        System.AssertNotEquals(isObjectAccessible, null);
        System.AssertNotEquals(isObjectCreateable, null);
        System.AssertNotEquals(isObjectUpdateable, null);
        System.AssertNotEquals(isFieldAccessible, null);
        System.AssertNotEquals(isFieldCreateable, null);
        System.AssertNotEquals(isFieldUpdateable, null);
        System.AssertNotEquals(isRecordTypeAvailable, null);
    }
}