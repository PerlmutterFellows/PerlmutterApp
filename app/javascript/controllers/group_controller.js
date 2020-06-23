import { Controller } from "stimulus"

export default class extends Controller {

    static targets = [ "dropdown" ]

    connect(){
        var selected_vals = this.parseArrayFromText($('#selected_vals')[0].textContent)
        $('.selectpicker').selectpicker('val', selected_vals);
        this.setDataContentSelectInputs();
        $('.selectpicker').selectpicker('refresh');
    }

    parseArrayFromText(input){
        input.replace(/[\[\]']+/g, '').replace(/['"]+/g, '').split(',').map(Function.prototype.call, String.prototype.trim);
    }

    setDataContentSelectInputs(){
        for(let i=0; i<document.getElementsByClassName('selectpicker')[0].children.length; i++){
            document.getElementsByClassName('selectpicker')[0].children[i].setAttribute("data-content", document.getElementsByClassName('selectpicker')[0].children[i].innerText)
        }
    }
}