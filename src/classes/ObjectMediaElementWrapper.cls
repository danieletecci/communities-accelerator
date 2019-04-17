public class ObjectMediaElementWrapper {
    
    public String Id;
    public String Name;

    public String Description;
    public String DesktopFileExtension;
    public String ExternalId;
    public String FileNameDesktop;
    public String FileNameMobile;
    public String FileNameTablet;
    public String FileURLDesktop;
    public String FileURLMobile;
    public String FileURLTablet;
    public Decimal HeightDesktop;
    public Decimal HeightMobile;
    public Decimal HeightTablet;
    public String MobileFileExtension;
    public String Status;
    public String TabletFileExtension;
    public Decimal WidthDesktop;
    public Decimal WidthMobile;
    public Decimal WidthTablet;
    
    public ObjectMediaElementWrapper(MediaElement__c mediaElement){
        try{this.Id = mediaElement.Id;}catch(Exception e){}
        try{this.Name = mediaElement.Name;}catch(Exception e){}
        
        try{this.Description = mediaElement.Description__c;}catch(Exception e){}
        try{this.DesktopFileExtension = mediaElement.DesktopFileExtension__c;}catch(Exception e){}
        try{this.ExternalId = mediaElement.ExternalId__c;}catch(Exception e){}
        try{this.FileNameDesktop = mediaElement.FileNameDesktop__c;}catch(Exception e){}
        try{this.FileNameMobile = mediaElement.FileNameMobile__c;}catch(Exception e){}
        try{this.FileNameTablet = mediaElement.FileNameTablet__c;}catch(Exception e){}
        try{this.FileURLDesktop = mediaElement.FileURLDesktop__c;}catch(Exception e){}
        try{this.FileURLMobile = mediaElement.FileURLMobile__c;}catch(Exception e){}
        try{this.FileURLTablet = mediaElement.FileURLTablet__c;}catch(Exception e){}
        try{this.HeightDesktop = mediaElement.HeightDesktop__c;}catch(Exception e){}
        try{this.HeightMobile = mediaElement.HeightMobile__c;}catch(Exception e){}
        try{this.HeightTablet = mediaElement.HeightTablet__c;}catch(Exception e){}
        try{this.MobileFileExtension = mediaElement.MobileFileExtension__c;}catch(Exception e){}
        try{this.Status = mediaElement.Status__c;}catch(Exception e){}
        try{this.TabletFileExtension = mediaElement.TabletFileExtension__c;}catch(Exception e){}
        try{this.WidthDesktop = mediaElement.WidthDesktop__c;}catch(Exception e){}
        try{this.WidthMobile = mediaElement.WidthMobile__c;}catch(Exception e){}
        try{this.WidthTablet = mediaElement.WidthTablet__c;}catch(Exception e){}
    }

}