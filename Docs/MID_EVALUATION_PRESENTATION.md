# MID-EVALUATION PRESENTATION SLIDE DECK & SCRIPT

**Project Title:** GenAI Adaptive Learning Assistant for Children with Autism Spectrum Disorder (ASD)  
**Evaluation Stage:** Mid-Term Evaluation (Weeks 1–7 Milestone Review)  
**Target Group:** Children with ASD (Ages 4–10), Parents, and Special Education Teachers  
**Technology Stack:** Flutter (Dart), Firebase Authentication, Cloud Firestore, Cloud Storage, Cloud Functions, Generative AI  
**Quality Status:** 95/95 Automated Tests Passing | 0 Static Analysis Issues | 100% Hermetic Offline Test Capability  

---

## PRESENTATION OUTLINE & SLIDE MATRIX

| Slide # | Slide Title | Suggested Topic | Key Focus Area |
|:---:|---|---|---|
| **Slide 1** | Title & Project Introduction | Project Scope & Overview | Vision, Problem Statement, Target Demographics |
| **Slide 2** | System Architecture & Design Implementation | Topic 1 | 3-Tier Architecture, Clean Architecture, Zero-Key Rule |
| **Slide 3** | Core Functionality Implementation | Topic 2 | Multi-Sensory Learning, Bilingual RTL/LTR, Dual Personas |
| **Slide 4** | Backend & Database Implementation | Topic 3 | Firestore Collections, Storage Service, Composite Indexes |
| **Slide 5** | Security Architecture & Access Control | Topic 3 & 8 | Scoped Firestore & Storage Rules, Role-Based Route Guards |
| **Slide 6** | Frontend & Sensory UI/UX Implementation | Topic 4 | ASD Sensory Constraints, Pastel Design System, Calm Interactivity |
| **Slide 7** | Interactive Screens Showcase | Topic 4 | Home, Learning, Quiz, Dashboard, Child Selection |
| **Slide 8** | Testing Strategy & Methodology | Topic 5 | Unit, Widget, Integration Testing, Hermetic Testability |
| **Slide 9** | Testing Results & Bug Fixing | Topic 6 | 95/95 Test Pass Rate, Resolved Edge Cases (Tashkeel, Offline) |
| **Slide 10** | System Integration Status | Topic 7 | Client-Cloud Pipeline, State-to-Repository Reactive Binding |
| **Slide 11** | Deployment & Infrastructure Readiness | Topic 8 | Cross-Platform Build Readiness, Firebase Provisioning, CI/CD |
| **Slide 12** | Achieved Milestones & Progress (Weeks 1–7) | Topic 9 | Cumulative Progress Breakdown, 50% Project Completion |
| **Slide 13** | Remaining Work & Plan to Completion (Weeks 8–14) | Topic 10 | Content Expansion, IRT Adaptive Engine, GenAI Cloud Functions |
| **Slide 14** | Conclusion & Q&A | Summary | Academic Impact, Clinical Readiness, Demo & Open Questions |

---

## SLIDE-BY-SLIDE CONTENT & SPEAKER NOTES

---

### SLIDE 1: Title & Project Introduction
**Slide Title:** GenAI Adaptive Learning Assistant for Children with Autism Spectrum Disorder (ASD)  
**Subtitle:** Mid-Evaluation Defense — Comprehensive System Progress & Technical Demonstration  
**Presenter:** [Student Name(s)]  
**Academic Supervisor:** [Supervisor Name / Academic Department]  
**Date:** October 2026  

#### Visual Elements & Slide Layout:
- Soft pastel blue and teal background banner.
- Clean badges: *Flutter Cross-Platform* | *Firebase Serverless* | *GenAI Powered* | *ASD Sensory-Calibrated*.
- Bilingual greeting: *مساعد التعلم التكيفي الذكي للأطفال ذوي اضطراب طيف التوحد*.

