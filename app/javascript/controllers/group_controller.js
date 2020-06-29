import { Controller } from "stimulus"

export default class extends Controller {

    static targets = [ "dropdown" ]

    connect(){
        var selected_vals = this.parseArrayFromText($('#selected_vals')[0].textContent)
        $('.selectpicker').selectpicker('val', selected_vals);
        this.setDataContentSelectInputs();
        $('.selectpicker').selectpicker('refresh');
        this.setSelectPickerFilterWidth();
    }

    parseArrayFromText(input){
        return input.replace(/[\[\]']+/g, '').replace(/['"]+/g, '').split(',').map(Function.prototype.call, String.prototype.trim);
    }

    setDataContentSelectInputs(){
        for(let i=0; i<document.getElementsByClassName('selectpicker')[0].children.length; i++){
            document.getElementsByClassName('selectpicker')[0].children[i].setAttribute("data-content", document.getElementsByClassName('selectpicker')[0].children[i].innerText)
        }
    }

    setSelectPickerFilterWidth() {
        var width = "width:" + document.getElementsByClassName('input-group-lg')[0].offsetWidth + "px!important";
        document.getElementsByClassName('filter-option-inner-inner')[0].setAttribute("style", width);
        document.getElementsByClassName('bootstrap-select')[0].setAttribute("style", width);
    }
}