<div align="center">

<br/>

```
███╗   ███╗ ██████╗  ██████╗ ██████╗ ███╗   ██╗███████╗███████╗████████╗
████╗ ████║██╔═══██╗██╔═══██╗██╔══██╗████╗  ██║██╔════╝██╔════╝╚══██╔══╝
██╔████╔██║██║   ██║██║   ██║██║  ██║██╔██╗ ██║█████╗  ███████╗   ██║   
██║╚██╔╝██║██║   ██║██║   ██║██║  ██║██║╚██╗██║██╔══╝  ╚════██║   ██║   
██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██████╔╝██║ ╚████║███████╗███████║   ██║   
╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝   ╚═╝  
```

### *Your emotional world, understood.*

<br/>

![Swift](https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-✦-007AFF?style=for-the-badge&logo=apple&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-16%2B-000000?style=for-the-badge&logo=apple&logoColor=white)
![iPadOS](https://img.shields.io/badge/iPadOS-16%2B-000000?style=for-the-badge&logo=apple&logoColor=white)
![Privacy](https://img.shields.io/badge/Privacy-First-34C759?style=for-the-badge&logo=shield&logoColor=white)
![Offline](https://img.shields.io/badge/Fully-Offline-FF9500?style=for-the-badge)

<br/>

> **MoodNest** is a privacy-first emotional intelligence app that transforms how you understand yourself —  
> tracking moods, surfacing patterns, and guiding reflection entirely on-device. No cloud. No tracking. Just you.

<br/>

</div>

---

## ✦ What is MoodNest?

MoodNest is a human-centered iOS & iPadOS wellness app built entirely in **Swift 6 + SwiftUI**. It gives users a quiet, friction-free space to log emotions, write journal entries, practice gratitude, and build self-care habits — then surfaces meaningful behavioral patterns through on-device intelligence.

Everything runs locally. No accounts. No servers. No data leaving your device.

---

## ✦ Feature Overview

### 🟢 Mood Tracking
- Emoji-based and spectrum-based mood input for expressive logging
- Streak calculation to build consistent habits
- Weekly mood analysis with trend visualization
- All entries stored in `EmotionalArchive`

### 📓 Journal System
- Rich text journaling with per-entry **sentiment analysis** via Apple's `NaturalLanguage` framework
- Sentiment scores stored alongside entries for behavioral insights
- Fully on-device — zero API calls

### 🙏 Gratitude Module
- Daily gratitude logging with lightweight, low-friction entry
- Streak tracking to encourage consistency

### 🌿 Self-Care Tracker
- Predefined wellness actions with daily tracking
- Streak-based encouragement system

### 🧘 Focus Mode
- Timer-based focus sessions
- Ambient sound engine via `AVAudioEngine`
- Breathing animations with `Reduce Motion` compliance

### 📊 Insights & Analytics
- Weekly behavioral pattern detection
- `BehaviorEngine` + `PatternAnalyzer` core services
- Trend classification: **improving / declining / stable**
- AI-style reflection generation from entry history

### 🔔 Smart Reminders
- Configurable daily reminders via `UserNotifications`
- Gentle nudges, not intrusive alerts

---

## ✦ Architecture

MoodNest follows **MVVM** — a clean separation between UI, state, and data that scales gracefully as the app grows.

```
┌─────────────────────────────────────────────────────────┐
│                      VIEW LAYER                         │
│          SwiftUI Views · Animations · No Logic          │
└────────────────────────┬────────────────────────────────┘
                         │  @StateObject / @ObservedObject
┌────────────────────────▼────────────────────────────────┐
│                   VIEWMODEL LAYER                       │
│     State Management · User Interaction Handling        │
│         Connects UI ↔ DataStores                        │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│                     DATA LAYER                          │
│   UserDefaults + JSON Encoding · Lazy Caching           │
│   Entry Caps: Mood 900 · Journal 1200 · Gratitude 1000  │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│                     CORE LAYER                          │
│  SentimentAnalyzer · BehaviorEngine · PatternAnalyzer   │
│  NotificationManager · HapticManager · AmbientSound     │
└─────────────────────────────────────────────────────────┘
```

---

## ✦ Folder Structure

```
MoodNest/
│
├── App/
│   └── MyApp.swift                    # Entry point
│
├── Core/
│   ├── Managers/
│   │   ├── NotificationManager.swift  # Daily reminders
│   │   ├── HapticManager.swift        # Tactile feedback
│   │   ├── VoiceReaderManager.swift   # TTS utility
│   │   └── AmbientSoundPlayer.swift   # AVAudioEngine wrapper
│   │
│   ├── Services/
│   │   ├── SentimentAnalyzer.swift    # NaturalLanguage integration
│   │   ├── PatternAnalyzer.swift      # Weekly trend detection
│   │   └── BehaviorEngine.swift       # Insight generation
│   │
│   ├── Utilities/
│   │   ├── GreetingManager.swift
│   │   └── DateHelpers.swift
│   │
│   └── Extensions/
│       ├── Color+Extensions.swift
│       └── ViewModifiers.swift
│
├── Data/
│   ├── Models/
│   │   ├── MoodEntry.swift
│   │   ├── JournalEntry.swift
│   │   ├── GratitudeEntry.swift
│   │   └── SelfCareEntry.swift
│   │
│   └── DataStores/
│       ├── EmotionalArchive.swift     # Mood persistence
│       ├── JournalDataStore.swift
│       ├── GratitudeDataStore.swift
│       ├── SelfCareDataStore.swift
│       └── AchievementManager.swift
│
├── Features/
│   ├── Home/                          # SmartMoodBanner, LiveInsightCard, etc.
│   ├── Journal/
│   ├── Gratitude/
│   ├── SelfCare/
│   ├── Focus/
│   ├── Awareness/
│   ├── Stories/
│   └── Profile/
│
└── Resources/
    └── JSON/
        ├── DailyQuotes.json
        ├── WellnessTips.json
        ├── MiniGuides.json
        └── DailyPrompts.json
```

---

## ✦ Data Architecture

| Store | Capacity | Storage |
|---|---|---|
| `EmotionalArchive` (Moods) | 900 entries | UserDefaults + JSON |
| `JournalDataStore` | 1200 entries | UserDefaults + JSON |
| `GratitudeDataStore` | 1000 entries | UserDefaults + JSON |
| `SelfCareDataStore` | 800 entries | UserDefaults + JSON |

**Safety principles enforced throughout:**
- No `try!` or force unwraps (`!`) anywhere in the codebase
- Graceful fallback decoding for corrupted data
- Lazy caching to avoid redundant deserialisation
- Corruption recovery on every DataStore

---

## ✦ Performance Design

| Optimization | Details |
|---|---|
| `LazyVStack` | Home screen scrolling — views only rendered on demand |
| Controlled animations | `repeatForever` animations are scoped and throttled |
| Background effects | Decorative animations limited to Home — not app-wide |
| Entry caps | Prevent UserDefaults bloat over time |

**Known tradeoffs:**
- JSON in UserDefaults is acceptable at current scale; file-based storage planned for a future version
- Decorative background animations add GPU load — acceptable for the Home screen experience

---

## ✦ Privacy & Security

```
✅ Fully offline                 — zero network requests
✅ No external APIs              — NaturalLanguage runs on-device
✅ No analytics SDKs             — no Firebase, Mixpanel, or similar
✅ No data collection            — nothing leaves the device, ever
✅ No account required           — open the app and start
```

MoodNest's privacy stance isn't a feature — it's a foundation.

---

## ✦ Accessibility

- **Dynamic Type** — all text scales with system font size
- **Reduce Motion** — animations gracefully disabled when requested
- **High Contrast UI** — legible across accessibility display modes
- **Haptic Feedback** — tactile confirmation for key actions
- **Large Touch Targets** — comfortable interaction for all users

---

## ✦ Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 6.0 |
| UI Framework | SwiftUI |
| Intelligence | Apple NaturalLanguage |
| Audio | AVAudioEngine |
| Notifications | UserNotifications |
| Storage | UserDefaults + JSONEncoder/Decoder |
| Architecture | MVVM |
| Platform | iOS & iPadOS 16+ |

---

## ✦ Getting Started

### Requirements
- Xcode 16+ **or** Swift Playgrounds 4.5+
- iOS / iPadOS 16.0+
- Apple Developer account (for device deployment)

### Run Locally

```bash
git clone https://github.com/Piyush-072006-B/MoodNest-7.2F2.git
cd MoodNest-7.2F2
# Open Package.swift in Xcode or Swift Playgrounds
```

> No dependencies to install. No package manager setup. Just open and run.

---

## ✦ Roadmap

- [ ] Replace `UserDefaults` with file-based storage for larger datasets
- [ ] Reduce GPU load on decorative home screen animations
- [ ] Expand `BehaviorEngine` with on-device CoreML model
- [ ] Optional privacy-first iCloud sync (encrypted, opt-in)
- [ ] Broader behavioral recommendations from pattern history
- [ ] Widget support for mood quick-log from the home screen

---

## ✦ Key Learnings

Building MoodNest was as much about engineering as it was about understanding human behavior:

- Navigating **Swift 6 strict concurrency** and `@MainActor` propagation at scale
- Managing **AVFoundation lifecycle complexity** — audio session interruptions, route changes
- Designing **performance-aware animations** that delight without taxing the GPU
- Learning that great wellness apps are built around **human habit formation**, not just feature lists
- Scaling a SwiftUI architecture from prototype to a production-quality codebase

---

## ✦ License

This project is personal / educational. All rights reserved © Piyush — `Piyush-072006-B`.

---

<div align="center">

<br/>

*Built with care, curiosity, and a lot of Swift.*

**[⭐ Star this repo](https://github.com/Piyush-072006-B/MoodNest-7.2F2)** if MoodNest inspires you.

<br/>

</div>
