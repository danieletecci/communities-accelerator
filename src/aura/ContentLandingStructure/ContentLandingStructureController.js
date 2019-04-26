({
	onInit : function(component, event, helper) {
		helper.getSitemap(component);
		helper.getGeneralData(component);
		helper.setInstance(component);
		//component.set("v.url", "https://cg-ca-dev-dt-dev-ed.preview.salesforce-communities.com/?orgId=00D1U000000tUY7&siteId=0DM1U000000Puum&language=en_US");
	},
	onLogin : function(component, event, helper) {
		if(component.get("v.isLogin")){
			component.set("v.isLogin", false);
			component.set("v.homeUrl", component.get("v.communityPreviewDomain") 
			 + ((component.get("v.urlPathPrefix")) ? "/" + component.get("v.urlPathPrefix") : "") + 
				"/s/");
			component.set("v.url", component.get("v.homeUrl") + "?clusterId=" + component.get("v.clusterId"));
		} else {
			console.log("no login");
			component.set("v.isLoading", false);
		}
	}
})