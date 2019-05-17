import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class Acordeon extends LightningElement {

    @api filters;

    connectedCallback() {
        loadStyle(this, '/sfsites/c/resource/Assets/Assets/Styles/accordeonExternalStyles.css');
    }

    openAccordeon(event){
        var panel;
        event.currentTarget.classList.toggle("active");
        panel = event.currentTarget.nextElementSibling;
        if (panel.style.maxHeight){
            panel.style.maxHeight = null;
            panel.style.overflow = "hidden";
            panel.classList.toggle("active");
        } else {
            panel.style.maxHeight = "218px";
            if(panel.scrollHeight > 218){
                panel.style.overflow = "scroll";
            }
            panel.classList.toggle("active");
        } 
    }

    acordeonRadioBtnSelected(event){
        var value = JSON.stringify({ 'value': event.currentTarget.value, 
        'accordeon': event.currentTarget.dataset.accordeon,
        'check': event.currentTarget.checked,
        'label': event.currentTarget.dataset.label});
        
        event.currentTarget.classList.toggle("active");

        this.eventDispatch(value);
        
    }

    acordeonCheckboxSelected(event){
        var value = JSON.stringify({ 
        'value': event.currentTarget.value, 
        'accordeon': event.currentTarget.dataset.accordeon,
        'check': event.currentTarget.checked,
        'label': event.currentTarget.dataset.label});
        
        event.currentTarget.classList.toggle("active");

        this.eventDispatch(value);
    }

    eventDispatch(value){
        const filterItemSelected = new CustomEvent('filterselected', {bubbles:"true",
        detail: {value}
        });
        this.dispatchEvent(filterItemSelected);
    }

    removeFilters(){
        var filters = JSON.parse(JSON.stringify(this.filters));
        filters.forEach(f => {
            f.values.forEach(a => {
                a.isSelected = false;

            })
        });
        this.filters = filters;
        this.eventDispatch(null);
    }
}