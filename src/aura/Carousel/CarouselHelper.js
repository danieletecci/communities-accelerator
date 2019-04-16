({
	init: function(component, event, helper){
		var body = component.get('v.body');
        var cards = [];
        var automaticTransition = component.get('v.automaticTransition');

        body.forEach(function(el) {
            if (el.toString().match(/aura:iteration/)) {
                var children = el.get('v.body');
                cards = children;
            } else {
                cards.push(el);
            }
        });
        component.set('v.cards', cards);

        window.addEventListener('resize', function() {
            helper.setContainerWidth(component, helper);
            helper.scrollToPage(component, event, helper, component.get('v.currentPage'));
        });

        helper.displayCards(component, event, helper);

        if(cards.length > 1 && automaticTransition){
            component.set('v.transitionAuto', helper.fireTransitionAuto(component, event, helper));
        }
	},
    displayCards: function(component, event, helper) {
		var body = component.get('v.body')[0];
		if(!$A.util.isEmpty(body)) {
			var pageCount = component.get('v.cards').length; 
			component.set('v.pages', new Array(pageCount));
		}
    },
    goToNextPage: function(component, event, helper) {
		
        if(component.get('v.pages') != null){
        	var newPage;
        	var currentPage = component.get('v.currentPage');
        	var lastPageIndex = component.get('v.pages').length - 1;
        
	        var loop = component.get('v.loop');
	        var last = false;
	        var direction = component.get('v.direction');

	        if(direction == 'Right'){
		        if (currentPage < lastPageIndex) {
		            newPage = currentPage + 1;
		        } else {
		        	if(loop){	
		            	newPage = 0;
		        	} else{
		        		last = true;
		        	}
		        }
	        }
	        if(direction == 'Left'){
	        	if(currentPage > 1){
	        		newPage = currentPage - 1;
	        	} else{
	        		if(currentPage == 0){
	        			newPage = lastPageIndex;
	        		} else{
	        			if(loop){
	        				newPage = 0;
	        			} else{
	        				last = true;
	        			}	
	        		}
	        		
	        	}
	        }
	        if(!last){	
	        	helper.scrollToPage(component, event, helper, newPage);
	        }
        }
    },
    goToPreviousPage: function(component, event, helper){
    	var newPage;
        var currentPage = component.get('v.currentPage');
        var lastPageIndex = component.get('v.pages').length - 1;
        var direction = component.get('v.direction');
        var loop = component.get('v.loop');
        var last = false;

        if (direction == 'Right'){
	        if (currentPage > 0) {
	            newPage = currentPage - 1;
	        } else {
	        	if(loop){
	            	newPage = lastPageIndex;
	        	} else {
	        		last = true;
	        	}
	        }
        }
        if (direction == 'Left'){
        	if(currentPage > 0 && currentPage != lastPageIndex){
        		newPage = currentPage + 1;
        	} else{
        		if(currentPage == lastPageIndex){
        			newPage = 0;
        		} else{
        			if(loop){
        				newPage = currentPage + 1;
        			} else{
        				last = true;
        			}	
        		}
        	}
        }
		if(!last){	
        	helper.scrollToPage(component, event, helper, newPage);
    	}
    },
    scrollToPage: function(component, event, helper, pageNumber) {
		var containerWidth = component.get('v.containerWidth');

		if (containerWidth > 480) {
			var carouselBody = component.find('carousel-body').getElement();
			var carouselBodyWidth = carouselBody.getBoundingClientRect().width;
			var currentPage = component.get('v.currentPage');
			var increment = (carouselBodyWidth * (pageNumber - currentPage)) / 60;
			var speed = 250; // Milliseconds
			var frameCount = 0;

			var fadeInMode = component.get('v.fadeInMode');

			if(fadeInMode){
				var nextImage = carouselBody.getElementsByClassName('image-' + String(pageNumber)).item(0);
				var currentImage = carouselBody.getElementsByClassName('image-' + String(currentPage)).item(0);
				nextImage.style.opacity = 1;
				nextImage.style.zIndex = 1;
				currentImage.style.opacity = 0;
				currentImage.style.zIndex = 0;
			} else{
				var slideInterval = setInterval(function() {
		            frameCount++;
					window.requestAnimationFrame(function() {
			            carouselBody.scrollLeft += increment;
					});

		            if (frameCount === 60) {
		                clearInterval(slideInterval);
		                currentPage = pageNumber;
						window.requestAnimationFrame(function() {
			                carouselBody.scrollLeft = carouselBodyWidth * currentPage;
						});
		            }
		        }, speed * 0.01667);
			}

			component.set('v.currentPage', pageNumber);
			//helper.updateDots(component, event, helper);

			var automaticTransition = component.get('v.automaticTransition');
			if(automaticTransition){
				helper.resetTransitionAuto(component, event, helper);
			}
		}
	},
	/*
	updateDots: function(component, event, helper) {
		var dots = component.find('dot');
		var currentPage = component.get('v.currentPage');

		
		dots.forEach(function(self, index) {
			if (index === currentPage) {
				self.getElement().classList.add('sc-pagination__dot_selected');
			} else {
				self.getElement().classList.remove('sc-pagination__dot_selected');
			}
		});
		
	},*/
	setContainerWidth: function(component, helper) {
		if (component.getElement() !== null) {
			var containerWidth = Math.ceil(component.getElement().getBoundingClientRect().width);
			component.set('v.containerWidth', containerWidth);
		}
	},
	fireTransitionAuto: function(component, event, helper){
        //segundos
        return window.setInterval(
            function(){helper.goToNextPage(component, event, helper);},
            component.get('v.transitionTime')
        );
    },
    resetTransitionAuto: function(component, event, helper){
    	window.clearInterval(component.get('v.transitionAuto'));
    	component.set('v.transitionAuto', helper.fireTransitionAuto(component, event, helper));
    }
})