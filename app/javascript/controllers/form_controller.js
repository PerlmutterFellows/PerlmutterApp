import { Controller } from "stimulus"

export default class extends Controller {

    connect(){
        this.setRequired()
    }

    setRequired(){
        $(`.form-group`).each(function(x, formGroup) {
            if (!$(formGroup).hasClass("d-none")){
                $(formGroup).find("input").attr("required", true)
                $(formGroup).find("input").removeAttr("disabled")
                $(formGroup).find("input").each(function (y, input) {
                    $(input).attr("name", $(input).data("name"))
                })
            }
            else{
                $(formGroup).find("input").removeAttr("required")
                $(formGroup).find("input").attr("disabled", "disabled")
                $(formGroup).find("input").removeAttr("name")
            }
        });
    }

    toggle(){
        let triggerName = $(event.target).data("trigger")
        $(`.trigger-displayed`).addClass("d-none")
        $(`.trigger-displayed`).removeClass("trigger-displayed")
        $(`.form-group[data-trigger='${triggerName}']`).removeClass("d-none")
        $(`.form-group[data-trigger='${triggerName}']`).addClass("trigger-displayed")
        this.setRequired()
    }


}