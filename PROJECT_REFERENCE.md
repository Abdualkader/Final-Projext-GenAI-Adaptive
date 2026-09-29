# Project Reference Specification

**Project Title:** GenAI Adaptive Learning Assistant for Children with Autism Spectrum Disorder (ASD)  
**Project Type:** University Graduation Project  
**Target Group:** Children with Autism Spectrum Disorder (ASD), Parents, and Educators  
**Primary Language Support:** Arabic (RTL) & English (LTR)  
**Architecture Model:** Three-Tier Architecture (Flutter Client → Firebase Cloud Functions / AI Services → Cloud Firestore & Storage)

---

## 1. Project Overview & Objective

The **GenAI Adaptive Learning Assistant** is a cross-platform mobile application built using Flutter designed to assist children with Autism Spectrum Disorder (ASD) in learning fundamental vocabulary. The application combines multi-sensory learning cues (visual images, auditory prompts, bilingual text) with adaptive difficulty and AI-powered exercise generation.

### Key Objectives
* Support foundational vocabulary learning across 4 core categories:
  * **Letters** (حروف)
  * **Numbers** (أرقام)
  * **Colors** (ألوان)
  * **Animals** (حيوانات)
* Maintain a predictable, calm, distraction-free environment tailored to neurodivergent sensory profiles.
* Implement closed-loop adaptive difficulty based on real-time child performance.
* Provide a parent/educator portal for authentication, child profile management, and progress monitoring.
* Keep the architecture modular, robust, realistic for graduation evaluation, and secure against credential exposure.

---

## 2. Technology Stack & Environment

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Frontend Framework** | Flutter (Dart) | Multi-platform client for Android / iOS |
| **Authentication** | Firebase Authentication | Email/Password, role-based access for parents/educators |
| **Database** | Cloud Firestore | NoSQL document database for user profiles, vocabulary, sessions, and analytics |
| **Asset Storage** | Firebase Cloud Storage | Media storage for high-quality SVG/PNG imagery and MP3/AAC audio files |
| **Backend / Middleware** | Firebase Cloud Functions | Node.js / TypeScript / Python serverless backend orchestration |
| **AI / NLP Integration** | Generative AI API (via Cloud Functions) | Dynamic quiz question generation, adaptive tuning; keys hidden behind Cloud Functions |
| **Dev Environment** | VS Code / Android Studio | Flutter SDK, Android Emulator, Git source control |

> [!IMPORTANT]
> **Zero Key Exposure Rule**: Private AI API keys must **never** be embedded in the Flutter client code or asset bundle. All AI requests are mediated by Firebase Cloud Functions.

---

## 3. System Architecture

```text
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│          Flutter Mobile Application (Dart)             │
│   (Child Mode: Calm UI/UX | Parent Mode: Dashboard)   │
└───────────────────────────┬────────────────────────────┘
                            │ HTTPS / Callable Functions / SDK
                            ▼
┌────────────────────────────────────────────────────────┐
│                Application Logic Layer                 │
│                 Firebase Cloud Functions               │
│  - Adaptive Difficulty Engine                          │
│  - AI Prompt Orchestration & Validation Gatekeeper     │
│  - Secure Aggregation & Session Scoring                │
└─────────────┬────────────────────────────┬─────────────┘
              │ Direct API Calls           │ Firestore SDK
              ▼                            ▼
┌──────────────────────────┐  ┌──────────────────────────┐
│      AI/NLP Services     │  │        Data Layer        │
│   (LLM / Exercise Gen)   │  │ Cloud Firestore (Docs)   │
│                          │  │ Firebase Storage (Media) │
└──────────────────────────┘  └──────────────────────────┘
```

---

## 4. Core Functional Requirements Matrix

| ID | Requirement Name | Description |
| :--- | :--- | :--- |
| **FR-01** | Multi-Sensory Content | Vocabulary presentation using simultaneous visual imagery, high-clarity voice audio, and text labels. |
| **FR-02** | Bilingualism | Complete localized interface and content in Arabic (native RTL) and English (LTR). |
| **FR-03** | Core Categories | Structured modules for Letters, Numbers, Colors, and Animals. |
| **FR-04** | Interactive Quizzes | 3-option image-word matching assessments with gentle error handling. |
| **FR-05** | Learning Progress Tracking | Capturing session start/end timestamps, items presented, response accuracy, and mastery rate. |
| **FR-06** | Adaptive Difficulty | Automatic level adjustment based on consecutive successes or struggle signals. |
| **FR-07** | Parent / Educator Portal | Secure view for child profile selection, historical accuracy trends, and session frequency. |
| **FR-08** | Positive Reinforcement | Calibrated visual celebration (gentle confetti/stars) and encouraging auditory affirmations. |
| **FR-09** | AI-Generated Exercises | Cloud Function generates novel, validated matching exercises when the child needs variety. |
| **FR-10** | Secure Authentication | Identity verification and child-profile linking for parents and educators. |

