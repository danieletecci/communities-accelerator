@isTest
public with sharing class CountrySelectorControllerTest {

	@isTest
    static void getCountriesCodesTest(){

		//Given
		
		//When
		Test.startTest();
		CountrySelectorController.CountriesWrapper test2 = CountrySelectorController.getCountriesCodes('ec');
		Test.stopTest();

		//Then
		System.assertNotEquals(test2.countriesList, null);
		System.assert(test2.countriesList.size()>0);
	
	}


	@isTest
    static void getCountriesCodesTestIsoCode(){

		//Given
		
		//When
		Test.startTest();
		CountrySelectorController.CountriesWrapper test2 = CountrySelectorController.getCountriesCodes('');
		Test.stopTest();

		//Then
		System.assert(test2.selected.iso.equalsIgnoreCase(UserInfo.getLocale().right(2)));
	
	}

}