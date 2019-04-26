public class ObjectMediaElementWrapper {
    
    @AuraEnabled public String Id;
    @AuraEnabled public String Name;

    @AuraEnabled public String Description;
    @AuraEnabled public String DesktopFileExtension;
    @AuraEnabled public String ExternalId;
    @AuraEnabled public String FileNameDesktop;
    @AuraEnabled public String FileNameMobile;
    @AuraEnabled public String FileNameTablet;
    @AuraEnabled public String FileURLDesktop;
    @AuraEnabled public String FileURLMobile;
    @AuraEnabled public String FileURLTablet;
    @AuraEnabled public String FileIdDesktop;
    @AuraEnabled public String FileIdMobile;
    @AuraEnabled public String FileIdTablet;
    @AuraEnabled public Decimal HeightDesktop;
    @AuraEnabled public Decimal HeightMobile;
    @AuraEnabled public Decimal HeightTablet;
    @AuraEnabled public String MobileFileExtension;
    @AuraEnabled public String Status;
    @AuraEnabled public String TabletFileExtension;
    @AuraEnabled public Decimal WidthDesktop;
    @AuraEnabled public Decimal WidthMobile;
    @AuraEnabled public Decimal WidthTablet;
    
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
        try{this.FileIdDesktop = mediaElement.FileIdDesktop__c;}catch(Exception e){}
        try{this.FileIdMobile = mediaElement.FileIdMobile__c;}catch(Exception e){}
        try{this.FileIdTablet = mediaElement.FileIdTablet__c;}catch(Exception e){}
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