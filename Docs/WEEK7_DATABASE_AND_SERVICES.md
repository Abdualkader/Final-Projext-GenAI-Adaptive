# WEEK 7 — FIREBASE DATABASE AND SERVICES IMPLEMENTATION REPORT

**Project:** GenAI Adaptive Learning Assistant for Children with Autism Spectrum Disorder (ASD)  
**Target Platform:** Flutter Web & Mobile (Android, iOS)  
**Evaluation Date:** October 2026  
**Status:** Completed & Validated (95/95 Tests Passing, 0 Analyzer Warnings)

---

## 1. Overview & Objectives

Week 7 implements the working Cloud Firestore and Firebase Storage data layer, transitioning the architecture from mock structures to live database operations while maintaining strict sensory safety and architectural boundaries.

The architecture enforces a strict unidirectional data flow:
```text
UI Layer (Widgets & Screens)
        ↓
State Management (ChangeNotifier Providers & UiState)
        ↓
Repository Layer (User, Category, Vocabulary, Session, Quiz, Progress)
        ↓
Service Layer (FirestoreService, StorageService, SampleDataService)
        ↓
Cloud Infrastructure (Cloud Firestore & Firebase Cloud Storage)
```

### Core Architecture Rules Enforced
1. **Clean Separation of Concerns:** Database queries and storage access logic are strictly prohibited inside UI widgets. UI components interact solely through Providers and Repositories.
2. **Sensory Safety &ASD Error Handling:** Technical database errors, network dropouts, and stack traces are captured by `FirestoreService` and translated into gentle, non-punitive notifications for children, or informative status messages for parents and educators.
3. **Data Privacy & Scoping:** Parent and educator queries are constrained to their authenticated account (`request.auth.uid`) and linked child IDs. Unrelated child profiles and session data are strictly inaccessible.
4. **Hermetic & Offline Resilience:** All repositories include in-memory state and fallback caching via `SampleDataService`, allowing continuous operation during offline conditions or hermetic unit testing without active Firebase instances.

---

## 2. Implemented Features & Architectural Verification

### 2.1 Task 1 — Architecture Inspection & Preservation
- Inspected all existing models (`UserModel`, `ChildModel`, `CategoryModel`, `VocabularyItemModel`, `LearningSessionModel`, `QuizResultModel`, `ProgressRecordModel`).
- Inspected repositories, providers, authentication flow, and Firebase configuration.
- Maintained clean dependency injection across services and repositories:
  - `FirestoreService({FirebaseFirestore? firestore})`
  - `StorageService({FirebaseStorage? storage})`
  - `BaseUserRepository({FirestoreService? firestoreService})`
  - `BaseCategoryRepository({FirestoreService? firestoreService})`
  - `BaseVocabularyRepository({FirestoreService? firestoreService})`
  - `BaseSessionRepository({FirestoreService? firestoreService})`
  - `BaseQuizRepository({FirestoreService? firestoreService})`
  - `BaseProgressRepository({FirestoreService? firestoreService})`

### 2.2 Task 2 — Firestore Collections
The database layer establishes standardized access to all required Firestore collections via `FirebaseCollections`:
- `users`: Parent/educator profiles.
- `children`: Student profiles linked to parents.
- `categories`: Foundational learning categories.
- `vocabularyItems`: Standardized vocabulary items and metadata.
- `sessions`: Learning session telemetry and duration tracking.
- `quizResults`: Individual question responses and trial results.
- `progressRecords`: Aggregated daily/weekly performance summaries.

### 2.3 Task 3 — User Repository (`BaseUserRepository`)
Implemented operations in `lib/repositories/user_repository.dart`:
- `getUserById(String userId)`: Retrieves user profile with fallback to local state.
- `saveUser(UserModel user)`: Persists user updates to Firestore `users/{userId}`.
- `updatePreferredLanguage(String userId, String language)`: Updates bilingual preference (`ar` or `en`).
- `getLinkedChildren(String parentId)`: Retrieves only child profiles linked to the given parent UID.
- `getLinkedChildIds(String parentId)`: Returns string array of authorized child IDs.
- `addChildProfile(String parentId, ChildModel child)`: Persists student document to `children/{childId}` and appends `childId` to the parent's `linkedChildIds`.

