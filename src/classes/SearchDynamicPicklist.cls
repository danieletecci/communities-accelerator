global class SearchDynamicPicklist extends VisualEditor.DynamicPickList{
	List<Component__c> 	compList = [SELECT Id,Name,ExternalId__c FROM Component__c WHERE RecordType.DeveloperName = 'Search'];
    
    global override VisualEditor.DataRow getDefaultValue(){
    	VisualEditor.DataRow defaultValue;
    	if(compList.isEmpty())
        	defaultValue = null;
        else
        	defaultValue = new VisualEditor.DataRow(compList.get(0).Name, compList.get(0).ExternalId__c);
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  	myValues = new VisualEditor.DynamicPickListRows();
    	
        
    	for(Component__c c : compList){
        	myValues.addRow(new VisualEditor.DataRow(c.Name, c.ExternalId__c));
    	}

        return myValues;
    }
}