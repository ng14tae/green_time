// app/javascript/charts/mood_line_chart.js
import { Chart, LineController, LineElement, PointElement, LinearScale, CategoryScale, Tooltip, Title } from "chart.js";

Chart.register(LineController, LineElement, PointElement, LinearScale, CategoryScale, Tooltip, Title);

export function drawMoodLineChart(labels, values) {
    const ctx = document.getElementById('mood-line-chart')?.getContext('2d');
    if (!ctx) return;
    if (window.moodChart) window.moodChart.destroy();

    window.moodChart = new Chart(ctx, {
        type: 'line',
        data: {
        labels,
        datasets: [{
            label: '気分',
            data: values,
            fill: false,
            borderColor: '#10b981',
            tension: 0.3,
            pointBackgroundColor: '#10b981',
            pointRadius: 5
        }]
        },
        options: {
        responsive: false,
        plugins: {
            tooltip: {
            callbacks: {
                label: (ctx) => ['','😢','😐','😊',''][Math.round(ctx.parsed.y)] || ''
            }
            }
        },
        scales: {
            y: {
            min: 0,
            max: 4,
            ticks: {
                stepSize: 1,
                callback: (v) => ['','😢','😐','😊',''][Math.round(v)] || '',
                font: { size: 16 }
            }
            }
        }
        }
    });
}
