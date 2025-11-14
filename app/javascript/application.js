import "@hotwired/turbo-rails";
import "./controllers";
import "./current_time";
import "chartkick/chart.js";
import { drawMoodLineChart } from "./charts/mood_line_chart.js";
window.drawMoodLineChart = drawMoodLineChart;

document.addEventListener("turbo:load", () => {
    Chartkick.eachChart((chart) => chart.redraw());
});