### 2.4 Task 4 — Category Repository (`BaseCategoryRepository`)
Implemented operations in `lib/repositories/category_repository.dart`:
- `getCategories()`: Queries `categories` ordered by `orderIndex`.
- `getCategoryById(String categoryId)`: Fetches an individual category by ID.
- `seedCategories(List<CategoryModel> categories)`: Seeds foundational categories to Firestore.
- Initial bilingual categories supported:
  1. **Letters** (*الحروف*) — `letters`
  2. **Numbers** (*الأرقام*) — `numbers`
  3. **Colors** (*الألوان*) — `colours`
  4. **Animals** (*الحيوانات*) — `animals`

### 2.5 Task 5 — Vocabulary Repository (`BaseVocabularyRepository`)
Implemented operations in `lib/repositories/vocabulary_repository.dart`:
- `getVocabularyItems({int? maxDifficulty})`: Retrieves vocabulary items with optional difficulty ceiling (levels 1–3).
- `getVocabularyForCategory(String categoryId, {int? maxDifficulty})`: Scoped category query.
- `getVocabularyItemById(String itemId)`: Retrieves a specific vocabulary item by identifier.
- `saveVocabularyItem(VocabularyItemModel item)`: Saves a flashcard to `vocabularyItems/{itemId}`.
- `seedVocabularyItems(List<VocabularyItemModel> items)`: Seeds batch items into Firestore.
- Database schema fields validated:
  - `itemId` / `id` (String)
  - `categoryId` (String)
  - `imageUrl` (String)
  - `audioUrlAr` (String)
  - `audioUrlEn` (String)
  - `labelAr` (String with diacritics / tashkeel)
  - `labelEn` (String)
  - `difficultyLevel` (int 1–3)

### 2.6 Task 6 — Firebase Storage Service (`StorageService`)
Implemented clean asset resolution in `lib/services/storage_service.dart`:
- `getVocabularyImageUrl(String path)`: Resolves images under `vocabulary/images/`.
- `getArabicAudioUrl(String path)`: Resolves pronunciation audio under `vocabulary/audio/ar/`.
- `getEnglishAudioUrl(String path)`: Resolves pronunciation audio under `vocabulary/audio/en/`.
- `getDownloadUrl(String fullStoragePath)`: Resolves storage references to HTTP download URLs via `Reference.getDownloadURL()`.
- Supports local/asset fallbacks (`assets/...` and `https://...`) for offline resilience.

### 2.7 Task 7 — Learning Sessions Repository (`BaseSessionRepository`)
Implemented telemetry recording in `lib/repositories/session_repository.dart`:
- `createSession(LearningSessionModel session)`: Writes new session to `sessions/{sessionId}`.
- `updateSession(LearningSessionModel session)`: Updates active session telemetry in real time.
- `completeSession(String sessionId, {required DateTime endTime, required double score})`: Finalizes session with end timestamp and score (0.0–1.0).
- `getSessionById(String sessionId)`: Fetches historical session by ID.
- `getRecentSessions(String childId, {int limit})`: Retrieves chronologically sorted sessions for a child.
- Preserves fields: `sessionId`, `childId`, `startTime`, `endTime`, `itemsPresented`, `score`.

### 2.8 Task 8 — Quiz Results Repository (`BaseQuizRepository`)
Implemented attempt tracking in `lib/repositories/quiz_repository.dart`:
- `recordQuizResult(QuizResultModel result)`: Stores attempt log to `quizResults/{resultId}`.
- `getQuizResultsForSession(String sessionId)`: Queries all questions attempted during a session.
- `getQuizResultsForChild(String childId)`: Queries historical attempts for analytics.
- `getQuizQuestionForCategory(String categoryId)`: Generates 3-option multiple choice trials.
- Stores: `resultId`, `sessionId`, `childId`, `questionId`, `childResponse`, `isCorrect`, `timestamp`.

### 2.9 Task 9 — Progress Repository (`BaseProgressRepository`)
Implemented progress logging and aggregation in `lib/repositories/progress_repository.dart`:
- `createProgressRecord(ProgressRecordModel record)`: Writes daily record to `progressRecords/{recordId}`.
- `updateProgressRecord(ProgressRecordModel record)`: Updates performance record.
- `getProgressByDate(String childId, DateTime date)`: Retrieves progress record for a specific date.
- `getProgressRecordsForChild(String childId)`: Retrieves chronological logs for trend analysis.
- `getProgressForChild(String childId)`: Aggregates records into dashboard-ready `StudentProgressModel`.
- Preserves fields: `itemsMastered`, `quizScores`, `overallAccuracy`.