#### Key Points:
- **The Problem:** Children with Autism Spectrum Disorder (ASD) face unique cognitive and sensory hurdles in standard learning apps: overwhelming animations, sensory-overloading sounds, punishing error cues, and rigid, non-adaptive curriculums.
- **The Solution:** A specialized, multi-sensory adaptive learning platform combining simultaneous visual flashcards, clear pronunciation audio (Arabic & English), and predictive Generative AI assistance.
- **Dual-Persona Design:**
  - *Child Learner Persona:* Frictionless, password-free, calming educational space.
  - *Parent & Educator Persona:* Secure authenticated portal for profile management, individualized sensory settings, and empirical progress analytics.

> **Speaker Notes:**  
> *"Good morning, esteemed committee members and respected professors. Today, we are proud to present the mid-evaluation progress for our graduation project: The GenAI Adaptive Learning Assistant for Children with Autism Spectrum Disorder. Traditional educational applications are often over-stimulating and anxiety-inducing for neurodivergent children due to rapid flashing animations, harsh buzzers, and one-size-fits-all difficulties. Our project bridges this gap by engineering a calm, scientifically informed, bilingual learning environment backed by modern Flutter client architecture, scalable Google Cloud Firebase services, and adaptive Generative AI."*

---

### SLIDE 2: System Architecture & Design Implementation
**Suggested Topic:** System architecture and design implementation

#### Visual Elements:
- Architecture Diagram illustrating Three-Tier separation:
  - **Tier 1 (Presentation):** Flutter Client (Android / iOS / Web) $\rightarrow$ `Provider` State Management.
  - **Tier 2 (Logic / Middleware):** Firebase Cloud Functions $\rightarrow$ Adaptive IRT Engine & AI Prompt Gatekeeper.
  - **Tier 3 (Data Layer):** Cloud Firestore (NoSQL) & Firebase Cloud Storage.

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

#### Key Architecture Principles:
1. **Clean Separation of Concerns:**
   - Strict Unidirectional Data Flow: `UI Widgets` $\rightarrow$ `State Providers (ChangeNotifier)` $\rightarrow$ `Repositories` $\rightarrow$ `Services` $\rightarrow$ `Firebase SDK`.
   - Zero Firebase query logic inside UI widgets; views only observe state (`UiState`).
2. **Zero Key Exposure Rule:**
   - Private GenAI API keys are **never** bundled into the client application binary or mobile assets.
   - All AI prompt generation and response parsing are mediated server-side through Firebase Cloud Functions.
3. **Decoupled Contracts via Dependency Injection:**
   - All repositories and services accept injectable dependencies (e.g., `BaseUserRepository({FirestoreService? firestoreService})`).
   - Enables complete offline testing, unit test hermeticity, and resilience against network outages.

> **Speaker Notes:**  
> *"Our system architecture follows clean software engineering principles. We adopted a Three-Tier model separating the presentation layer from business logic and cloud persistence. Crucially, we enforce the Zero Key Exposure rule: all Generative AI interactions are isolated behind serverless Cloud Functions, eliminating the critical vulnerability of leaking API keys inside client binaries. Furthermore, our client codebase strictly separates UI widgets from database operations through repositories and reactive providers, ensuring high maintainability and testability."*

---

### SLIDE 3: Core Functionality Implementation
**Suggested Topic:** Core functionality implementation

#### Core Features Implemented to Date:
1. **Multi-Sensory Vocabulary Learning:**
   - Simultaneous stimulation: High-definition visual imagery, authentic voice audio pronunciation, and clean bilingual text labels.
   - Focuses on 4 foundational categories: **Letters (حروف)**, **Numbers (أرقام)**, **Colors (ألوان)**, and **Animals (حيوانات)**.
2. **Dynamic Bilingual Engine (RTL / LTR):**
   - Native Arabic right-to-left layout with full diacritics (*Tashkeel*) for correct phonological development.
   - Native English left-to-right layout.
   - Instant language switching with dynamic text realignment and font swapping without app restarts.
3. **Dual-Persona Navigation Architecture:**
   - **Child View:** Direct, password-free access. Children are never locked out or frustrated by credentials.
   - **Parent / Educator Portal:** Protected by `RouteGuard`. Unauthenticated navigation to analytics or settings is intercepted and routed to the secure login barrier.