---

## 5. Cloud Firestore Database Schema

### Collection: `users`
Represents parents, educators, and user system profiles.
```typescript
interface UserDocument {
  userId: string;              // Firebase Auth UID
  role: 'parent' | 'educator'; // System role
  preferredLanguage: 'ar' | 'en';
  linkedChildIds: string[];    // Array of linked child profile IDs
  createdAt: Timestamp;
}
```

### Collection: `children`
Represents individual child profiles managed by parents/educators.
```typescript
interface ChildDocument {
  childId: string;
  parentId: string;
  name: string;
  birthDate?: Timestamp;
  currentDifficultyLevel: number; // e.g., 1 (Beginner), 2 (Intermediate), 3 (Advanced)
  preferredLanguage: 'ar' | 'en';
  createdAt: Timestamp;
}
```

### Collection: `categories`
Top-level learning divisions.
```typescript
interface CategoryDocument {
  categoryId: string;          // e.g., 'letters', 'numbers', 'colors', 'animals'
  nameAr: string;              // e.g., 'حيوانات'
  nameEn: string;              // e.g., 'Animals'
  iconUrl: string;             // Asset or storage URL
  orderIndex: number;          // Display sequence
}
```

### Collection: `vocabularyItems`
Individual learning cards and assets.
```typescript
interface VocabularyItemDocument {
  itemId: string;
  categoryId: string;          // Foreign key -> categories.categoryId
  imageUrl: string;            // Cloud Storage HTTPS URL or local asset key
  audioUrlAr: string;          // Arabic pronunciation audio URL
  audioUrlEn: string;          // English pronunciation audio URL
  labelAr: string;             // e.g., 'قطة'
  labelEn: string;             // e.g., 'Cat'
  difficultyLevel: number;     // 1, 2, or 3
}
```

### Collection: `sessions`
Learning session telemetry.
```typescript
interface SessionDocument {
  sessionId: string;
  childId: string;             // Foreign key -> children.childId
  categoryId: string;          // Target category
  startTime: Timestamp;
  endTime: Timestamp;
  itemsPresented: string[];    // Array of itemId strings
  score: number;               // Normalized score or count
}
```

### Collection: `quizResults`
Granular per-question attempt logs.
```typescript
interface QuizResultDocument {
  resultId: string;
  sessionId: string;           // Foreign key -> sessions.sessionId
  questionId: string;
  childResponse: string;       // Chosen itemId or label
  isCorrect: boolean;
  responseTimeMs?: number;
  timestamp: Timestamp;
}
```

### Collection: `progressRecords`
Aggregated daily/weekly performance analytics.
```typescript
interface ProgressRecordDocument {
  recordId: string;
  childId: string;
  date: Timestamp;             // YYYY-MM-DD normalized
  itemsMastered: string[];     // Array of itemIds meeting mastery threshold
  quizScores: number[];        // List of percentages from quizzes taken today
  overallAccuracy: number;     // Cumulative accuracy (0.0 - 1.0)
}
```

### Required Firestore Composite Indexes
```yaml
indexes:
  - collectionGroup: "sessions"
    queryScope: "COLLECTION"
    fields:
      - fieldPath: "childId"
        order: "ASCENDING"
      - fieldPath: "startTime"
        order: "DESCENDING"

  - collectionGroup: "vocabularyItems"
    queryScope: "COLLECTION"
    fields:
      - fieldPath: "categoryId"
        order: "ASCENDING"
      - fieldPath: "difficultyLevel"
        order: "ASCENDING"

  - collectionGroup: "progressRecords"
    queryScope: "COLLECTION"
    fields:
      - fieldPath: "childId"
        order: "ASCENDING"
      - fieldPath: "date"
        order: "DESCENDING"
```

---

## 6. Application Screen Architecture

