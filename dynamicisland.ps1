# DynamicIsland.ps1
# Crea una isla dinámica con diseño responsivo y estilo iPhone.
# Ejecuta: powershell -ExecutionPolicy Bypass -File .\DynamicIsland.ps1

$TempDir = Join-Path $env:TEMP "DynamicIsland"
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

$htmlPath = Join-Path $TempDir "dynamic_island.html"

$html = @'
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Dynamic Island</title>
  <style>
    :root {
      --bg1: #070b14;
      --bg2: #111827;
      --glass: rgba(20, 25, 36, 0.78);
      --glass-2: rgba(255,255,255,0.06);
      --line: rgba(255,255,255,0.12);
      --text: #edf6ff;
      --sub: #a9b9d0;
      --accent: #7dd3fc;
      --green: #8ae28c;
      --orange: #ffbf69;
      --bg-badge: rgba(255,255,255,0.08);
    }

    * {
      box-sizing: border-box;
      -webkit-tap-highlight-color: transparent;
    }

    html, body {
      margin: 0;
      width: 100%;
      height: 100%;
      font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
      background: radial-gradient(circle at top, #182236 0%, var(--bg1) 38%, #050912 100%);
      color: var(--text);
      overflow: hidden;
    }

    body {
      display: grid;
      place-items: center;
    }

    .scene {
      position: relative;
      width: min(100vw, 560px);
      height: min(100vh, 960px);
      display: flex;
      align-items: flex-start;
      justify-content: center;
      padding-top: 20px;
    }

    .phone {
      width: min(92vw, 430px);
      height: min(80vh, 720px);
      border-radius: 42px;
      background: linear-gradient(180deg, rgba(20, 28, 38, 0.9), rgba(8, 12, 18, 0.96));
      border: 1px solid rgba(255,255,255,0.12);
      box-shadow:
        0 30px 80px rgba(0,0,0,0.62),
        inset 0 0 30px rgba(255,255,255,0.04);
      position: relative;
      overflow: hidden;
    }

    .phone::before {
      content: "";
      position: absolute;
      inset: 0;
      background: linear-gradient(180deg, rgba(255,255,255,0.06), transparent 22%);
      pointer-events: none;
    }

    .camera-notch {
      position: absolute;
      top: 16px;
      left: 50%;
      transform: translateX(-50%);
      width: 144px;
      height: 26px;
      background: rgba(0,0,0,0.7);
      border-radius: 0 0 18px 18px;
      box-shadow: inset 0 -1px 0 rgba(255,255,255,0.06);
      z-index: 3;
    }

    .island {
      position: absolute;
      top: 18px;
      left: 50%;
      transform: translateX(-50%);
      width: clamp(180px, 45vw, 310px);
      height: 62px;
      border-radius: 999px;
      background: rgba(12, 16, 22, 0.95);
      border: 1px solid rgba(255,255,255,0.1);
      box-shadow:
        0 16px 28px rgba(0,0,0,0.45),
        inset 0 0 18px rgba(255,255,255,0.05);
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 10px 16px 10px 12px;
      transition: all 0.36s cubic-bezier(.2,.8,.2,1);
      cursor: pointer;
      user-select: none;
      z-index: 10;
    }

    .island.expanded {
      width: clamp(250px, 70vw, 360px);
      height: 170px;
      border-radius: 26px;
      padding: 14px 18px 12px 18px;
      background: linear-gradient(180deg, rgba(18, 22, 29, 0.96), rgba(10, 12, 17, 0.92));
      align-items: flex-start;
    }

    .island:hover {
      filter: brightness(1.05);
    }

    .mini {
      display: flex;
      align-items: center;
      gap: 10px;
      width: 100%;
      transition: opacity 0.2s ease;
      overflow: hidden;
    }

    .island.expanded .mini {
      opacity: 0;
      pointer-events: none;
    }

    .avatar {
      width: 34px;
      height: 34px;
      border-radius: 50%;
      background: linear-gradient(135deg, #e0f2fe, #60a5fa, #a78bfa);
      box-shadow: 0 8px 22px rgba(96,165,250,.35);
      display: grid;
      place-items: center;
      font-weight: 700;
      color: #07131f;
      font-size: 0.8rem;
      flex-shrink: 0;
    }

    .meta {
      flex: 1;
      min-width: 0;
      display: flex;
      flex-direction: column;
      justify-content: center;
    }

    .title {
      font-size: 0.78rem;
      font-weight: 700;
      line-height: 1.1;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .subtitle {
      font-size: 0.65rem;
      color: var(--sub);
      letter-spacing: 0.04em;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .signal {
      display: flex;
      align-items: flex-end;
      gap: 3px;
      height: 18px;
      margin-left: 6px;
      flex-shrink: 0;
    }

    .bar {
      width: 4px;
      border-radius: 999px;
      background: linear-gradient(180deg, #dbeafe, #7dd3fc);
      opacity: 0.9;
      transition: height 0.25s ease;
    }

    .bar:nth-child(1) { height: 7px; }
    .bar:nth-child(2) { height: 12px; }
    .bar:nth-child(3) { height: 16px; }
    .bar:nth-child(4) { height: 11px; }

    .battery {
      width: 30px;
      height: 16px;
      border-radius: 6px;
      border: 1px solid rgba(255,255,255,0.45);
      position: relative;
      margin-left: 8px;
      background: rgba(255,255,255,0.04);
      flex-shrink: 0;
    }

    .battery::before {
      content: "";
      position: absolute;
      inset: 3px 3px 3px 3px;
      border-radius: 4px;
      background: linear-gradient(90deg, #98f5a5, #8ae28c);
    }

    .battery::after {
      content: "";
      position: absolute;
      right: -4px;
      top: 5px;
      width: 2px;
      height: 6px;
      border-radius: 2px;
      background: rgba(255,255,255,0.6);
    }

    .expanded-panel {
      position: absolute;
      inset: 0;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      opacity: 0;
      transform: translateY(10px);
      transition: all 0.28s ease;
      pointer-events: none;
      padding: 14px 16px 12px 16px;
    }

    .island.expanded .expanded-panel {
      opacity: 1;
      transform: translateY(0);
      pointer-events: auto;
    }

    .top-row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
    }

    .call-name {
      display: flex;
      align-items: center;
      gap: 10px;
      min-width: 0;
    }

    .pill {
      width: 30px;
      height: 30px;
      border-radius: 50%;
      background: linear-gradient(135deg, #dbeafe, #60a5fa);
      display: grid;
      place-items: center;
      color: #0b1220;
      font-size: 0.7rem;
      font-weight: 700;
      flex-shrink: 0;
    }

    .call-name-text {
      min-width: 0;
    }

    .call-name-text .n {
      font-size: 0.78rem;
      font-weight: 700;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .call-name-text .n2 {
      font-size: 0.64rem;
      color: var(--sub);
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .status-dot {
      width: 10px;
      height: 10px;
      border-radius: 50%;
      background: var(--green);
      box-shadow: 0 0 12px rgba(138,226,140,.8);
      flex-shrink: 0;
    }

    .middle {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: 6px;
    }

    .big-time {
      font-size: 2rem;
      font-weight: 700;
      letter-spacing: -0.05em;
    }

    .mini-badges {
      display: flex;
      gap: 8px;
      align-items: center;
    }

    .badge {
      min-width: 54px;
      height: 30px;
      border-radius: 12px;
      background: rgba(255,255,255,0.06);
      border: 1px solid rgba(255,255,255,0.07);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 0.7rem;
      color: var(--sub);
    }

    .bottom {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
    }

    .ctrl {
      flex: 1;
      height: 42px;
      border-radius: 999px;
      border: 1px solid rgba(255,255,255,0.08);
      background: rgba(255,255,255,0.04);
      display: grid;
      place-items: center;
      color: var(--text);
      font-weight: 600;
      font-size: 0.72rem;
    }

    .ctrl.red {
      background: rgba(255, 102, 102, 0.12);
      border-color: rgba(255, 120, 120, 0.25);
      color: #ffd7d7;
    }

    .screen {
      position: absolute;
      inset: 0;
      background:
        radial-gradient(circle at 50% 12%, rgba(125,211,252,0.14), transparent 20%),
        linear-gradient(180deg, rgba(10,15,22,0.3), rgba(10,15,22,0.55));
      z-index: 0;
    }

    .content {
      position: absolute;
      inset: 0;
      z-index: 1;
      padding-top: 84px;
      display: flex;
      align-items: flex-start;
      justify-content: center;
    }

    .widget {
      width: min(80vw, 300px);
      height: 120px;
      border-radius: 28px;
      background: linear-gradient(135deg, rgba(20,24,32,0.88), rgba(33,41,52,0.78));
      border: 1px solid rgba(255,255,255,0.08);
      box-shadow: inset 0 0 18px rgba(255,255,255,0.02);
      display: flex;
      flex-direction: column;
      justify-content: center;
      padding: 16px 18px;
      color: white;
    }

    .widget .row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 10px;
      font-size: 0.74rem;
      color: var(--sub);
    }

    .widget .value {
      font-size: 1.1rem;
      font-weight: 700;
      letter-spacing: -0.04em;
    }

    .widget .graph {
      display: flex;
      align-items: flex-end;
      gap: 5px;
      height: 40px;
      margin-top: 8px;
    }

    .widget .graph span {
      display: inline-block;
      width: 7px;
      border-radius: 999px;
      background: linear-gradient(180deg, #7dd3fc, #38bdf8);
      box-shadow: 0 0 12px rgba(56,189,248,0.35);
    }

    @media (max-width: 480px) {
      .scene {
        padding-top: 10px;
      }

      .phone {
        width: 96vw;
        height: 92vh;
        border-radius: 34px;
      }

      .island {
        top: 12px;
        width: min(62vw, 260px);
        height: 54px;
      }

      .island.expanded {
        width: min(84vw, 350px);
        height: 152px;
      }

      .content {
        padding-top: 70px;
      }

      .widget {
        width: min(72vw, 260px);
        height: 108px;
      }

      .big-time {
        font-size: 1.6rem;
      }

      .badge {
        min-width: 44px;
      }
    }
  </style>
</head>
<body>
  <div class="scene">
    <div class="phone">
      <div class="screen"></div>

      <div class="camera-notch"></div>

      <div class="island" id="island" tabindex="0" aria-label="isla dinámica">
        <div class="mini">
          <div class="avatar">A</div>
          <div class="meta">
            <div class="title">Ana</div>
            <div class="subtitle">Llamando...</div>
          </div>
          <div class="signal" aria-label="señal">
            <span class="bar" style="height: 8px;"></span>
            <span class="bar" style="height: 12px;"></span>
            <span class="bar" style="height: 16px;"></span>
            <span class="bar" style="height: 10px;"></span>
          </div>
          <div class="battery"></div>
        </div>

        <div class="expanded-panel">
          <div class="top-row">
            <div class="call-name">
              <div class="pill">A</div>
              <div class="call-name-text">
                <div class="n">Ana</div>
                <div class="n2">Llamada activa</div>
              </div>
            </div>
            <div class="status-dot"></div>
          </div>

          <div class="middle">
            <div class="big-time">9:41</div>
            <div class="mini-badges">
              <div class="badge">Wi‑Fi</div>
              <div class="badge">LTE</div>
            </div>
          </div>

          <div class="bottom">
            <div class="ctrl">Silenciar</div>
            <div class="ctrl">Video</div>
            <div class="ctrl red">Colgar</div>
          </div>
        </div>
      </div>

      <div class="content">
        <div class="widget">
          <div class="row">
            <span>Actividad</span>
            <span>Hoy</span>
          </div>
          <div class="value">8.4 km</div>
          <div class="graph" aria-label="gráfico">
            <span style="height: 20px;"></span>
            <span style="height: 38px;"></span>
            <span style="height: 16px;"></span>
            <span style="height: 44px;"></span>
            <span style="height: 34px;"></span>
            <span style="height: 60px;"></span>
            <span style="height: 56px;"></span>
            <span style="height: 80px;"></span>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script>
    const island = document.getElementById("island");

    island.addEventListener("click", () => {
      island.classList.toggle("expanded");
    });

    island.addEventListener("keydown", (e) => {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        island.classList.toggle("expanded");
      }
    });

    function animateBars() {
      const bars = document.querySelectorAll(".bar");
      bars.forEach((bar) => {
        const h = 8 + Math.random() * 18;
        bar.style.height = `${h}px`;
        bar.style.opacity = (0.5 + Math.random() * 0.5).toFixed(2);
      });
    }

    setInterval(animateBars, 350);

    const graphBars = document.querySelectorAll(".widget .graph span");
    graphBars.forEach((bar, i) => {
      const h = 18 + Math.random() * 60;
      bar.style.height = `${h}px`;
      bar.style.opacity = 0.8 + Math.random() * 0.2;
    });
  </script>
</body>
</html>
'@

Set-Content -Path $htmlPath -Value $html -Encoding UTF8

Write-Host "Abriendo la isla dinámica..."
Start-Process $htmlPath