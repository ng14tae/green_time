// app/javascript/charts/mood_line_chart.js
import { Chart, LineController, LineElement, PointElement, LinearScale, CategoryScale, Tooltip, Title } from "chart.js";

Chart.register(LineController, LineElement, PointElement, LinearScale, CategoryScale, Tooltip, Title);

export function drawMoodLineChart(labels, values) {
    const canvas = document.getElementById('mood-line-chart');
    if (!canvas) return;

    const minWidth = 200;
    const realWidth = Math.max(labels.length * 50, minWidth);
    canvas.style.width = realWidth + "px";
    canvas.width = realWidth;
    canvas.height = 400;

    const ctx = canvas.getContext('2d');
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
            responsive: true,           // 親要素に合わせて調整
            maintainAspectRatio: false, // 高さを固定
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
