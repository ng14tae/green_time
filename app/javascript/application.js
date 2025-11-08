// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import "./current_time"
import "chartkick/chart.js"

document.addEventListener("turbo:load", () => {
    Chartkick.eachChart((chart) => chart.redraw());
});
