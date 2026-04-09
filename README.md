<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>MoodNest — README</title>
<link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display:ital@0;1&family=DM+Sans:wght@300;400;500&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet"/>
<style>
  :root {
    --bg: #0a0a0f;
    --bg2: #111118;
    --bg3: #1a1a24;
    --card: #14141e;
    --border: rgba(255,255,255,0.07);
    --border2: rgba(255,255,255,0.13);
    --text: #f0eee8;
    --muted: #8b8a99;
    --hint: #4a4960;
    --accent: #b09fff;
    --accent2: #ff9fd0;
    --accent3: #9fffd4;
    --accent4: #ffd49f;
    --green: #34d399;
    --purple: #a78bfa;
    --pink: #f472b6;
  }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    background: var(--bg);
    color: var(--text);
    font-family: 'DM Sans', sans-serif;
    font-weight: 300;
    line-height: 1.7;
    overflow-x: hidden;
  }
  /* ── HERO ── */
  .hero {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    position: relative;
    padding: 4rem 2rem;
    overflow: hidden;
  }
  .hero-orb {
    position: absolute;
    border-radius: 50%;
    filter: blur(80px);
    opacity: 0.18;
    animation: pulse 6s ease-in-out infinite;
  }
  .orb1 { width: 500px; height: 500px; background: #7c3aed; top: -100px; left: -150px; animation-delay: 0s; }
  .orb2 { width: 400px; height: 400px; background: #db2777; top: 100px; right: -120px; animation-delay: 2s; }
  .orb3 { width: 350px; height: 350px; background: #0891b2; bottom: -80px; left: 30%; animation-delay: 4s; }
  @keyframes pulse {
    0%, 100% { transform: scale(1) translate(0,0); opacity: 0.18; }
    50% { transform: scale(1.15) translate(20px, -20px); opacity: 0.25; }
  }
  .hero-content { position: relative; z-index: 2; }
  .hero-pill {
    display: inline-flex; align-items: center; gap: 8px;
    border: 1px solid var(--border2);
    border-radius: 100px;
    padding: 6px 16px;
    font-size: 12px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--muted);
    margin-bottom: 2rem;
    animation: fadeUp 0.8s ease both;
  }
  .hero-pill span { width: 6px; height: 6px; border-radius: 50%; background: var(--green); display: inline-block; animation: blink 2s infinite; }
  @keyframes blink { 0%,100%{opacity:1} 50%{opacity:0.3} }
  .hero-logo {
    font-family: 'DM Serif Display', serif;
    font-size: clamp(4rem, 12vw, 9rem);
    letter-spacing: -0.03em;
    line-height: 1;
    margin-bottom: 0.5rem;
    background: linear-gradient(135deg, #e0d7ff 0%, #f0a9d8 40%, #a9f0d0 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    animation: fadeUp 0.9s 0.1s ease both;
  }
  .hero-tagline {
    font-family: 'DM Serif Display', serif;
    font-style: italic;
    font-size: clamp(1.1rem, 3vw, 1.6rem);
    color: var(--muted);
    margin-bottom: 2.5rem;
    animation: fadeUp 0.9s 0.2s ease both;
  }
  .badges {
    display: flex; flex-wrap: wrap; gap: 10px;
    justify-content: center;
    margin-bottom: 3rem;
    animation: fadeUp 0.9s 0.3s ease both;
  }
  .badge {
    display: flex; align-items: center; gap: 6px;
    padding: 6px 14px;
    border-radius: 8px;
    border: 1px solid var(--border2);
    font-size: 12px;
    font-family: 'JetBrains Mono', monospace;
    font-weight: 500;
    letter-spacing: 0.02em;
    background: var(--card);
  }
  .badge-dot { width: 7px; height: 7px; border-radius: 50%; }
  .b-swift { color: #f05138; } .bd-swift { background: #f05138; }
  .b-swiftui { color: #007aff; } .bd-swiftui { background: #007aff; }
  .b-ios { color: #a78bfa; } .bd-ios { background: #a78bfa; }
  .b-privacy { color: #34d399; } .bd-privacy { background: #34d399; }
  .b-offline { color: #fb923c; } .bd-offline { background: #fb923c; }
  .hero-desc {
    max-width: 560px;
    margin: 0 auto;
    color: var(--muted);
    font-size: 1rem;
    line-height: 1.8;
    animation: fadeUp 0.9s 0.4s ease both;
  }
  .hero-desc strong { color: var(--text); font-weight: 500; }
  @keyframes fadeUp {
    from { opacity: 0; transform: translateY(24px); }
    to { opacity: 1; transform: translateY(0); }
  }
  /* ── SECTIONS ── */
  section { padding: 5rem 2rem; max-width: 900px; margin: 0 auto; }
  .section-label {
    font-family: 'JetBrains Mono', monospace;
    font-size: 11px;
    letter-spacing: 0.2em;
    text-transform: uppercase;
    color: var(--hint);
    margin-bottom: 0.5rem;
  }
  .section-title {
    font-family: 'DM Serif Display', serif;
    font-size: clamp(2rem, 5vw, 3rem);
    line-height: 1.15;
    margin-bottom: 1.5rem;
    color: var(--text);
  }
  .divider { border: none; border-top: 1px solid var(--border); margin: 0; }
  /* ── FEATURE GRID ── */
  .feature-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
    gap: 1px;
    border: 1px solid var(--border);
    border-radius: 16px;
    overflow: hidden;
    background: var(--border);
  }
  .feature-card {
    background: var(--card);
    padding: 1.75rem;
    transition: background 0.3s;
  }
  .feature-card:hover { background: var(--bg3); }
  .feature-icon {
    width: 40px; height: 40px;
    border-radius: 10px;
    display: flex; align-items: center; justify-content: center;
    font-size: 18px;
    margin-bottom: 1rem;
  }
  .feature-title { font-weight: 500; font-size: 0.95rem; margin-bottom: 0.5rem; color: var(--text); }
  .feature-desc { font-size: 0.85rem; color: var(--muted); line-height: 1.6; }
  /* ── ARCH DIAGRAM ── */
  .arch-diagram {
    border: 1px solid var(--border);
    border-radius: 16px;
    overflow: hidden;
    background: var(--card);
  }
  .arch-layer {
    padding: 1.25rem 1.75rem;
    border-bottom: 1px solid var(--border);
    display: flex;
    align-items: center;
    gap: 1.5rem;
    transition: background 0.3s;
  }
  .arch-layer:last-child { border-bottom: none; }
  .arch-layer:hover { background: var(--bg3); }
  .arch-layer-label {
    font-family: 'JetBrains Mono', monospace;
    font-size: 10px;
    letter-spacing: 0.15em;
    text-transform: uppercase;
    min-width: 90px;
    padding: 4px 10px;
    border-radius: 6px;
    text-align: center;
    font-weight: 500;
  }
  .arch-layer-content { flex: 1; }
  .arch-layer-title { font-size: 0.9rem; font-weight: 500; margin-bottom: 0.25rem; }
  .arch-layer-items { font-size: 0.8rem; color: var(--muted); }
  .arch-arrow {
    text-align: center;
    padding: 0.5rem;
    color: var(--hint);
    font-size: 1.2rem;
  }
  /* ── DATA TABLE ── */
  .data-table {
    width: 100%; border-collapse: collapse;
    border: 1px solid var(--border);
    border-radius: 12px;
    overflow: hidden;
  }
  .data-table th {
    background: var(--bg3);
    padding: 0.75rem 1.25rem;
    text-align: left;
    font-size: 0.75rem;
    font-family: 'JetBrains Mono', monospace;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    color: var(--hint);
    font-weight: 400;
    border-bottom: 1px solid var(--border);
  }
  .data-table td {
    padding: 0.9rem 1.25rem;
    font-size: 0.875rem;
    border-bottom: 1px solid var(--border);
    vertical-align: middle;
  }
  .data-table tr:last-child td { border-bottom: none; }
  .data-table tr:hover td { background: var(--bg3); }
  .cap-bar-bg { background: var(--bg3); border-radius: 100px; height: 6px; width: 120px; overflow: hidden; }
  .cap-bar { height: 100%; border-radius: 100px; }
  /* ── PRIVACY BLOCK ── */
  .privacy-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px; }
  .privacy-item {
    display: flex; align-items: flex-start; gap: 12px;
    padding: 1rem 1.25rem;
    border: 1px solid var(--border);
    border-radius: 12px;
    background: var(--card);
    transition: border-color 0.3s;
  }
  .privacy-item:hover { border-color: var(--border2); }
  .privacy-check {
    width: 22px; height: 22px; border-radius: 50%;
    background: rgba(52, 211, 153, 0.15);
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
    margin-top: 2px;
  }
  .privacy-check svg { width: 12px; height: 12px; }
  .privacy-text { font-size: 0.85rem; color: var(--text); line-height: 1.5; }
  .privacy-sub { font-size: 0.78rem; color: var(--muted); }
  /* ── ROADMAP ── */
  .roadmap-list { list-style: none; display: flex; flex-direction: column; gap: 12px; }
  .roadmap-item {
    display: flex; align-items: center; gap: 14px;
    padding: 1rem 1.25rem;
    border: 1px solid var(--border);
    border-radius: 12px;
    background: var(--card);
    font-size: 0.875rem;
    transition: all 0.3s;
  }
  .roadmap-item:hover { border-color: var(--border2); transform: translateX(4px); }
  .roadmap-dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
  /* ── STACK PILLS ── */
  .stack-grid { display: flex; flex-wrap: wrap; gap: 10px; }
  .stack-pill {
    display: flex; align-items: center; gap: 8px;
    padding: 8px 16px;
    border: 1px solid var(--border2);
    border-radius: 100px;
    font-size: 0.82rem;
    background: var(--card);
    font-family: 'JetBrains Mono', monospace;
    transition: border-color 0.3s;
  }
  .stack-pill:hover { border-color: var(--accent); }
  /* ── QUOTE ── */
  .quote-block {
    border-left: 2px solid var(--accent);
    padding: 1.25rem 1.75rem;
    background: var(--card);
    border-radius: 0 12px 12px 0;
    font-family: 'DM Serif Display', serif;
    font-style: italic;
    font-size: 1.15rem;
    color: var(--muted);
    line-height: 1.6;
    margin: 2rem 0;
  }
  /* ── FOLDER TREE ── */
  .folder-tree {
    font-family: 'JetBrains Mono', monospace;
    font-size: 0.8rem;
    line-height: 1.9;
    color: var(--muted);
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: 14px;
    padding: 1.75rem;
    overflow-x: auto;
  }
  .folder-tree .dir { color: var(--accent); font-weight: 500; }
  .folder-tree .file { color: var(--text); }
  .folder-tree .comment { color: var(--hint); }
  /* ── FOOTER ── */
  .footer {
    text-align: center;
    padding: 4rem 2rem 5rem;
    border-top: 1px solid var(--border);
  }
  .footer-logo { font-family: 'DM Serif Display', serif; font-size: 2.5rem; margin-bottom: 0.5rem; background: linear-gradient(135deg, #e0d7ff, #f0a9d8); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
  .footer-sub { color: var(--hint); font-size: 0.85rem; }
  /* ── SCROLL REVEAL ── */
  .reveal { opacity: 0; transform: translateY(32px); transition: opacity 0.7s ease, transform 0.7s ease; }
  .reveal.visible { opacity: 1; transform: translateY(0); }
  /* ── FLOATING PARTICLES ── */
  .particles { position: fixed; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; z-index: 0; overflow: hidden; }
  .particle { position: absolute; border-radius: 50%; animation: float linear infinite; }
  @keyframes float {
    0% { transform: translateY(100vh) scale(0); opacity: 0; }
    10% { opacity: 1; }
    90% { opacity: 1; }
    100% { transform: translateY(-10vh) scale(1); opacity: 0; }
  }
</style>
</head>
<body>

<div class="particles" id="particles"></div>

<!-- HERO -->
<div class="hero">
  <div class="hero-orb orb1"></div>
  <div class="hero-orb orb2"></div>
  <div class="hero-orb orb3"></div>
  <div class="hero-content">
    <div class="hero-pill"><span></span> iOS &amp; iPadOS · Swift 6 · Fully Offline</div>
    <div class="hero-logo">MoodNest</div>
    <div class="hero-tagline">Your emotional world, understood.</div>
    <div class="badges">
      <div class="badge"><div class="badge-dot bd-swift"></div><span class="b-swift">Swift 6.0</span></div>
      <div class="badge"><div class="badge-dot bd-swiftui"></div><span class="b-swiftui">SwiftUI</span></div>
      <div class="badge"><div class="badge-dot bd-ios"></div><span class="b-ios">iOS 16+</span></div>
      <div class="badge"><div class="badge-dot bd-privacy"></div><span class="b-privacy">Privacy First</span></div>
      <div class="badge"><div class="badge-dot bd-offline"></div><span class="b-offline">100% Offline</span></div>
    </div>
    <p class="hero-desc">
      MoodNest is a <strong>privacy-first emotional intelligence app</strong> that transforms daily inputs into meaningful insights through elegant design and on-device intelligence. No cloud. No tracking. Just you.
    </p>
  </div>
</div>

<hr class="divider"/>

<!-- WHAT IS IT -->
<section class="reveal">
  <div class="section-label">01 — Overview</div>
  <h2 class="section-title">Built for<br/>real human behavior.</h2>
  <p style="color: var(--muted); max-width: 620px; font-size: 0.95rem; margin-bottom: 1.5rem;">MoodNest gives users a quiet, friction-free space to log emotions, write journal entries, practice gratitude, and build self-care habits — then surfaces meaningful behavioral patterns through on-device intelligence.</p>
  <div class="quote-block">"Designing for emotional wellness means designing for the moments when people have the least capacity — so everything must be effortless."</div>
</section>

<hr class="divider"/>

<!-- FEATURES -->
<section class="reveal">
  <div class="section-label">02 — Features</div>
  <h2 class="section-title">Everything you need,<br/>nothing you don't.</h2>
  <div class="feature-grid">
    <div class="feature-card">
      <div class="feature-icon" style="background: rgba(167,139,250,0.15);">🟢</div>
      <div class="feature-title">Mood Tracking</div>
      <div class="feature-desc">Emoji + spectrum-based input. Streak calculation. Weekly analysis stored in EmotionalArchive.</div>
    </div>
    <div class="feature-card">
      <div class="feature-icon" style="background: rgba(244,114,182,0.15);">📓</div>
      <div class="feature-title">Journal System</div>
      <div class="feature-desc">Text journaling with on-device sentiment analysis via NaturalLanguage. Scores stored per entry.</div>
    </div>
    <div class="feature-card">
      <div class="feature-icon" style="background: rgba(52,211,153,0.15);">🙏</div>
      <div class="feature-title">Gratitude Module</div>
      <div class="feature-desc">Daily gratitude logging with lightweight entry and streak-based encouragement.</div>
    </div>
    <div class="feature-card">
      <div class="feature-icon" style="background: rgba(251,191,36,0.15);">🌿</div>
      <div class="feature-title">Self-Care Tracker</div>
      <div class="feature-desc">Predefined wellness actions, daily tracking, and streak-based motivation system.</div>
    </div>
    <div class="feature-card">
      <div class="feature-icon" style="background: rgba(14,165,233,0.15);">🧘</div>
      <div class="feature-title">Focus Mode</div>
      <div class="feature-desc">Timer sessions with AVAudioEngine ambient sound and breathing animations.</div>
    </div>
    <div class="feature-card">
      <div class="feature-icon" style="background: rgba(239,68,68,0.15);">📊</div>
      <div class="feature-title">Insights Engine</div>
      <div class="feature-desc">BehaviorEngine + PatternAnalyzer detect trends: improving / declining / stable.</div>
    </div>
    <div class="feature-card">
      <div class="feature-icon" style="background: rgba(167,139,250,0.15);">🧠</div>
      <div class="feature-title">Sentiment Analysis</div>
      <div class="feature-desc">Apple NaturalLanguage framework. Fully on-device. Zero external API calls ever.</div>
    </div>
    <div class="feature-card">
      <div class="feature-icon" style="background: rgba(52,211,153,0.15);">🔔</div>
      <div class="feature-title">Smart Reminders</div>
      <div class="feature-desc">Configurable daily reminders via UserNotifications. Gentle nudges, not interruptions.</div>
    </div>
  </div>
</section>

<hr class="divider"/>

<!-- ARCHITECTURE -->
<section class="reveal">
  <div class="section-label">03 — Architecture</div>
  <h2 class="section-title">MVVM, clean<br/>and layered.</h2>
  <div class="arch-diagram">
    <div class="arch-layer">
      <div class="arch-layer-label" style="background: rgba(167,139,250,0.15); color: #a78bfa;">View</div>
      <div class="arch-layer-content">
        <div class="arch-layer-title">View Layer</div>
        <div class="arch-layer-items">SwiftUI Views · Animations · No logic · Pure rendering</div>
      </div>
    </div>
    <div class="arch-arrow">↕</div>
    <div class="arch-layer">
      <div class="arch-layer-label" style="background: rgba(244,114,182,0.15); color: #f472b6;">ViewModel</div>
      <div class="arch-layer-content">
        <div class="arch-layer-title">ViewModel Layer</div>
        <div class="arch-layer-items">@StateObject / @ObservedObject · State management · Connects UI ↔ DataStores</div>
      </div>
    </div>
    <div class="arch-arrow">↕</div>
    <div class="arch-layer">
      <div class="arch-layer-label" style="background: rgba(52,211,153,0.15); color: #34d399;">Data</div>
      <div class="arch-layer-content">
        <div class="arch-layer-title">Data Layer</div>
        <div class="arch-layer-items">UserDefaults + JSON · Lazy caching · Entry caps · Corruption recovery</div>
      </div>
    </div>
    <div class="arch-arrow">↕</div>
    <div class="arch-layer">
      <div class="arch-layer-label" style="background: rgba(251,191,36,0.15); color: #fbbf24;">Core</div>
      <div class="arch-layer-content">
        <div class="arch-layer-title">Core Layer</div>
        <div class="arch-layer-items">SentimentAnalyzer · BehaviorEngine · PatternAnalyzer · Managers · Utilities</div>
      </div>
    </div>
  </div>
</section>

<hr class="divider"/>

<!-- FOLDER STRUCTURE -->
<section class="reveal">
  <div class="section-label">04 — Structure</div>
  <h2 class="section-title">Organized<br/>for scale.</h2>
  <div class="folder-tree">
<span class="dir">MoodNest/</span>
├── <span class="dir">App/</span>
│   └── <span class="file">MyApp.swift</span>                    <span class="comment">// entry point</span>
├── <span class="dir">Core/</span>
│   ├── <span class="dir">Managers/</span>
│   │   ├── <span class="file">NotificationManager.swift</span>  <span class="comment">// daily reminders</span>
│   │   ├── <span class="file">HapticManager.swift</span>        <span class="comment">// tactile feedback</span>
│   │   └── <span class="file">AmbientSoundPlayer.swift</span>   <span class="comment">// AVAudioEngine wrapper</span>
│   ├── <span class="dir">Services/</span>
│   │   ├── <span class="file">SentimentAnalyzer.swift</span>    <span class="comment">// NaturalLanguage</span>
│   │   ├── <span class="file">PatternAnalyzer.swift</span>      <span class="comment">// weekly trends</span>
│   │   └── <span class="file">BehaviorEngine.swift</span>       <span class="comment">// insight generation</span>
│   └── <span class="dir">Extensions/ · Utilities/</span>
├── <span class="dir">Data/</span>
│   ├── <span class="dir">Models/</span>
│   │   ├── <span class="file">MoodEntry.swift</span>
│   │   ├── <span class="file">JournalEntry.swift</span>
│   │   ├── <span class="file">GratitudeEntry.swift</span>
│   │   └── <span class="file">SelfCareEntry.swift</span>
│   └── <span class="dir">DataStores/</span>
│       ├── <span class="file">EmotionalArchive.swift</span>     <span class="comment">// cap: 900</span>
│       ├── <span class="file">JournalDataStore.swift</span>     <span class="comment">// cap: 1200</span>
│       ├── <span class="file">GratitudeDataStore.swift</span>   <span class="comment">// cap: 1000</span>
│       └── <span class="file">SelfCareDataStore.swift</span>    <span class="comment">// cap: 800</span>
├── <span class="dir">Features/</span>
│   ├── <span class="dir">Home/ · Journal/ · Gratitude/</span>
│   ├── <span class="dir">SelfCare/ · Focus/ · Awareness/</span>
│   └── <span class="dir">Stories/ · Profile/</span>
└── <span class="dir">Resources/JSON/</span>
    ├── <span class="file">DailyQuotes.json</span>
    ├── <span class="file">WellnessTips.json</span>
    ├── <span class="file">MiniGuides.json</span>
    └── <span class="file">DailyPrompts.json</span>
  </div>
</section>

<hr class="divider"/>

<!-- DATA TABLE -->
<section class="reveal">
  <div class="section-label">05 — Data Architecture</div>
  <h2 class="section-title">Lean storage,<br/>safe by design.</h2>
  <table class="data-table">
    <thead>
      <tr>
        <th>Store</th>
        <th>Cap</th>
        <th>Fill</th>
        <th>Backend</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td style="font-family: 'JetBrains Mono', monospace; font-size: 0.8rem; color: var(--accent);">EmotionalArchive</td>
        <td style="color: var(--text);">900 entries</td>
        <td><div class="cap-bar-bg"><div class="cap-bar" style="width: 75%; background: #a78bfa;"></div></div></td>
        <td style="color: var(--muted); font-size: 0.8rem;">UserDefaults + JSONEncoder</td>
      </tr>
      <tr>
        <td style="font-family: 'JetBrains Mono', monospace; font-size: 0.8rem; color: var(--accent2);">JournalDataStore</td>
        <td style="color: var(--text);">1200 entries</td>
        <td><div class="cap-bar-bg"><div class="cap-bar" style="width: 100%; background: #f472b6;"></div></div></td>
        <td style="color: var(--muted); font-size: 0.8rem;">UserDefaults + JSONEncoder</td>
      </tr>
      <tr>
        <td style="font-family: 'JetBrains Mono', monospace; font-size: 0.8rem; color: var(--accent3);">GratitudeDataStore</td>
        <td style="color: var(--text);">1000 entries</td>
        <td><div class="cap-bar-bg"><div class="cap-bar" style="width: 83%; background: #34d399;"></div></div></td>
        <td style="color: var(--muted); font-size: 0.8rem;">UserDefaults + JSONEncoder</td>
      </tr>
      <tr>
        <td style="font-family: 'JetBrains Mono', monospace; font-size: 0.8rem; color: var(--accent4);">SelfCareDataStore</td>
        <td style="color: var(--text);">800 entries</td>
        <td><div class="cap-bar-bg"><div class="cap-bar" style="width: 67%; background: #fbbf24;"></div></div></td>
        <td style="color: var(--muted); font-size: 0.8rem;">UserDefaults + JSONEncoder</td>
      </tr>
    </tbody>
  </table>
  <p style="margin-top: 1rem; font-size: 0.8rem; color: var(--hint);">No force unwraps. No try!. Lazy caching on all stores. Corruption recovery built into every decoder.</p>
</section>

<hr class="divider"/>

<!-- PRIVACY -->
<section class="reveal">
  <div class="section-label">06 — Privacy</div>
  <h2 class="section-title">Privacy isn't<br/>a feature here.</h2>
  <p style="color: var(--muted); font-size: 0.95rem; margin-bottom: 1.5rem; max-width: 560px;">It's the foundation everything else is built on. MoodNest's privacy stance is unconditional.</p>
  <div class="privacy-grid">
    <div class="privacy-item">
      <div class="privacy-check"><svg viewBox="0 0 12 12" fill="none"><path d="M2 6l3 3 5-5" stroke="#34d399" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg></div>
      <div><div class="privacy-text">Fully offline</div><div class="privacy-sub">Zero network requests, ever</div></div>
    </div>
    <div class="privacy-item">
      <div class="privacy-check"><svg viewBox="0 0 12 12" fill="none"><path d="M2 6l3 3 5-5" stroke="#34d399" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg></div>
      <div><div class="privacy-text">No external APIs</div><div class="privacy-sub">NaturalLanguage runs on-device</div></div>
    </div>
    <div class="privacy-item">
      <div class="privacy-check"><svg viewBox="0 0 12 12" fill="none"><path d="M2 6l3 3 5-5" stroke="#34d399" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg></div>
      <div><div class="privacy-text">No analytics SDKs</div><div class="privacy-sub">No Firebase, Mixpanel, etc.</div></div>
    </div>
    <div class="privacy-item">
      <div class="privacy-check"><svg viewBox="0 0 12 12" fill="none"><path d="M2 6l3 3 5-5" stroke="#34d399" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg></div>
      <div><div class="privacy-text">No account required</div><div class="privacy-sub">Open and start immediately</div></div>
    </div>
    <div class="privacy-item">
      <div class="privacy-check"><svg viewBox="0 0 12 12" fill="none"><path d="M2 6l3 3 5-5" stroke="#34d399" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg></div>
      <div><div class="privacy-text">No data collection</div><div class="privacy-sub">Nothing leaves your device</div></div>
    </div>
    <div class="privacy-item">
      <div class="privacy-check"><svg viewBox="0 0 12 12" fill="none"><path d="M2 6l3 3 5-5" stroke="#34d399" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg></div>
      <div><div class="privacy-text">On-device intelligence</div><div class="privacy-sub">All ML runs locally</div></div>
    </div>
  </div>
</section>

<hr class="divider"/>

<!-- TECH STACK -->
<section class="reveal">
  <div class="section-label">07 — Tech Stack</div>
  <h2 class="section-title">Powered by<br/>Apple's best.</h2>
  <div class="stack-grid">
    <div class="stack-pill"><span style="color: #f05138;">●</span> Swift 6.0</div>
    <div class="stack-pill"><span style="color: #007aff;">●</span> SwiftUI</div>
    <div class="stack-pill"><span style="color: #a78bfa;">●</span> NaturalLanguage</div>
    <div class="stack-pill"><span style="color: #fb923c;">●</span> AVAudioEngine</div>
    <div class="stack-pill"><span style="color: #34d399;">●</span> UserNotifications</div>
    <div class="stack-pill"><span style="color: #fbbf24;">●</span> UserDefaults</div>
    <div class="stack-pill"><span style="color: #f472b6;">●</span> MVVM</div>
    <div class="stack-pill"><span style="color: #38bdf8;">●</span> iOS 16+ / iPadOS</div>
    <div class="stack-pill"><span style="color: #a78bfa;">●</span> Swift Package Manager</div>
  </div>
</section>

<hr class="divider"/>

<!-- ROADMAP -->
<section class="reveal">
  <div class="section-label">08 — Roadmap</div>
  <h2 class="section-title">What comes<br/>next.</h2>
  <ul class="roadmap-list">
    <li class="roadmap-item"><div class="roadmap-dot" style="background: #a78bfa;"></div>Replace UserDefaults with file-based storage for larger datasets</li>
    <li class="roadmap-item"><div class="roadmap-dot" style="background: #f472b6;"></div>Reduce GPU load on decorative home screen animations</li>
    <li class="roadmap-item"><div class="roadmap-dot" style="background: #34d399;"></div>Expand BehaviorEngine with on-device CoreML model</li>
    <li class="roadmap-item"><div class="roadmap-dot" style="background: #fbbf24;"></div>Optional privacy-first iCloud sync — encrypted, opt-in only</li>
    <li class="roadmap-item"><div class="roadmap-dot" style="background: #38bdf8;"></div>Widget support for mood quick-log from home screen</li>
    <li class="roadmap-item"><div class="roadmap-dot" style="background: #fb923c;"></div>Broader behavioral recommendations from pattern history</li>
  </ul>
</section>

<!-- FOOTER -->
<footer class="footer">
  <div class="footer-logo">MoodNest</div>
  <p style="color: var(--muted); font-size: 0.9rem; margin-bottom: 0.5rem; font-family: 'DM Serif Display', serif; font-style: italic;">Built with care, curiosity, and a lot of Swift.</p>
  <p class="footer-sub">© Piyush · Piyush-072006-B · All rights reserved</p>
</footer>

<script>
  const canvas = document.getElementById('particles');
  const colors = ['#a78bfa','#f472b6','#34d399','#fbbf24','#38bdf8'];
  for (let i = 0; i < 28; i++) {
    const p = document.createElement('div');
    const size = Math.random() * 3 + 1;
    p.className = 'particle';
    p.style.cssText = `
      width: ${size}px; height: ${size}px;
      left: ${Math.random() * 100}%;
      background: ${colors[Math.floor(Math.random() * colors.length)]};
      opacity: ${Math.random() * 0.4 + 0.1};
      animation-duration: ${Math.random() * 20 + 15}s;
      animation-delay: ${Math.random() * 20}s;
    `;
    canvas.appendChild(p);
  }
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
  }, { threshold: 0.1 });
  document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
</script>
</body>
</html>
