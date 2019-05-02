({
	afterRender : function(component, event, helper) {
		this.superAfterRender();
        var cWrapper = component.get("v.componentWrapper");
        var bannerType = cWrapper.BannerFrameType;
		var banner = component.find("banner");
        var width = window.getComputedStyle(banner.getElement()).width.replace('px','');
		if(bannerType === 'Hero'){
            component.set("v.heightValue", Math.floor(width*0.34) + 'px');
        } else if(bannerType === 'Page'){
            component.set("v.heightValue", Math.floor(width*0.25) + 'px');
		} else if(bannerType === 'Square'){
            component.set("v.heightValue", Math.floor(width) + 'px');
		} else if(bannerType === 'Custom'){
            component.set("v.heightValue", Math.floor(cWrapper.CustomHeight) + 'px');
        }
    }
})