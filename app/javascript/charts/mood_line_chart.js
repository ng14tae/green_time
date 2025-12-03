// app/javascript/charts/mood_line_chart.js
import { Chart, LineController, LineElement, PointElement, LinearScale, CategoryScale, Tooltip, Title } from "chart.js";

Chart.register(LineController, LineElement, PointElement, LinearScale, CategoryScale, Tooltip, Title);

export function drawMoodLineChart(labels, values) {
    const canvas = document.getElementById('mood-line-chart');
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const minBarWidth = 50;        // 1データあたりの幅
    const minTotalWidth = 300;     // データが少ない場合の最小キャンバス幅
    const realWidth = Math.max(labels.length * minBarWidth, minTotalWidth);

    canvas.width = realWidth;      // 内部描画幅
    canvas.height = 400;
    canvas.style.width = realWidth + "px"; // 表示幅

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
