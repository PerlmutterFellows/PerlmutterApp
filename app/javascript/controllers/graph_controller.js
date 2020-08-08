import { Controller } from "stimulus"
import Chartkick from "chartkick/dist/chartkick.esm";

export default class extends Controller {
    connect(){
        let id = this.data.get("id");
        this.data.set("graph", "total_scores");
    }
    toggleGraphs(){
        const user_scores_graph = Chartkick.charts['scores_graph'];
        const graph_shown = this.data.get("graph");
        const id = this.data.get("id");
        if(graph_shown == "total_scores"){
            const subscoresURL = `/users/subscores/${id}`;
            fetch(subscoresURL).then(response => response.json()).then(data =>
                user_scores_graph.updateData(data)
            );
            this.data.set("graph", "subscores")
        } else {
            const scoresURL = `/users/scores/${id}`;
            fetch(scoresURL).then(response => response.json()).then(data =>
                user_scores_graph.updateData(data)
            );
            this.data.set("graph", "total_scores")
        }

    }
}