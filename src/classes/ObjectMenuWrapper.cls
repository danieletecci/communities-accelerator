public class ObjectMenuWrapper {
    
    public String Id;
    public String Name;
    public String RecordTypeId;
    public String RecordTypeName;
    public String RecordTypeDeveloperName;

    public String Behaviour;
    public String Cluster;
    public String ClusterRootExternalId;
    public String ComponentName;
    public String ExternalId;
    public String MenuIcon;
    public String MenuLabel;
    public String Navigation;
    public String ParentMenu;
    public String Status;
    public String URLParameters;
    
    public String NavigationURL;
    
    public ObjectMenuWrapper(Menu__c menu){
        try{this.Id = menu.Id;}catch(Exception e){}
        try{this.Name = menu.Name;}catch(Exception e){}
        try{this.RecordTypeId = menu.RecordTypeId;}catch(Exception e){}
        try{this.RecordTypeName = menu.RecordType.Name;}catch(Exception e){}
        try{this.RecordTypeDeveloperName = menu.RecordType.DeveloperName;}catch(Exception e){}
        
        try{this.Behaviour = menu.Behaviour__c;}catch(Exception e){}
        try{this.Cluster = menu.Cluster__c;}catch(Exception e){}
        try{this.ClusterRootExternalId = menu.ClusterRootExternalId__c;}catch(Exception e){}
        try{this.ComponentName = menu.ComponentName__c;}catch(Exception e){}
        try{this.ExternalId = menu.ExternalId__c;}catch(Exception e){}
        try{this.MenuIcon  = menu.MenuIcon__c;}catch(Exception e){}
        try{this.MenuLabel = menu.MenuLabel__c;}catch(Exception e){}
        try{this.Navigation = menu.Navigation__c;}catch(Exception e){}
        try{this.ParentMenu = menu.ParentMenu__c;}catch(Exception e){}
        try{this.Status = menu.Status__c;}catch(Exception e){}
        try{this.URLParameters = menu.URLParameters__c;}catch(Exception e){}
        try{this.NavigationURL = menu.Navigation__r.URL__c;}catch(Exception e){}
    }

}