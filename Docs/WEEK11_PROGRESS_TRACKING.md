# WEEK 11 — PROGRESS TRACKING SYSTEM REPORT

**Project:** GenAI Adaptive Learning Assistant for Children with Autism Spectrum Disorder (ASD)  
**Milestone:** Week 11 — Progress Tracking System  
**Status:** Completed & Fully Tested (151/151 Tests Passing)

---

## 1. Executive Summary

In Week 11, we implemented the complete, production-ready progress-tracking system connecting the Parent/Educator Dashboard directly to live Firebase Firestore data (`sessions`, `quizResults`, and `progressRecords` collections). 

The system provides parents and educators with transparent, explainable analytics regarding their child's vocabulary acquisition, quiz performance, learning consistency, and progress trends across all four core learning categories (**Letters**, **Numbers**, **Colors**, **Animals**) in both **Arabic** and **English**.

### Key Accomplishments:
1. **Dynamic Quiz Accuracy Calculation (Task 3):** Calculated in real-time from recorded quiz response logs using the formula:
   $$\text{Accuracy} = \frac{\text{Correct Answers}}{\text{Total Answers}} \times 100$$
2. **Explainable Mastery Model (Task 4):** A deterministic, auditable rule categorizing vocabulary items as *Mastered* when a child achieves $\ge 2$ correct quiz responses, $\ge 75\%$ accuracy, or $\ge 2$ successful learning sessions ($\ge 70\%$ score).
3. **Session Frequency & Telemetry (Task 5):** Calculated total learning sessions, active weekly frequency, and chronological session logs.
4. **Progress Trends & Visual Analytics (Task 6):** Embedded category-by-category bar charts mapping mastery rates across Letters, Numbers, Colors, and Animals.
5. **Interactive Date & Category Filters (Task 8 & 9):** Flexible date range filtering (**All Time**, **Today**, **This Week**, **This Month**) and category domain filtering (**All Categories**, **Letters**, **Numbers**, **Colors**, **Animals**).
6. **ASD-Friendly Sensory Design & States (Task 10 & 11):** Non-punitive empty state ("*No learning activity yet. Start a learning session to see progress.*"), sensory-calm loading indicator, and gentle error states with retry capabilities.
7. **Security & Authorization Gate (Task 12):** Strict parent-child data isolation ensuring parents/educators can only access analytics for explicitly linked children.
8. **Firestore Query Performance & Indexing (Task 13):** Verified compound indexes (`sessions: childId ASC, startTime DESC` and `progressRecords: childId ASC, date DESC`).

---

## 2. Progress Calculation Methodology

Progress metrics are computed dynamically from Firestore collections without hardcoded statistics:

### A. Quiz Accuracy (Task 3)
- For any requested child profile and active filter period, all granular question attempts are retrieved from the `quizResults` collection.
- Formula:
  $$\text{Accuracy \%} = \left(\frac{\sum \text{isCorrect}}{\text{Total Quiz Attempts}}\right) \times 100$$
- If a child has completed learning sessions but no quiz assessments yet, accuracy falls back to the average session score:
  $$\text{Session Accuracy \%} = \left(\frac{\sum \text{Session Scores}}{\text{Total Sessions}}\right) \times 100$$
- If no records exist, accuracy defaults to `0%` (triggering the empty state).

### B. Mastered Vocabulary Rule (Task 4)
Rather than a "black-box" machine-learning model, Week 11 establishes a simple, transparent, and explainable rule designed for autism educators:
- **Condition 1 (Quiz Confidence):** The child answered the item correctly at least twice in quizzes.
- **Condition 2 (High Accuracy):** The child achieved $\ge 75\%$ accuracy on the item across attempts (with at least 1 correct response).
- **Condition 3 (Session Exposure):** The item appeared in $\ge 2$ completed vocabulary sessions with a session score $\ge 70\%$.
- Items meeting any of these criteria are recorded in `itemsMastered: List<String>`.
- Mastered items can be tapped in the dashboard to open a dialog showing all mastered vocabulary words.

### C. Session Frequency & Activity (Task 5)
- **Total Sessions:** Total count of completed learning sessions within the filtered timeframe.
- **Weekly Frequency:** Calculated as active sessions completed within the rolling 7-day window.
- **Recent Sessions:** Chronological list of the latest sessions displaying date, time, category icon, bilingual category label, score (e.g. `18 / 20`), and sensory-calm accuracy badge (green for $\ge 80\%$, warm amber for gentle encouragement).

