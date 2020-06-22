import { Controller } from "stimulus"

export default class extends Controller {

    static targets = [ "dropdown" ]

    connect(){
        var selected_vals = $('#selected_vals')[0].textContent.replace(/[\[\]']+/g, '').replace(/['"]+/g, '').split(',');
        selected_vals = selected_vals.map(Function.prototype.call, String.prototype.trim);
        $('.selectpicker').selectpicker('val', selected_vals);
        for(let i=0; i<document.getElementsByClassName('selectpicker')[0].children.length; i++){
            document.getElementsByClassName('selectpicker')[0].children[i].setAttribute("data-content", document.getElementsByClassName('selectpicker')[0].children[i].innerText)
        }
        $('.selectpicker').selectpicker('refresh');
    }
}