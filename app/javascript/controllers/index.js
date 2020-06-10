// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js.

import { Application, Controller } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"

const application = Application.start()
application.register("tabs", class extends Controller {

    static targets = [ "tab", "panel" ]

    initialize() {
        this.showTab()
    }

    change(event) {
        this.index = this.tabTargets.indexOf(event.currentTarget)
    }

    showTab() {
        this.tabTargets.forEach((tab, index) => {
            tab.classList.toggle("active", index == this.index)
            this.panelTargets[index].style.display = index == this.index ? "block" : "none"
        })
    }

    get index() {
        return parseInt(this.data.get("index") || 0)
    }

    set index(value) {
        this.data.set("index", value)
        this.showTab()
    }
})
application.register("upload", class extends Controller {

    static targets = [ "file" ]

    update(event) {
        event.target.nextSibling.innerText = event.target.value.replace(/.*(\/|\\)/, '');
    }

})

const context = require.context("controllers", true, /_controller\.js$/)
application.load(definitionsFromContext(context))