```text
App Entry / SplashScreen
  │
  ├──► [Parent/Educator Flow]
  │      ├── Login / Registration Screen
  │      ├── Child Selection / Management Screen
  │      ├── Progress Dashboard Screen (Charts, Accuracy, Filter by Date/Category)
  │      └── Settings Screen (Language, Audio preferences, Session limits)
  │
  └──► [Child Flow]
         ├── Child Home Screen (Calm grid with Letters, Numbers, Colors, Animals)
         ├── Category Content Screen
         ├── Vocabulary Learning Screen (Single Item: Image + Bilingual Labels + Audio Speaker)
         ├── Interactive Quiz Screen (Question prompt + 3 Image cards)
         └── Reinforcement & Reward Screen (Gentle celebration + Return to home/next)
```

---

## 7. Child-Friendly ASD UI/UX Principles

1. **Sensory Regulation**:
   * Use soft, muted color palettes (warm pastels, soft blues, gentle greens).
   * Avoid flashing lights, harsh strobe transitions, red alert boxes, and abrupt alarm buzzers.
2. **Predictable Layouts**:
   * Consistent button placement across all learning cards (Back is always top-left/RTL top-right, Next is bottom-right).
   * Clear visual affordances with rounded, soft-corner containers.
3. **Accessibility & Motor Skills**:
   * Minimum touch target size: **48 × 48 dp** (recommend 64 × 64 dp for primary actions).
   * High contrast ratio between text labels and backgrounds without aggressive pure-black on pure-white harshness.
4. **Cognitive Load & Pacing**:
   * Maximum single lesson segment: **~5 minutes** to prevent fatigue and sensory overload.
   * One focal item at a time on screen during learning mode.
5. **Gentle Feedback Mechanism**:
   * **Correct Answer:** Soft chime, warm praise ("ممتاز / Good job!"), mild visual celebration.
   * **Incorrect Answer:** No harsh buzzing, no red screens. Gentle neutral chime, soft nudge ("حاول مرة أخرى / Let's try again!"), and elimination of the incorrect option.

---

## 8. Bilingual & RTL/LTR System Architecture

* **Framework**: Flutter `flutter_localizations` with `.arb` files or unified translation dictionaries.
* **Bi-directional Layout**:
  * English uses `TextDirection.ltr`.
  * Arabic uses `TextDirection.rtl`.
  * Widgets leverage `Directionality.of(context)` and alignment properties (`AlignmentDirectional.start`, `EdgeInsetsDirectional`).
* **Content Dual-Storage**: Every vocabulary item document contains both `labelAr`, `labelEn`, `audioUrlAr`, and `audioUrlEn`. The child can toggle or listen to both.

---

## 9. Core Use Case Flows

### UC-01: Vocabulary Learning Flow
```text
Child launches app
  ↓
Selects Category (e.g., Animals)
  ↓
System queries vocabularyItems WHERE categoryId == 'animals' AND difficultyLevel <= childLevel
  ↓
Display first item: Image + Arabic Label + English Label
  ↓
Audio automatically plays native pronunciation (or child taps audio button)
  ↓
Child taps "Next" (or automatic transition after delay)
  ↓
Cycle through 5-item batch
  ↓
Record Session telemetry to Firestore
  ↓
Update Child Progress metrics
```

### UC-02: Interactive Quiz Flow
```text
System prepares 3-option multiple choice question
  ↓
Display audio prompt / text prompt: "أين القطة؟ / Where is the Cat?"
  ↓
Display 3 distinct image cards (1 target, 2 distractors from same category)
  ↓
Child taps card
  ├── Correct:
  │     ├── Play encouraging sound + star animation
  │     ├── Log isCorrect: true to quizResults
  │     └── Increment consecutive correct streak (triggers difficulty upgrade if threshold reached)
  └── Incorrect:
        ├── Play soft neutral sound
        ├── Disable or fade incorrect card
        ├── Child allowed second attempt
        └── Log isCorrect: false to quizResults
  ↓
Complete Quiz Session (3 to 5 questions)
  ↓
Show Reinforcement / Reward Screen
```

---

## 10. AI Integration, Validation & Fallback Safeguards

