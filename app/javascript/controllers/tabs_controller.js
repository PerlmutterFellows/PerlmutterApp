import { Controller } from "stimulus"

export default class extends Controller {
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
}