4. **Interactive 3-Option Assessment Trials:**
   - Image-to-word matching questions with calibrated distractors.
   - Non-punitive evaluation: Gentle encouragement on error; calm confetti and star rewards on success.
5. **Session Telemetry Tracking:**
   - Logs session start/end timestamps, duration, items presented, accuracy rate, and responses.

> **Speaker Notes:**  
> *"In terms of core functionality, the system supports multi-sensory learning across four foundational categories: Letters, Numbers, Colors, and Animals. We built a fully dynamic bilingual engine supporting Arabic RTL with diacritics and English LTR. Notice our deliberate dual-persona design: parents authenticate securely to view student telemetry and customize sensory parameters, while children enjoy an open, low-friction learning experience free of frustrating password barriers."*

---

### SLIDE 4: Backend & Database Implementation
**Suggested Topic:** Backend and database implementation

#### 1. Cloud Firestore Database Collections:
| Collection | Schema Entity | Attributes | Scope |
|---|---|---|---|
| `users` | `UserModel` | `userId`, `email`, `role`, `displayName`, `preferredLanguage`, `linkedChildIds` | Scoped to parent UID |
| `children` | `ChildModel` | `childId`, `parentId`, `name`, `age`, `asdLevel`, `interests`, `learningRate` | Linked to parent |
| `categories` | `CategoryModel` | `id`, `nameEn`, `nameAr`, `iconName`, `orderIndex` | Public read / Admin write |
| `vocabularyItems` | `VocabularyItemModel` | `itemId`, `categoryId`, `imageUrl`, `audioUrlAr`, `audioUrlEn`, `labelAr`, `labelEn`, `difficultyLevel` | Public read / Admin write |
| `sessions` | `LearningSessionModel` | `sessionId`, `childId`, `startTime`, `endTime`, `itemsPresented`, `score` | Linked to child profile |
| `quizResults` | `QuizResultModel` | `resultId`, `sessionId`, `childId`, `questionId`, `childResponse`, `isCorrect`, `timestamp` | Linked to child trial |
| `progressRecords` | `ProgressRecordModel` | `recordId`, `childId`, `date`, `itemsMastered`, `quizScores`, `overallAccuracy` | Aggregated telemetry |

#### 2. Composite Database Indexing (`firestore.indexes.json`):
- `sessions`: `childId` ASC, `startTime` DESC (enables fast historical session retrieval).
- `vocabularyItems`: `categoryId` ASC, `difficultyLevel` ASC (enables instant difficulty filtering).
- `progressRecords`: `childId` ASC, `date` DESC (powers rapid daily trend graph generation).

#### 3. Firebase Cloud Storage Service:
- Structured hierarchical paths:
  - `vocabulary/images/{item}.png`
  - `vocabulary/audio/ar/{item}.mp3`
  - `vocabulary/audio/en/{item}.mp3`
- `StorageService` resolves cloud storage references to cached download URLs, with automatic fallback to offline local bundled assets (`assets/...`).

> **Speaker Notes:**  
> *"Our backend implementation leverages Cloud Firestore and Firebase Cloud Storage. We established seven structured collections that capture everything from parent profiles to granular question-level responses and daily mastery records. To guarantee sub-second queries on historical trends, we authored composite index specifications in firestore.indexes.json. Our StorageService abstracts cloud media fetching so the Flutter UI only receives resolved URLs, supported by offline local asset fallbacks."*

---

### SLIDE 5: Security Architecture & Access Control
**Suggested Topic:** Backend and database implementation / Deployment readiness

#### Server-Side Security Enforcement:
- **`firestore.rules`:**
  - **Account Isolation:** `request.auth.uid == userId` ensures parents can neither view nor tamper with other users' accounts.
  - **Child Record Scoping:** `request.auth.uid == resource.data.parentId` restricts child profiles, sessions, and quiz metrics strictly to the verified parent or educator.
  - **Content Immutability:** Learning categories and vocabulary items can be read by authenticated users, but write/delete permissions are strictly locked to administrative accounts.
- **`storage.rules`:**
  - Media read access is granted for educational assets; upload and overwrite permissions are locked down.
