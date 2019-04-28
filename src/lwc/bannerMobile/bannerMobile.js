import { LightningElement, track, api} from 'lwc';
import { loadStyle,loadScript } from 'lightning/platformResourceLoader';
import Assets from '@salesforce/resourceUrl/Assets';

export default class Banner extends LightningElement {

    @api bannerData;
    @track position = 0;
    @track elements;
    swipedir
    startX
    dist
    threshold = 60 //required min distance traveled to be considered swipe
    allowedTime = 2000 // maximum time allowed to travel that distance
    elapsedTime
    startTime
    firstRender = false;

    

    connectedCallback() {
        this.elements = this.bannerData.slice();
        loadStyle(this, Assets + '/Assets/Styles/roboto.css');
        loadStyle(this, 'fsites/c/resource/Assets/Assets/Styles/bannerMobileExternalStyles.css');
        loadStyle(this, Assets + '/Assets/Styles/bannerExternalStyle.css');
        loadStyle(this, Assets + '/Assets/Bootstrap/css/bootstrap.min.css'); 
        loadScript(this, Assets + '/Assets/Bootstrap/js/bootstrap.min.js');
        loadScript(this, Assets + '/Assets/Bootstrap/js/popper.min.js');
        loadScript(this, Assets + '/Assets/Bootstrap/js/jquery-3.3.1.min.js');
    }

    renderedCallback() {
    //     const carouselDiv = this.template.querySelector('.carousel');
    //     const id = carouselDiv.getAttribute('id');
    //     const carouselIndicators = this.template.querySelector('.carousel-indicators');
    //     const carouselPrev = this.template.querySelector('.carousel-control-prev');
    //     const carouselNext = this.template.querySelector('.carousel-control-next');
    //     carouselIndicators.setAttribute('data-target', `#${id}`);
    //     carouselPrev.setAttribute('href', `#${id}`);
    //     carouselNext.setAttribute('href', `#${id}`);
        const carousel = this.template.querySelector('.carousel-inner');
        if(!this.firstRender){
            carousel.addEventListener('touchstart', (e) => {
                e.preventDefault();
                e.stopPropagation();
                let touchobj = e.changedTouches[0]
                this.swipedir = 'none'
                this.dist = 0
                this.startX = touchobj.pageX
                this.startTime = new Date().getTime()// record time when finger first makes contact with surface
                e.preventDefault()
            })

            carousel.addEventListener('touchmove', (e) => {
                e.preventDefault() // prevent scrolling when inside DIV
            })

            carousel.addEventListener('touchend', (e) => {
                e.preventDefault();
                e.stopPropagation();
                let touchobj = e.changedTouches[0]
                this.distX = touchobj.pageX - this.startX // get horizontal dist traveled by finger while in contact with surface
                this.elapsedTime = new Date().getTime() - this.startTime // get time elapsed
                if (this.elapsedTime <= this.allowedTime){ // first condition for awipe met
                    if (Math.abs(this.distX) >= this.threshold){ // 2nd condition for horizontal swipe met
                        this.swipedir = (this.distX < 0)? 'left' : 'right' // if dist traveled is negative, it indicates left swipe
                        this.handleswipe(this.swipedir);
                    }
                }
                e.preventDefault()
            })
            this.firstRender = true;
        }
        
    }

    handleswipe(isrightswipe){
        if (isrightswipe)
            this.next();
        else{
            this.previous();
        }
    }

    next(){
        this.elements[this.position].class = this.elements[this.position].class.replace(' active','');
        this.elements[this.position].indicatorClass = '';
        this.position++;
        if(this.position === this.elements.length) {
            this.position = 0;
        }
        this.elements[this.position].class = this.elements[this.position].class.concat(' active');
        this.elements[this.position].indicatorClass = 'active';
    }

    previous(){
        this.elements[this.position].class = this.elements[this.position].class.replace(' active','');  
        this.elements[this.position].indicatorClass = '';
        this.position--; 
        if(this.position === -1) {
            this.position = this.elements.length-1;
        }
        this.elements[this.position].class = this.elements[this.position].class.concat(' active');
        this.elements[this.position].indicatorClass = 'active';
    }

    hasText(){
        return this.bannerData.title || this.bannerData.description
    }
}