### 2.10 Task 10 — Firestore Composite Indexes
Verified index declarations in `firestore.indexes.json`:
```json
{
  "indexes": [
    {
      "collectionGroup": "sessions",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "childId", "order": "ASCENDING" },
        { "fieldPath": "startTime", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "vocabularyItems",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "categoryId", "order": "ASCENDING" },
        { "fieldPath": "difficultyLevel", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "progressRecords",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "childId", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

### 2.11 Task 11 — Security Rules
Hardened and verified server-side security rules:
- **`firestore.rules`**:
  - `users`: Read/write allowed only when `request.auth.uid == userId`.
  - `children`: Read/write allowed only when `resource.data.parentId == request.auth.uid`.
  - `categories` & `vocabularyItems`: Read allowed to authenticated users; write restricted to staff/educator roles.
  - `sessions`, `quizResults`, `progressRecords`: Accessible only to parents/educators owning the linked child.
- **`storage.rules`**:
  - Educational assets (`vocabulary/images/**`, `vocabulary/audio/**`) readable by authenticated users.
  - Write operations strictly forbidden for non-admin/client users.

### 2.12 Task 12 — Error Handling & UI States
Implemented in `lib/core/errors/app_exceptions.dart` and `lib/core/errors/ui_state.dart`:
- Standardized lifecycle states: `UiState.loading()`, `UiState.success(data)`, `UiState.empty()`, `UiState.error(exception)`.
- Exception hierarchy:
  - `NetworkException`: Handles connection dropouts and Firebase unavailability.
  - `AuthException`: Handles credential and permission failures.
  - `NotFoundException`: Handles missing vocabulary, categories, or documents.
- ASD Dual Messaging:
  - `toChildFriendlyMessage(bool isArabic)`: Calming, non-punitive messaging (e.g., *"سحابة الإنترنت نائمة قليلاً، سنحاول معاً بعد لحظات ☁️"*).
  - `toParentMessage(bool isArabic)`: Technical/diagnostic messaging for adults.

### 2.13 Task 13 — Controlled Development Sample Data
Created `lib/services/sample_data_service.dart` with controlled datasets:
- **4 Categories**: Letters, Numbers, Colors, Animals.
- **16 Vocabulary Items**: 4 items per category with Arabic labels, transliterations, difficulty levels, and asset paths.
- **Test Accounts**:
  - Parent: `parent_test_01` (`parent@test.com`).
  - Children: `child_adam` (Age 6, ASD Level 1), `child_sarah` (Age 8, ASD Level 2), `child_omar` (Age 5, ASD Level 1).
- **Sample Telemetry**: `session_sample_01`, `quiz_sample_01`, `progress_sample_01`.
- `SampleDataService.seedAll(FirestoreService)`: Enables one-command database population.

### 2.14 Task 14 — Integration Test Verification
Verified full end-to-end flow:
```text
Login (Parent Account)
       ↓
User Profile (Loaded with linkedChildIds)
       ↓
Child Selection (Adam selected)
       ↓
Load Categories (Letters, Numbers, Colors, Animals)
       ↓
Load Vocabulary (Filtered by Category & Difficulty)
       ↓
Resolve Storage URLs (Images & Bilingual Audio)
```
Data is served dynamically from the Firebase repository layer rather than hardcoded UI state.

---

## 3. Test Verification Matrix

All tests execute cleanly without network timeouts or unhandled exceptions:

| Test Group | Tests | Result | Description |
|---|:---:|:---:|---|
| **Firestore Collections & Indexes** | 2 | PASSED | Verifies collection names and `firestore.indexes.json` composite indexes |
| **User Repository Operations** | 6 | PASSED | Verifies profile fetch, save, language update, child link scoping, and child additions |
| **Category Repository Operations** | 3 | PASSED | Verifies 4 core categories, bilingual labels, and Firestore batch seeding |
| **Vocabulary Repository Operations** | 4 | PASSED | Verifies vocabulary queries, difficulty filtering, single card fetch, and item persistence |
| **Storage Service & URL Resolution** | 4 | PASSED | Verifies image and bilingual audio path mappings and fallback URL resolution |
| **Session Repository Telemetry** | 2 | PASSED | Verifies session creation, live telemetry updates, completion recording, and child queries |
| **Quiz Results Attempt Logging** | 2 | PASSED | Verifies quiz trial recording, correctness flags, and 3-option question generation |
| **Progress Repository Aggregation** | 2 | PASSED | Verifies progress creation, retrieval by child/date, and dashboard model mapping |
| **Security Rules Verification** | 2 | PASSED | Verifies authenticated access constraints and unauthenticated blocking |
| **Error Handling & UI States** | 3 | PASSED | Verifies `UiState` transitions and ASD gentle vs. parent diagnostic messaging |
| **Sample Data & Integration Flow** | 2 | PASSED | Verifies controlled dataset structure and end-to-end User $\rightarrow$ Storage flow |
| **Regression: Existing Suites (Weeks 1–6)** | 63 | PASSED | Widget tests, navigation guards, audio, and authentication suites all pass |
| **TOTAL VERIFIED TESTS** | **95 / 95** | **PASSED** | **100% Pass Rate across entire project** |

### Static Analysis
```bash
$ dart analyze lib test
Analyzing lib, test...
No issues found!
```

---

## 4. Key Files Changed & Created

| File | Type | Description |
|---|---|---|
| `lib/core/constants/firebase_collections.dart` | Constants | Declares canonical collection names |
| `lib/services/firestore_service.dart` | Service | Cloud Firestore wrapper with DI, queries, and error mapping |
| `lib/services/storage_service.dart` | Service | Firebase Cloud Storage path and URL resolution service |
| `lib/services/sample_data_service.dart` | Service | Controlled development dataset and database seeding utility |
| `lib/repositories/user_repository.dart` | Repository | User and linked child profiles with offline fallback caching |
| `lib/repositories/category_repository.dart` | Repository | Bilingual category access and batch seeding |
| `lib/repositories/vocabulary_repository.dart` | Repository | Vocabulary flashcards with category and difficulty level filters |
| `lib/repositories/session_repository.dart` | Repository | Learning session telemetry and timestamp recording |
| `lib/repositories/quiz_repository.dart` | Repository | Question attempts, response correctness, and trial generation |
| `lib/repositories/progress_repository.dart` | Repository | Daily progress summaries and performance metric aggregation |
| `lib/models/quiz_result_model.dart` | Model | Added `childId` and `copyWith` method |
| `lib/models/progress_model.dart` | Model | Added `copyWith` method |
| `lib/screens/child/home_screen.dart` | UI | Dynamically binds category grid to `CategoryProvider` |
| `lib/screens/child/vocabulary_learning_screen.dart` | UI | Dynamically binds flashcards to `VocabularyProvider` |
| `firestore.indexes.json` | Firebase Config | Verified composite indexes for sessions, vocabulary, and progress |
| `firestore.rules` | Security | Hardened role-based access rules for Firestore collections |
| `storage.rules` | Security | Hardened access rules for Firebase Cloud Storage assets |
| `test/firebase_data_layer_test.dart` | Tests | 32 automated unit and integration tests for Week 7 data layer |

---

## 5. Scope Boundaries & Deferred Features

The following features are intentionally deferred to subsequent milestones per project specification:
- **Week 8 — Vocabulary Content:** Audio pronunciation playback engine, full vocabulary wordlists, high-resolution imagery.
- **Week 9 — Adaptive Learning:** Item Response Theory (IRT) difficulty adaptation and spaced repetition algorithms.
- **Week 10 — Interactive Quiz:** Dynamic quiz generation and positive sensory reinforcement engine.
- **Week 11 — Progress Dashboard:** Real-time progress analytics, trend graphs, and parent reporting exports.
- **Week 12 — Cloud Functions & GenAI:** Secure backend Cloud Functions for GenAI text/quiz generation following the Zero Key Exposure Rule.

---

## 6. Confirmation of Readiness for Week 8

The Firebase data layer is fully operational, verified, and adheres to the project's repository and security architecture. The project is confirmed **Ready for Week 8 — Vocabulary Content Implementation**.