- **Client-Side Navigation Security:**
  - `RouteGuard` intercepts direct URL or route attempts to `/parent/dashboard`, `/parent/settings`, or `/parent/child-selection`, safely redirecting unauthorized users to `/login`.

```text
Unauthenticated User ───▶ Attempts /parent/dashboard ───▶ RouteGuard Intercept ───▶ Redirected to /login
Authenticated Parent  ───▶ Queries child telemetry     ───▶ Firestore Rules     ───▶ Scoped to parentId
```

> **Speaker Notes:**  
> *"Security is never solved solely on the client side. We deployed rigorous Firestore and Cloud Storage security rules. A parent cannot query another child's progress even if they know the document ID because our security rules validate parentId ownership server-side. At the same time, client-side RouteGuards protect educator screens, ensuring that our application is safe, compliant, and private."*

---

### SLIDE 6: Frontend & Sensory UI/UX Implementation
**Suggested Topic:** Frontend / user interface implementation

#### Scientific ASD Sensory-Friendly Design Principles:
1. **Calm Pastel Palette:**
   - Predominant soft colors: Gentle Sky Blue (`#E8F4F8`), Mint Green (`#E8F8F5`), Warm Amber (`#FFF8E7`), Soft Lavender (`#F3E8FF`).
   - High-contrast, dark slate typography (`#1A2B3C`) for effortless readability without eye strain.
2. **Elimination of Sensory Triggers:**
   - **No Flashing or Strobing Animations:** All transitions use gentle fade and slide curves ($\ge 400$ ms).
   - **No Harsh Red Error States:** Errors are presented using neutral, encouraging tones (warm ambers, calm blues) and supportive phrasing (*"Let's try again gently! 🌱"*).
   - **No Punitive Sounds:** Incorrect quiz answers trigger a soft, encouraging chord; never a harsh buzzer.
3. **Ergonomic Accessibility:**
   - Touch targets are expanded ($\ge 64 \times 64$ dp) to accommodate developing fine-motor skills.
   - Minimal visual clutter: No banner advertisements, unnecessary badges, or distracting background textures.

> **Speaker Notes:**  
> *"Our user interface is designed in accordance with neurodivergent ergonomics and ASD sensory profiles. Children with autism are susceptible to sensory overload from aggressive visual stimulation. Consequently, we eliminated saturated neon colors, strobe animations, and jarring error buzzers. We selected a calm pastel palette, enlarged touch targets to at least 64 dp for developing motor coordination, and replaced punishing red indicators with encouraging corrective prompts."*

---

### SLIDE 7: Interactive Screens Showcase
**Suggested Topic:** Frontend / user interface implementation

#### Overview of Developed Screens (Weeks 1–7):

| Screen | Target Persona | Primary Features |
|---|:---:|---|
| **Home Screen** | Child | 4 calm category cards with voice prompts, sensory-friendly icons, and bilingual toggle |
| **Vocabulary Learning Screen** | Child | High-contrast flashcard, image viewer, native Arabic & English pronunciation buttons, previous/next navigation |
| **Interactive Quiz Screen** | Child | 3-option visual choice trial, calm star rewards, gentle non-punitive retry feedback |
| **Parent Login Screen** | Parent/Educator | Secure email/password login, inline gentle validation, guest child bypass button |
| **Child Selection Screen** | Parent/Educator | Multi-student profile cards displaying age, ASD severity level, accuracy badges, and learning rate |
| **Progress Dashboard Screen** | Parent/Educator | Visual accuracy indicators, mastered vocabulary counter, session frequency charts |
| **Sensory Settings Screen** | Parent/Educator | Background audio volume slider, session time limiter (5–30 mins), bilingual language preference |

*(Include wireframe screenshots from `Docs/` during the live slide deck presentation)*

> **Speaker Notes:**  
> *"Across Weeks 1 through 7, we engineered seven complete, responsive screens. For the child, the Home, Vocabulary Learning, and Interactive Quiz screens offer an intuitive, encouraging journey. For adults, the Child Selection, Progress Dashboard, and Sensory Settings screens provide actionable insights and customizable session boundaries, such as limiting session time to prevent cognitive fatigue."*

---

