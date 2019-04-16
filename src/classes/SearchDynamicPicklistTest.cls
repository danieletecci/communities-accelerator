@isTest
public class SearchDynamicPicklistTest {

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