---

## 3. Parent / Educator Dashboard Metrics (Task 7)

| Metric | Card / Widget | Source / Formula | Sensory Presentation |
|---|---|---|---|
| **Mastered Vocabulary** | `StatCard` (Green accent) | Count of mastered vocabulary items (`itemsMastered.length`) | Tap to view chips of all mastered words |
| **Quiz Accuracy** | `StatCard` (Primary Blue) | Overall correct quiz percentage | Calibrated percentage with encouraging subtitle |
| **Total Sessions** | `StatCard` (Purple accent) | Count of filtered sessions (`totalSessions`) | Cumulative session counter |
| **Session Frequency** | `StatCard` (Amber accent) | Sessions in rolling 7-day period (`weeklyFrequency/wk`) | Learning habit consistency metric |
| **Progress Trends** | `CategoryBarChart` | Category accuracy bars (0–100%) for Letters, Numbers, Colors, Animals | High-legibility vertical bar chart |
| **Recent Sessions** | `ListView` in Card | Recent learning session logs from `sessions` collection | Non-alarming status badges, score breakdown |

---

## 4. Date & Category Filtering (Tasks 8 & 9)

Parents and educators can filter the entire dashboard using interactive dropdown selectors matching Wireframe 3:

### Date Filter Options (Task 8)
- **All Time (`'all'`):** Aggregates the child's entire learning history since account creation.
- **Today (`'today'`):** Filters sessions and quiz answers where `timestamp >= start of today`.
- **This Week (`'week'`):** Filters activities from the last 7 calendar days.
- **This Month (`'month'`):** Filters activities from the last 30 calendar days (displays formatted date span, e.g., `May 1 – May 31, 2025`).

### Category Filter Options (Task 9)
- **All Categories (`'all'`):** Displays aggregated progress across all four learning domains.
- **Letters (`'letters'`):** Filters quiz attempts, mastered letters, and letter sessions.
- **Numbers (`'numbers'`):** Filters numbers-specific learning telemetry.
- **Colors (`'colors'`):** Filters color vocabulary cards and color quiz evaluations.
- **Animals (`'animals'`):** Filters animal recognition sessions and quiz questions.

When a filter is changed, `ProgressProvider` automatically re-queries the repositories and smoothly updates the metrics and session history.

---

## 5. UI States (Tasks 10 & 11)

The dashboard gracefully transitions through four distinct UI states:

1. **Loading State (`UiState.loading()`):**
   - Renders a sensory-calm `CircularProgressIndicator` with soft caption ("*Loading progress metrics...* / *جاري تحميل سجلات التقدم...*").
2. **Success State (`UiState.success()`):**
   - Displays student profile header, four core stat cards, interactive filter selectors, category bar chart, and recent sessions list.
3. **Empty State (`UiState.empty()` or `progress.isEmpty`):**
   - If a child has no learning history, displays a warm, non-punitive icon and clear message:
     > **No learning activity yet.**  
     > *Start a learning session to see progress.*  
     > `[ Start Learning Session ]`
   - Strictly avoids displaying fake or zero-confusing statistics.
4. **Error State (`UiState.error()`):**
   - If Firebase is unreachable or fails temporarily, the app displays a gentle message with a "Retry" button without crashing.

---

## 6. Security & Data Protection (Task 12)

Children's learning data and diagnostic progress records are strictly protected under parental data privacy principles:
- **Authorization Verification:** `ProgressProvider.loadProgress(childId, authProvider: auth)` validates that `childId` exists in `authProvider.currentUser.linkedChildIds`.
- **Access Denial:** If an unauthorized user attempts to view progress for an unlinked child ID, the provider denies access and throws:
  ```dart
  AppException(
    code: 'ACCESS_DENIED',
    message: 'You are not authorized to view progress for this child profile.',
  )
  ```
- **Firestore Security Rules:** `firestore.rules` enforces that child documents and sub-collections are only accessible if `resource.data.parentId == request.auth.uid`.

---

## 7. Performance & Indexing (Task 13)

