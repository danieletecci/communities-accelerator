public class CustomSettingWrapper {
    
    public String ClusterFieldForPublicGroups;
    public String SalesforceDomain;
    public String ContentLandingColumnFields;
    public String ContentLandingRecordTypes;
    public String ContentTemplateRecordTypes;
    public Decimal MaxSizeDesktop;
    public Decimal MaxSizeMobile;
    public Decimal MaxSizeTablet;
    public Boolean EnableMediaElementAutomaticResize;
    
    public CustomSettingWrapper(CMSSettings__c cmsSetting, CMSContentSettings__c contentSetting, CMSMediaElementSettings__c meSetting){
        this.ClusterFieldForPublicGroups = cmsSetting.ClusterFieldForPublicGroups__c;
        this.SalesforceDomain = cmsSetting.SalesforceDomain__c;
        this.ContentLandingColumnFields = contentSetting.ContentLandingColumnFields__c;
        this.ContentLandingRecordTypes = contentSetting.ContentLandingRecordTypes__c;
        this.ContentTemplateRecordTypes = contentSetting.ContentTemplateRecordTypes__c;
        this.MaxSizeDesktop = meSetting.MaxSizeDesktop__c;
        this.MaxSizeMobile = meSetting.MaxSizeMobile__c;
        this.MaxSizeTablet = meSetting.MaxSizeTablet__c;
        this.EnableMediaElementAutomaticResize = meSetting.EnableMediaElementAutomaticResize__c;
    }

}