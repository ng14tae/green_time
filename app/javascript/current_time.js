document.addEventListener('DOMContentLoaded', function() {
    const timeElement = document.getElementById('current-time');

    if (timeElement) {
        function updateTime() {
        const now = new Date();
        const timeString = now.toLocaleTimeString('ja-JP', {
            hour: '2-digit',      // 時は2桁表示
            minute: '2-digit',    // 分は2桁表示
            second: '2-digit',    // 秒は2桁表示
            hour12: false,        // 24時間表示（重要！）
            timeZone: 'Asia/Tokyo' // 東京時間（重要！）
        });
        timeElement.textContent = timeString;
        }

        updateTime();
        setInterval(updateTime, 1000);
    }
});