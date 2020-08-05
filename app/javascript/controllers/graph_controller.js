import { Controller } from "stimulus"

export default class extends Controller {
    toggleGraphs(){
        $('#user_scores_graph').toggle();
        $('#subscores_graph').toggle();
    }
}