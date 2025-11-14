import { Chart, LineController, LineElement, PointElement, LinearScale, CategoryScale, Tooltip, Title } from "chart.js";

Chart.register(LineController, LineElement, PointElement, LinearScale, CategoryScale, Tooltip, Title);

export function drawMoodLineChart(labels, values) {
    const ctx = document.getElementById('mood-line-chart').getContext('2d');

    // 既に描画済みなら破棄
    if (window.moodChart) {
        window.moodChart.destroy();
    }

    window.moodChart = new Chart(ctx, {
        type: 'line',
        data: {
        labels: labels,
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
            responsive: true,
            plugins: {
                tooltip: {
                callbacks: {
                    label: (ctx) => {
                    const v = ctx.parsed.y;
                    return ['','😢 悪い','😐 普通','😊 良い',''][v];
                    }
                }
                }
            },
            scales: {
                y: {
                min: 0,
                max: 4,
                ticks: {
                    stepSize: 1,
                    callback: (v) => ['','😢 悪い','😐 普通','😊 良い',''][v],
                    font: { size: 16 }
                }
                }
            }
            }

    });
}
