public with sharing class ContentLandingHeaderController {
	@AuraEnabled(cacheable=true)
    public static Boolean hasCreateTemplateButton(){
    	return SecurityUtils.hasCustomPermission(GeneralUtils.prefix('[CMS]ContentCreateTemplate'));
    }

    @AuraEnabled(cacheable=true)
    public static Boolean hasCreateContentButton(){
    	return SecurityUtils.isObjectCreateable(GeneralUtils.prefix('[CMS]Content__c'));
    }

	@AuraEnabled(cacheable=true)
    public static String getObjectLabel(String sObjectType){
    	return Schema.getGlobalDescribe().get(GeneralUtils.prefix(sObjectType)).getDescribe().getLabel();
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getPicklistValues(String sObjectType, String fieldApiName){
    	List<Map<String,String>>	picklistValues 	= new List<Map<String,String>>();
		List<Schema.PicklistEntry> 	pleList 		= Schema.getGlobalDescribe().get(GeneralUtils.prefix(sObjectType)).getDescribe().fields.getMap().get(GeneralUtils.prefix(fieldApiName)).getDescribe().getPicklistValues();

		for( Schema.PicklistEntry pickListVal : pleList){
			if(pickListVal.isActive()){
				Map<String,String> pv = new Map<String,String>();
				pv.put('defaultValue', 	pickListVal.isDefaultValue()+'');
				pv.put('label', 		pickListVal.getLabel());
				pv.put('value', 		pickListVal.getValue());
				picklistValues.add(pv);
			}
		}

		return picklistValues;
    }
}