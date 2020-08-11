var ProgressBar = require('progressbar.js');
import { Controller } from "stimulus"

export default class extends Controller {

    connect(){
        this.drawProgressBar();
        this.removeExtraChildren();
    }

    removeExtraChildren(){
        const element = document.getElementById("container");
        let children = element.children;
        if(children.length > 2){
            for(let i=2; i < children.length; i++){
                const childElement = children[i];
                childElement.remove();
            }
        }
    }

    drawProgressBar(){
        console.log('drawing progress bar');
        const primary = getComputedStyle(document.getElementById("progressStart")).backgroundColor;
        const secondary = getComputedStyle(document.getElementById("progressEnd")).backgroundColor;
        const bar = new ProgressBar.SemiCircle("#container", {
            strokeWidth: 6,
            color: '#FFEA82',
            trailColor: '#eee',
            trailWidth: 1,
            easing: 'easeInOut',
            duration: 1400,
            svgStyle: null,
            text: {
                value: '',
                alignToBottom: false
            },
            from: {color: primary},
            to: {color: secondary},
            // Set default step function for all animate calls
            step: (state, bar) => {
                bar.path.setAttribute('stroke', state.color);
                const value = Math.round(bar.value() * this.data.get("max_score"));
                if (value === 0) {
                    bar.setText('');
                } else {
                    bar.setText(value);
                }

                bar.text.style.color = state.color;
            }
        });
        bar.text.style.fontFamily = '"Raleway", Helvetica, sans-serif';
        bar.text.style.fontSize = '2rem';

        bar.animate(this.data.get("score") / this.data.get("max_score"));  // Number from 0.0 to 1.0
        this.removeExtraChildren();
    }

    disconnect(){
        this.removeExtraChildren();
    }
}