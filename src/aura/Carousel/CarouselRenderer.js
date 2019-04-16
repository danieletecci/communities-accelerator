({
    afterRender: function(component, helper) {
        helper.setContainerWidth(component, helper);
        // NAHUE TEST
        var fadeInMode = component.get('v.fadeInMode');
        if (fadeInMode){
            var Body = component.find('carousel-body').getElement();
            var currentImage = Body.getElementsByClassName('image-0').item(0);
            currentImage.style.opacity = 1;
			currentImage.style.zIndex = 0;
        }

        this.superAfterRender();
    }
})