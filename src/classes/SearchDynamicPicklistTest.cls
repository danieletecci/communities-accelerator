@isTest
<<<<<<< HEAD:src/classes/SearchDynamicPicklistTest.cls
public class SearchDinamicPicklistTest {
=======
public class SearchDynamicPicklistTest {
>>>>>>> 19d0c2ed229dfc66e981d43784632e605eabf6b7:src/classes/SearchDynamicPicklistTest.cls
	@isTest
    static void getValues(){
        SearchDynamicPicklist scp = new SearchDynamicPicklist();
        scp.getDefaultValue();
        scp.getValues();
        
        MockupFactory.createComponent('Search',1);
        
        SearchDynamicPicklist scp2 = new SearchDynamicPicklist();
        scp2.getDefaultValue();
        scp2.getValues();
    }
}