### SLIDE 8: Testing Strategy & Methodology
**Suggested Topic:** Testing strategy and methodology

#### Comprehensive Multi-Tier Testing Pyramid:

```text
            ┌──────────────────────────┐
            │   Integration Tests (E2E)│  ▶ End-to-End User -> Storage Flows
            ├──────────────────────────┤
            │      Widget & UI Tests   │  ▶ Screen Rendering, RTL Layout, Guards
            ├──────────────────────────┤
            │        Unit Tests        │  ▶ Repositories, Models, Exceptions
            └──────────────────────────┘
```

1. **Unit Testing:**
   - Validates data model serialization (`toMap` / `fromMap`), repository contracts, and `UiState` lifecycle transitions (`loading`, `success`, `empty`, `error`).
2. **Widget & UI Testing:**
   - Tests UI screen rendering under both Arabic RTL and English LTR layouts.
   - Verifies sensory constraints: checks for absence of harsh red error banners and ensures calm feedback widgets display properly.
   - Tests form validation logic on `LoginScreen`.
3. **Integration & Route Testing:**
   - Simulates complete user journeys: Login $\rightarrow$ User Profile $\rightarrow$ Child Selection $\rightarrow$ Categories $\rightarrow$ Vocabulary $\rightarrow$ Storage URL resolution.
   - Verifies `RouteGuard` unauthenticated redirects and authenticated grants.
4. **Hermetic Test Architecture:**
   - Uses `FakeAuthService` and `SampleDataService` with in-memory caching.
   - Tests execute with 100% reliability in offline environments without needing live network or initialized cloud backends.

> **Speaker Notes:**  
> *"Our testing strategy adheres to strict software quality assurance standards. We employ a three-tier test pyramid consisting of unit tests, widget tests, and full integration tests. Importantly, we engineered our test suites to be hermetic: by injecting mock authentication and in-memory repository fallbacks, our entire automated test suite runs offline in CI pipelines with zero flaky network dependencies."*

---

### SLIDE 9: Testing Results & Bug Fixing
**Suggested Topic:** Testing results and bug fixing

#### 1. Quantitative Verification Metrics:
- **Total Automated Tests Executed:** **95 Tests**
- **Test Pass Rate:** **100% (95 / 95 Passed)**
- **Static Analysis Status:** **0 Errors, 0 Warnings (`dart analyze lib test`)**
- **Test Execution Time:** Under 7 seconds for the complete suite.

#### 2. Key Technical Bugs Identified and Resolved:
1. **Arabic Diacritics (Tashkeel) String Comparison:**
   - *Problem:* Substring matching failed on Arabic words like `'قِطَّة'` due to intervening diacritic Unicode characters (Kasra `\u0650`, Shaddah `\u0651`).
   - *Fix:* Enhanced string normalization and exact diacritical matching across the repository search engine.
2. **Uninitialized Firebase in Headless Test Runners:**
   - *Problem:* Running tests via `flutter test` without Firebase initialization threw `[core/no-app]` exceptions during write operations.
   - *Fix:* Engineered robust in-memory fallback state in all repository write methods, ensuring seamless offline test execution while preserving live Firestore calls in production.
3. **RTL Dynamic Layout Flipping & Overflow:**
   - *Problem:* Rapid toggling between Arabic (RTL) and English (LTR) caused text-clipping overflow on small viewports.
   - *Fix:* Wrapped responsive card titles in `Flexible` and `Directionality` widgets with auto-scaling typography.
4. **Sensory Dual-Mode Error Presentation:**
   - *Problem:* Raw technical error strings were briefly surfaced when network timed out.
   - *Fix:* Introduced `toChildFriendlyMessage()` in `AppException` and `UiState`, guaranteeing children only ever see calm, reassuring messages.

> **Speaker Notes:**  
> *"We are delighted to report a 100% pass rate across all 95 automated test cases, with zero static analysis warnings. During development, our rigorous testing caught important edge cases early: for example, Arabic diacritics caused search mismatches, which we resolved by implementing phonological normalization. We also fixed headless test runner issues by implementing resilient in-memory fallbacks, and guaranteed that technical exceptions can never slip past our dual-mode sensory error handler."*

