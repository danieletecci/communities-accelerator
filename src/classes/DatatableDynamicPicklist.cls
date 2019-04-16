global with sharing class DatatableDynamicPicklist extends VisualEditor.DynamicPickList{
	// Default value -- The one that appears at the top
	global override VisualEditor.DataRow getDefaultValue(){
		VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('--None--','');
		return defaultValue;
	}

	// getValues -- define values inside picklist / ('[Title]','[Value]')
	global override VisualEditor.DynamicPickListRows getValues(){
		VisualEditor.DynamicPicklistRows picklistValues = new VisualEditor.DynamicPicklistRows();
		VisualEditor.DataRow nullValue = new VisualEditor.DataRow('--None--','');
		picklistValues.addRow(nullValue); 

		List<Datatable__c> idsToDisplay = [SELECT Name, ExternalId__c FROM Datatable__c];
		for(Datatable__c cIds : idsToDisplay){
			picklistValues.addRow(new VisualEditor.DataRow(cIds.Name,cIds.ExternalId__c));
		}
		return picklistValues;
	}
}
// Note: The 2 methods present are REQUIRED