To ensure efficient queries without downloading entire historical collections, the Firestore compound indexes in `firestore.indexes.json` are utilized:
```json
{
  "collectionGroup": "sessions",
  "queryScope": "COLLECTION",
  "fields": [
    { "fieldPath": "childId", "order": "ASCENDING" },
    { "fieldPath": "startTime", "order": "DESCENDING" }
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
```

---

## 8. Verification & Test Results (Task 14)

A dedicated test suite was created in `test/progress_tracking_test.dart` alongside existing test suites:

| Test Case | Target Task | Description | Status |
|---|---|---|---|
| **Test 1** | Task 2 | `ProgressRecordModel` serialization and field verification | **PASSED** |
| **Test 2** | Task 3 | Quiz accuracy calculation: $\text{Correct} / \text{Total} \times 100$ | **PASSED** |
| **Test 3** | Task 4 | Mastered vocabulary rule identification based on quizzes & sessions | **PASSED** |
| **Test 4** | Task 5 | Session frequency, weekly activity, and chronological ordering | **PASSED** |
| **Test 5** | Task 8 & 9 | Date filtering ('today') and Category filtering ('numbers', 'animals') | **PASSED** |
| **Test 6** | Task 10 | New child with no history returns empty progress and zero stats | **PASSED** |
| **Test 7** | Task 12 | Security authorization gate rejects unlinked child requests | **PASSED** |
| **Test 8** | Task 10 & 11 UI | Dashboard renders empty state with friendly prompt and action button | **PASSED** |
| **Test 9** | Task 7, 8, 9 UI | Dashboard renders real metrics, filters, category bar chart, recent sessions | **PASSED** |
| **Test 10** | Localization | Bilingual Arabic RTL verification for dashboard and empty states | **PASSED** |
| **Regression** | All Weeks | Full test suite across Weeks 1–11 (151 tests) | **151/151 PASSED** |

---

## 9. Important Files Changed

1. **`lib/models/progress_model.dart`**
   - Enhanced `StudentProgressModel` with `itemsMastered`, `masteredCount`, `weeklyFrequency`, `activeCategoryFilter`, `activeDateFilter`, and `isEmpty` getter.
   - Added `StudentProgressModel.empty()` factory for clean zero-state handling.
2. **`lib/repositories/progress_repository.dart`**
   - Implemented real progress computation in `BaseProgressRepository` integrating `SessionRepository`, `QuizRepository`, `UserRepository`, and `VocabularyRepository`.
   - Added `getMasteredVocabulary()` and `calculateQuizAccuracy()`.
   - Added snapshot recording to `progressRecords` collection.
3. **`lib/providers/progress_provider.dart`**
   - Added date filtering (`setDateFilter`) and category filtering (`setCategoryFilter`).
   - Added security authorization check against `authProvider.currentUser.linkedChildIds`.
   - Added `UiState` transitions: `loading`, `success`, `empty`, `error`.
4. **`lib/screens/parent/progress_dashboard_screen.dart`**
   - Converted to reactive stateful widget with `ListenableBuilder` integration.
   - Added interactive date filter dropdown and category filter dropdown.
   - Added interactive Mastered Words modal bottom sheet.
   - Added empty state UI (Task 10) and sensory-safe error/loading states (Task 11).
   - Preserved fallback compatibility for standalone test wrappers.
5. **`lib/core/localization/app_localizations.dart`**
   - Added Arabic and English strings for date filters, empty states, and dialogs.
6. **`test/progress_tracking_test.dart`**
   - Comprehensive test suite covering all Week 11 acceptance criteria.

---

## 10. Remaining Functionality (Deferred to Week 12)

In strict adherence to the project instructions, the following capabilities were intentionally deferred:
- **AI-Generated Exercises:** Generative AI dynamic question prompts (belongs to Week 12).
- **Adaptive Difficulty Algorithm:** Dynamic adjustment of difficulty levels based on real-time learner telemetry (belongs to Week 12).
- **AI-Based Mastery Prediction:** Machine-learning probabilistic mastery models (belongs to Week 12).

---

## 11. Readiness for Week 12

**Confirmed:** The progress tracking system is fully operational and provides high-fidelity, auditable learning performance logs. The data collected in `sessions` and `quizResults` and aggregated in `progressRecords` provides the exact foundation required for the GenAI Adaptive Learning & Difficulty Adjustment engine in Week 12.