```text
[Flutter Client] ────(Callable Function: generateAdaptiveQuiz)────► [Firebase Cloud Function]
                                                                            │
                                                                 ┌──────────┴──────────┐
                                                                 │                     │
                                                         [Call AI API]           [On Error/Timeout]
                                                                 │                     │
                                                         [Validate JSON]               │
                                                                 │                     │
                                                          Valid? ├── Yes ────────► [Return AI Quiz]
                                                                 └── No  ────────► [Load Local Fallback]
```

* **Responsibilities of Cloud Function**:
  1. Inspect child's recent `quizResults` to find weak vocabulary items.
  2. Synthesize prompt: *"Generate a 3-option vocabulary identification exercise for level X focused on items [cat, dog] with distractors from category Animals."*
  3. Validate LLM JSON output against strict schema (ensures valid item IDs, clean labels, age-appropriate text).
  4. If AI API throttles, fails, or outputs invalid JSON, automatically return deterministic curated fallback questions from Firestore.

---

## 11. Project Directory Structure

```text
lib/
├── core/
│   ├── constants/            # App colors, asset paths, dimensions
│   ├── theme/                # Theme data (ASD-calm palette, typography)
│   ├── localization/         # AppLocalizations, AR/EN delegates
│   └── utils/                # Audio helper, date formatters, validators
│
├── models/                   # Data classes (User, Child, Category, VocabItem, Session, QuizResult)
│
├── services/                 # Hardware/External services (AudioPlayerService, FirebaseService, AIService)
│
├── repositories/             # Data abstraction layer (AuthRepo, VocabRepo, SessionRepo, ProgressRepo)
│
├── providers/                # State management (AuthProvider, ChildProvider, LearningProvider, QuizProvider)
│
├── screens/
│   ├── auth/                 # LoginScreen, RegisterScreen
│   ├── child/                # ChildHomeScreen, CategoryScreen
│   ├── learning/             # VocabularyLearningScreen
│   ├── quiz/                 # QuizScreen, ReinforcementScreen
│   ├── parent/               # ParentDashboardScreen, ChildSelectionScreen
│   └── settings/             # SettingsScreen
│
├── widgets/                  # Reusable UI components (CalmButton, ImageCard, SoundButton, StarDisplay)
│
└── main.dart                 # App bootstrap and Firebase initialization
```

---

## 12. 16-Week Implementation Roadmap

```text
W1: Environment Setup ───────────► Flutter SDK, Dart, Android Emulator, Git, Base Project
W2: Cloud & Backend Setup ──────► Firebase Auth, Firestore, Cloud Functions, AI Env
W3: UI/UX & Architecture ────────► Calm Theme, Localization (AR/EN), RTL/LTR, Routing
W4: Main UI Scaffolding ─────────► Child Home, Categories, Learning View, Parent Screens
W5: Core Data & Providers ───────► Models, Repositories, State Management, Error Handling
W6: Authentication & Security ───► Parent Login, Child Profiles, Protected Routing
W7: Firebase Data Layer ─────────► Firestore Repositories, Security Rules, Storage Service
W8: Vocabulary Content ──────────► Seed 4 Categories, Audio/Image Assets, Difficulty levels
W9: Vocabulary Learning Engine ──► Audio Playback, Card Switching, Session Logging
W10: Interactive Quiz Module ────► 3-Option Matcher, Soft Feedback, Score Recording
W11: Progress & Analytics ───────► Dashboard Visualizations, Trend Charts, Mastery Calculator
W12: GenAI & Adaptive Engine ────► Cloud Functions AI Proxy, Strict Validator, Fallback Banks
W13: System Integration ─────────► End-to-End Client-to-Cloud Integration & Flow Testing
W14: Quality & Usability Tests ──► Bilingual Verification, ASD Sensory Audit, Stress Tests
W15: Bug Fixing & Performance ───► Memory optimization, Offline Audio Caching, Polish
W16: Final Release & Defense ────► Final Builds, Demonstration Script, Documentation
```

---

## 13. Weekly Development Workflow

For every assigned week:
1. **Inspect**: Review current workspace status and prior week deliverables.
2. **Plan**: Define exact files and functions within that week's designated scope.
3. **Implement**: Write clean, modular, documented code adhering strictly to the architecture.
4. **Test**: Compile and verify changes to ensure zero breaking regressions.
5. **Fix**: Rectify compilation, typing, or runtime defects immediately.
6. **Verify**: Ensure the application remains runnable and consistent.
7. **Document**: Report completed items, files modified/created, tests performed, remaining items, and next week's focus.
