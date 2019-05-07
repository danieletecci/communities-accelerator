public class ObjectMenuWrapper {
    
    @AuraEnabled public String Id;
    @AuraEnabled public String Name;
    @AuraEnabled public String RecordTypeId;
    @AuraEnabled public String RecordTypeName;
    @AuraEnabled public String RecordTypeDeveloperName;

    @AuraEnabled public String Behaviour;
    @AuraEnabled public String Cluster;
    @AuraEnabled public String ClusterRootExternalId;
    @AuraEnabled public String ComponentName;
    @AuraEnabled public String ExternalId;
    @AuraEnabled public String MenuIcon;
    @AuraEnabled public String MenuLabel;
    @AuraEnabled public String MenuDynamicLabel;
    @AuraEnabled public String Navigation;
    @AuraEnabled public String ParentMenu;
    @AuraEnabled public String StyleClass;
    @AuraEnabled public String Status;
    @AuraEnabled public String URLParameters;
    @AuraEnabled public String URLMask;
    
    @AuraEnabled public String NavigationURL;
    
    public ObjectMenuWrapper(Menu__c menu){
        try{this.Id = menu.Id;}catch(Exception e){}
        try{this.Name = menu.Name;}catch(Exception e){}
        try{this.RecordTypeId = menu.RecordTypeId;}catch(Exception e){}
        try{this.RecordTypeName = menu.RecordType.Name;}catch(Exception e){}
        try{this.RecordTypeDeveloperName = menu.RecordType.DeveloperName;}catch(Exception e){}
        
        try{this.Behaviour = menu.Navigation__r.Behaviour__c;}catch(Exception e){}
        try{this.Cluster = menu.Cluster__c;}catch(Exception e){}
        try{this.ClusterRootExternalId = menu.ClusterRootExternalId__c;}catch(Exception e){}
        try{this.ComponentName = menu.ComponentName__c;}catch(Exception e){}
        try{this.ExternalId = menu.ExternalId__c;}catch(Exception e){}
        try{this.MenuIcon  = menu.MenuIcon__c;}catch(Exception e){}
        try{this.MenuLabel = menu.MenuLabel__c;}catch(Exception e){}
        try{this.MenuDynamicLabel = menu.MenuDynamicLabel__c;}catch(Exception e){}
        try{this.Navigation = menu.Navigation__c;}catch(Exception e){}
        try{this.ParentMenu = menu.ParentMenu__c;}catch(Exception e){}
        try{this.Status = menu.Status__c;}catch(Exception e){}
        try{this.URLParameters = menu.URLParameters__c;}catch(Exception e){}
        try{this.NavigationURL = menu.Navigation__r.URL__c;}catch(Exception e){}
        try{this.URLMask = menu.Navigation__r.URLMask__c;}catch(Exception e){}
        try{this.StyleClass = menu.StyleClass__c;}catch(Exception e){}
        
    }

}