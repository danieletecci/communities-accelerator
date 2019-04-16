({
	setFilteredSitemap : function(component, searchedStr) {
		var sitemapBackupString = JSON.stringify(component.get("v.sitemapBackup"));
		var sitemapBackup = JSON.parse(sitemapBackupString).menus;
		var navigationBackup = JSON.parse(sitemapBackupString).navigations;
		if(searchedStr != null && searchedStr != ''){
			for(var i=0; i < sitemapBackup.length; i++){
				i += this.updateMenuWrapper(sitemapBackup[i], sitemapBackup, i, searchedStr);
			}
			for(var i=0; i < navigationBackup.length; i++){
				if(!navigationBackup[i].Name.toUpperCase().includes(searchedStr.toUpperCase())){
					navigationBackup.splice(i, 1);
					i--;
				}
			}
		}
		
		let sitemap = [...sitemapBackup];
		let navigation = [...navigationBackup];
		component.set("v.sitemap", sitemap);
		component.set("v.otherNavigations", navigation);
	},
	updateMenuWrapper : function(menuWrapper, array, index, searchedStr){
		var returnValue;
		if(menuWrapper.childsMenu && menuWrapper.childsMenu.length > 0){
			for(var i=0; i < menuWrapper.childsMenu.length; i++){
				i += this.updateMenuWrapper(menuWrapper.childsMenu[i], menuWrapper.childsMenu, i, searchedStr);
			}
			if(menuWrapper.childsMenu.length == 0 && !menuWrapper.menu.Name.toUpperCase().includes(searchedStr.toUpperCase())){
				array.splice(index, 1);
				returnValue = -1
			} else {
				returnValue = 0;
			}
		} else if(!menuWrapper.menu.Name.toUpperCase().includes(searchedStr.toUpperCase())){
			array.splice(index, 1);
			returnValue = -1;
		} else {
			returnValue = 0;
		}
		
		return returnValue;
	},
	getSiteId : function(component) {
		console.log(component.get("v.url"));
		var helper = this;
		var action = component.get('c.getSiteId');
		action.setParams({
			clusterId : component.get("v.clusterId")
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var oldSite 				= component.get("v.siteId");
				var Articleite 				= response.getReturnValue()
				var communityPreviewDomain 	= component.get("v.communityPreviewDomain");
				if(communityPreviewDomain == null || Articleite == null){
					helper.showToast("Error!", $A.get("$Label.c.ContentLandingStructureMissingConfiguration"), "error");
					component.set("v.isLoading", true);
					return;
				}
				component.set('v.siteId', Articleite);
				var instance = component.get("v.instance");
				if(oldSite != Articleite){
					component.set("v.isLogin", true);
					component.set("v.url", "https://" + communityPreviewDomain + "/?orgId=" + 
								component.get("v.orgId") + "&siteId=" + Articleite + "&language=en_US");
					component.set("v.isLoading", true);
				}
				console.log(component.get("v.url"));
			}
		});
		$A.enqueueAction(action);
	},
	showToast : function(toastTitle, toastMessage, toastType){
	    var toastEvent = $A.get("e.force:showToast");
	    toastEvent.setParams({
	        title: toastTitle,
	        message: toastMessage,
	        type: toastType,
			mode: ((toastType === "success") ? 'dismissable' : 'sticky')
	    });
	    toastEvent.fire();
	}
})