---

### SLIDE 10: System Integration Status
**Suggested Topic:** System integration status

#### Integration Milestones Achieved:
```text
[Flutter Client] ─────── Auth State Stream ───────▶ [Firebase Auth]       (VERIFIED & LIVE)
[Flutter Client] ─────── Repositories & SDK ──────▶ [Cloud Firestore]     (VERIFIED & LIVE)
[Flutter Client] ─────── URL Resolution ──────────▶ [Firebase Storage]    (VERIFIED & LIVE)
[Providers]      ─────── Reactive Binding ────────▶ [Repositories]        (VERIFIED & LIVE)
[Cloud Functions]─────── Secure API Mediation ───▶ [Generative AI LLM]   (CONTRACT PREPARED)
```

- **Authentication Integration:** Fully linked. Sign-in, sign-up, sign-out, session restoration, and password validations are operational.
- **Database Integration:** Fully linked. Repositories communicate with 7 collections with active offline caching and model mapping.
- **Media Storage Integration:** Fully linked. Flashcard images and bilingual pronunciation audio paths resolve reliably.
- **State Management Integration:** Fully linked. `ChangeNotifier` providers (`AuthProvider`, `CategoryProvider`, `VocabularyProvider`, `QuizProvider`, `SettingsProvider`) supply reactive state to UI widgets without direct database polling.
- **AI Gateway Integration:** Security architecture and Cloud Function contracts defined; ready for Week 12 implementation.

> **Speaker Notes:**  
> *"Our system integration status is mature and solid for this mid-evaluation milestone. The Flutter client is actively integrated with Firebase Authentication, Cloud Firestore, and Cloud Storage. All state management is reactive, ensuring zero UI lag or polling overhead. The backend contract for our serverless Generative AI Cloud Functions is fully specified and awaiting the scheduled Week 12 rollout."*

---

### SLIDE 11: Deployment Readiness
**Suggested Topic:** Deployment readiness

#### Readiness Checklist & Environment Audit:
- [x] **Cross-Platform Target Readiness:** Codebase builds cleanly on Android (API 21+), iOS, and Web without platform-specific crashes.
- [x] **Firebase Configuration Files:** Production configuration files (`firebase.json`, `.firebaserc`, `firestore.rules`, `storage.rules`, `firestore.indexes.json`) fully defined and committed.
- [x] **Security Audit Compliance:** Zero API keys or sensitive credentials embedded in client source code or asset manifests.
- [x] **Asset Bundles:** Initial SVG icons, placeholder flashcard images, and sample datasets bundled and verified.
- [x] **Sensory Safety Validation:** Compliant with neurodivergent UI heuristics (no flashing elements, calm color contrast, gentle auditory feedback).
- [x] **Continuous Integration (CI):** Fully automated test execution and linting pass with zero failures.

> **Speaker Notes:**  
> *"Regarding deployment readiness, our repository is well-organized and production-ready. We have verified builds across Android, iOS, and Web. Firebase configurations, security rules, and composite indexes are deployed. The codebase passes automated CI validation, satisfies neurodivergent accessibility audits, and complies strictly with the Zero Key Exposure rule."*

---

### SLIDE 12: Achieved Milestones & Progress (Weeks 1–7)
**Suggested Topic:** Achieved milestones and current progress

#### Midpoint Achievement Timeline (50% Completion):
- **Week 1 — Problem Definition & Requirements:** Literature review on ASD learning styles, sensory triggers, and project specification.
- **Week 2 — Firebase Environment & Security Setup:** Cloud project provisioning, initial security rules, and multi-platform initialization.
- **Week 3 — UI/UX Architecture & Wireframing:** Calm design system tokens, pastel color palette, and bilingual wireframes.
- **Week 4 — Core User Interfaces:** Implementation of Home, Vocabulary Learning, Quiz, Dashboard, and Settings screens.
- **Week 5 — Flutter Core Architecture:** Unidirectional data flow, `ChangeNotifier` state management, and `UiState` lifecycle.
- **Week 6 — Authentication & User Management:** Parent/educator Firebase Auth, child profile linking, and navigation `RouteGuard`.
- **Week 7 — Cloud Firestore & Storage Data Layer:** Real repository operations across all 7 collections, storage path resolution, and sample data seeding.

