public with sharing class LanguageSelectorController {

	//WRAPPER
	public class LanguageWrapper {
		@auraEnabled public String name;
		@auraEnabled public String value;

		public LanguageWrapper(String nam, String val){
			this.name = nam;
			this.value = val;
		}	
	}
	public class MenuWrapper {
		@auraEnabled public Boolean isGuestUser;
        @auraEnabled public LanguageWrapper userLanguage;
        @auraEnabled public List<LanguageWrapper> languages;

        public MenuWrapper(){
			this.languages = new List<LanguageWrapper>();
		}
	}

	@AuraEnabled
    public static MenuWrapper getLanguageMenu(String clusterId){
    	System.debug('getLanguageMenu clusterId: ' + clusterId);
    	Cluster__c cluster = [SELECT Id, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c where Id =: clusterId];

    	Set<String>langs = new Set<String>();
    	langs.add(cluster.DefaultLanguage__c);

    	String[] tmpString = cluster.OtherLanguages__c.split(';');
    	langs.addAll(tmpString);

    	String userLanguage = UserInfo.getLanguage();

    	MenuWrapper wrapper = new MenuWrapper();

		Schema.DescribeSObjectResult sobjectDescribe = Schema.getGlobalDescribe().get('Translation__c').getDescribe();
		for (Schema.PicklistEntry entry : sobjectDescribe.fields.getMap().get('LanguageCode__c').getDescribe().getPickListValues()){
			if(langs.contains(entry.getValue()) && entry.isActive()){	
				LanguageWrapper lang= new LanguageWrapper(entry.getLabel(), entry.getValue());
				wrapper.languages.add(lang);
				if(entry.getValue().equalsIgnoreCase(userLanguage)){
					wrapper.userLanguage=lang;
				}	
				
			}
			
		}
		
		Profile profile =  [SELECT id, Name FROM Profile WHERE id = : UserInfo.getProfileId()];

		wrapper.isGuestUser = (profile.Name == 'Guest');

		return wrapper;
    }

	@AuraEnabled
	public static void setLanguage(String language){
		
		User u = [SELECT id ,LanguageLocaleKey FROM User WHERE id =: UserInfo.getUserId()];

		u.LanguageLocaleKey = language;

		update u;
	}
}