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
    public String HeightDesktop;
    public String HeightMobile;
    public String HeightTablet;
    public String MobileFileExtension;
    public String Status;
    public String TabletFileExtension;
    public String WidthDesktop;
    public String WidthMobile;
    public String WidthTablet;
    
    public ObjectMediaElementWrapper(MediaElement__c mediaElement){
        this.Id = content.Id;
        this.Name = content.Name;
        this.Description = mediaElement.Description__c;
        this.DesktopFileExtension = mediaElement.DesktopFileExtension__c;
        this.ExternalId = mediaElement.ExternalId__c;
        this.FileNameDesktop = mediaElement.FileNameDesktop__c;
        this.FileNameMobile = mediaElement.FileNameMobile__c;
        this.FileNameTablet = mediaElement.FileNameTablet__c;
        this.FileURLDesktop = mediaElement.FileURLDesktop__c;
        this.FileURLMobile = mediaElement.FileURLMobile__c;
        this.FileURLTablet = mediaElement.FileURLTablet__c;
        this.HeightDesktop = mediaElement.HeightDesktop__c;
        this.HeightMobile = mediaElement.HeightMobile__c;
        this.HeightTablet = mediaElement.HeightTablet__c;
        this.MobileFileExtension = mediaElement.MobileFileExtension__c;
        this.Status = mediaElement.Status__c;
        this.TabletFileExtension = mediaElement.TabletFileExtension__c;
        this.WidthDesktop = mediaElement.WidthDesktop__c;
        this.WidthMobile = mediaElement.WidthMobile__c;
        this.WidthTablet = mediaElement.WidthTablet__c;
    }

}