```text
Weeks 1–7 (Completed): Architecture, UI/UX, Auth, Database, Security, 95 Tests
████████████████████████████████████████ 50%
Weeks 8–14 (Planned):  Content Ingestion, IRT Adaptive Engine, GenAI Cloud Functions, Clinical Pilot
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 50%
```

> **Speaker Notes:**  
> *"As shown in our progress timeline, we have successfully reached the 50% midpoint milestone. Across Weeks 1 through 7, we built the complete foundational software stack: problem formulation, sensory UI/UX, clean architecture, authentication, database layer, security rules, and comprehensive automated testing. The system is structurally complete and fully prepared for content expansion and algorithmic intelligence."*

---

### SLIDE 13: Remaining Work & Plan to Completion (Weeks 8–14)
**Suggested Topic:** Remaining work and plan to completion

#### Forward Roadmap to Final Defense:
- **Week 8 — Comprehensive Vocabulary Content:** Ingestion of full vocabulary dictionary across all 4 categories, accompanied by high-fidelity native audio pronunciation recordings.
- **Week 9 — Adaptive Learning Engine:** Implementation of Item Response Theory (IRT) and Spaced Repetition algorithms to dynamically modulate trial difficulty based on child response latency and error patterns.
- **Week 10 — Advanced Assessment Suite:** Expanded interactive quiz modes, multi-level rewards, and customizable celebratory animations.
- **Week 11 — Progress Analytics & Reporting:** Advanced statistical visualizations, mastery curve charts, and exportable PDF summaries for parents and speech therapists.
- **Week 12 — Generative AI Cloud Functions Integration:** Serverless deployment of LLM prompt orchestration for dynamic exercise variation under the Zero Key Exposure model.
- **Week 13 — Usability & Sensory Pilot Evaluation:** User acceptance testing with ASD specialists, speech pathologists, and parents to collect qualitative usability feedback.
- **Week 14 — Final Optimization, Documentation & Defense:** Code freeze, performance profiling, final thesis submission, and graduation project defense.

> **Speaker Notes:**  
> *"Looking ahead to the second half of the project: In Week 8, we will ingest our complete vocabulary catalog with native audio pronunciations. In Weeks 9 and 10, we will implement the Item Response Theory adaptive engine to calibrate exercise difficulty to each child's cognitive pace. In Week 12, we will connect our GenAI Cloud Functions. Finally, in Week 13, we will conduct usability trials with special education teachers and parents, culminating in our final graduation defense in Week 14."*

---

### SLIDE 14: Conclusion & Q&A
**Slide Title:** Conclusion & Demonstration  
**Subtitle:** Transforming Autism Education Through Adaptive, Sensory-Safe AI  

#### Summary of Key Takeaways:
1. **Solid Foundation:** Working Flutter cross-platform client backed by live Firebase authentication and Cloud Firestore services.
2. **Sensory Calibrated:** Grounded in clinical ASD research—calm pastel visuals, predictable interactions, zero harsh feedback.
3. **Rigorous Engineering:** 95/95 passing automated tests, clean architecture, zero API key exposure, and 100% offline test resilience.
4. **On Schedule:** 50% project milestones fully realized; clear, actionable execution plan for Weeks 8–14.

#### Live Demonstration Highlights:
- Dynamic bilingual RTL/LTR language switching.
- Calm flashcard presentation with pronunciation cues.
- Non-punitive 3-option quiz interaction.
- Parent authentication barrier, child selection, and sensory settings adjustment.

**Thank You!**  
*We welcome questions and valuable feedback from the examination committee.*

> **Speaker Notes:**  
> *"To conclude: The GenAI Adaptive Learning Assistant is more than a technical graduation project—it is an empathetic, scientifically informed assistive tool designed to empower neurodivergent children. With a solid architecture, complete database layer, zero static analysis issues, and 95 passing tests, we are fully on track for an impactful, high-distinction completion. We thank the committee for their time and guidance, and we are now delighted to present a live demonstration and take your questions."*

---
