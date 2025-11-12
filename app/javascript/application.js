// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import "./current_time"
import "chart.js/auto"
import "chartkick/chart.js"

document.addEventListener("turbo:load", () => {
    Chartkick.eachChart((chart) => chart.redraw());
});

// --------------------------------------------------
// 📋 LINEデバッグビューア（LINE内ブラウザ専用）
// --------------------------------------------------
function setupLineDebug() {
  // すでに存在する場合はスキップ
  if (document.getElementById("line-debug")) return;

  const debugBox = document.createElement("div");
  debugBox.id = "line-debug";
  debugBox.style.cssText = `
    position: fixed;
    bottom: 0;
    left: 0;
    width: 100%;
    max-height: 40%;
    overflow-y: auto;
    background: rgba(0,0,0,0.8);
    color: #0f0;
    font-size: 11px;
    font-family: monospace;
    padding: 6px;
    white-space: pre-wrap;
    z-index: 999999;
  `;
  document.body.appendChild(debugBox);

  // console.logを上書き
  const originalLog = console.log;
  console.log = function (...args) {
    originalLog.apply(console, args);
    const msg = args.map(a => (typeof a === 'object' ? JSON.stringify(a, null, 2) : a)).join(' ');
    debugBox.textContent += msg + "\n";
  };

  console.log("🟢 LINEデバッグビューア有効化");
  console.log("UserAgent:", navigator.userAgent);

  if (navigator.userAgent.toLowerCase().includes("line")) {
    console.log("📱 LINE内ブラウザで実行中");
  } else {
    console.log("🌐 外部ブラウザで実行中");
  }
}

document.addEventListener("turbo:load", () => {
  setupLineDebug();
});
