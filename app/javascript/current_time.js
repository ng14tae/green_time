function updateClocks() {
    console.log('updateClocks関数が実行されました');

        // 現在時刻の更新
        function updateCurrentTime() {
            const now = new Date();
            const timeString = now.toLocaleTimeString('ja-JP', {
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            });

            const currentTimeElement = document.getElementById('current-time');
            if (currentTimeElement) {
                currentTimeElement.textContent = timeString;
            }
        }

        // 勤務時間の更新
        const workTimeElement = document.getElementById('working-time');
        if (workTimeElement && workTimeElement.dataset.checkinTime) {
            const checkinTime = new Date(workTimeElement.dataset.checkinTime);

            function updateWorkTime() {
                const now = new Date();
                const elapsed = Math.floor((now - checkinTime) / 1000);

                const hours = Math.floor(elapsed / 3600);
                const minutes = Math.floor((elapsed % 3600) / 60);
                const seconds = elapsed % 60;

                const formatted = `${hours}時間${minutes}分${seconds}秒`;
                workTimeElement.textContent = formatted;
            }

            // すぐに実行して、1秒ごとに更新
            updateWorkTime();
            setInterval(updateWorkTime, 1000);
        }

        // 現在時刻も1秒ごとに更新
        updateCurrentTime();
        setInterval(updateCurrentTime, 1000);
    }

// ページ読み込み時に実行
document.addEventListener('DOMContentLoaded', updateClocks);
document.addEventListener('turbo:load', updateClocks);