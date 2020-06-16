import { Controller } from "stimulus"

export default class extends Controller {

    static targets = [ "file" ]

    update(event) {
        event.target.nextSibling.innerText = event.target.value.replace(/.*(\/|\\)/, '');
    }
}