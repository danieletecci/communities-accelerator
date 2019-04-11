@isTest
public with sharing class CMSExceptionTest {
	private static testmethod void unitTest(){
		Test.startTest();
		try {
            throw new CMSException('testing');
        }catch (Exception e) {
            system.debug('exe');
        }
		Test.stopTest();
	}
} 