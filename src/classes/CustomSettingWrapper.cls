public class CustomSettingWrapper {
    
    public String clusterFieldForPublicGroups;
    public String salesforceDomain;
    public String contentLandingColumnFields;
    public String contentLandingRecordTypes;
    public String contentTemplateRecordTypes;
    public Decimal maxSizeDesktop;
    public Decimal maxSizeMobile;
    public Decimal maxSizeTablet;
    public Boolean enableMediaElementAutomaticResize;
    
    public CustomSettingWrapper(CMSSettings__c cmsSetting, CMSContentSettings__c contentSetting, CMSMediaElementSettings__c meSetting){
        this.clusterFieldForPublicGroups = cmsSetting.ClusterFieldForPublicGroups__c;
        this.salesforceDomain = cmsSetting.SalesforceDomain__c;
        this.contentLandingColumnFields = contentSetting.ContentLandingColumnFields__c;
        this.contentLandingRecordTypes = contentSetting.ContentLandingRecordTypes__c;
        this.contentTemplateRecordTypes = contentSetting.ContentTemplateRecordTypes__c;
        this.maxSizeDesktop = meSetting.MaxSizeDesktop__c;
        this.maxSizeMobile = meSetting.MaxSizeMobile__c;
        this.maxSizeTablet = meSetting.MaxSizeTablet__c;
        this.enableMediaElementAutomaticResize = meSetting.EnableMediaElementAutomaticResize__c;
    }

}