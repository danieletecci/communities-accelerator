public class ObjectNavigationWrapper {
    
    @AuraEnabled public String Id;
    @AuraEnabled public String Name;
    @AuraEnabled public String RecordTypeId;
    @AuraEnabled public String RecordTypeName;
    @AuraEnabled public String RecordTypeDeveloperName;

    @AuraEnabled public String Audience;
	@AuraEnabled public String Behaviour;
	@AuraEnabled public String Cluster;
	@AuraEnabled public Boolean DefaultPage;
	@AuraEnabled public String Description;
	@AuraEnabled public String ExternalId;
	@AuraEnabled public String ParentNavigation;
	@AuraEnabled public String Status;
	@AuraEnabled public String Type;
	@AuraEnabled public String URL;
	@AuraEnabled public String URLMask;
    
    public ObjectNavigationWrapper(Navigation__c navigation){
        try{this.Id = navigation.Id;}catch(Exception e){}
        try{this.Name = navigation.Name;}catch(Exception e){}
        try{this.RecordTypeId = navigation.RecordTypeId;}catch(Exception e){}
        try{this.RecordTypeName = navigation.RecordType.Name;}catch(Exception e){}
        try{this.RecordTypeDeveloperName = navigation.RecordType.DeveloperName;}catch(Exception e){}
        
        try{this.Audience = navigation.Audience__c;}catch(Exception e){}
		try{this.Behaviour = navigation.Behaviour__c;}catch(Exception e){}
		try{this.Cluster = navigation.Cluster__c;}catch(Exception e){}
		try{this.DefaultPage = navigation.DefaultPage__c;}catch(Exception e){}
		try{this.Description = navigation.Description__c;}catch(Exception e){}
		try{this.ExternalId = navigation.ExternalId__c;}catch(Exception e){}
		try{this.ParentNavigation = navigation.ParentNavigation__c;}catch(Exception e){}
		try{this.Status = navigation.Status__c;}catch(Exception e){}
		try{this.Type = navigation.Type__c;}catch(Exception e){}
		try{this.URL = navigation.URL__c;}catch(Exception e){}
		try{this.URLMask = navigation.URLMask__c;}catch(Exception e){}
    }

}