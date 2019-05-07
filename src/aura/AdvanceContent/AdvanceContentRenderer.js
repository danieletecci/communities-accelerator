({
	afterRender : function(component, helper){
        this.superAfterRender();
        helper.handleOrientation(component);
        window.addEventListener("orientationchange", () => helper.handleOrientation(component));
    },
})