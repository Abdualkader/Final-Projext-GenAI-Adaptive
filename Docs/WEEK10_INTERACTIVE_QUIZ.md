# WEEK 10 — INTERACTIVE QUIZ IMPLEMENTATION REPORT

**Project:** GenAI Adaptive Learning Assistant for Children with Autism Spectrum Disorder (ASD)  
**Target Platform:** Flutter Web & Mobile (Android, iOS)  
**Evaluation Date:** October 2026  
**Status:** Completed & Validated (14/14 Tests Passing, 0 Analyzer Warnings)

---

## 1. Executive Summary & Objectives

Week 10 implements the interactive quiz assessment system. The quiz presents a prompt and three image-based response options to evaluate learner retention and vocabulary comprehension without creating sensory anxiety or academic pressure:

```text
Quiz Session Initialization (Child Profile + Category ID)
      ↓
Question Prompt (Bilingual Audio + Large Typography)
      ↓
3 Image-Based Response Options (Randomized Positions)
      ↓
Child Selects Choice OR Peaceful 60s Timer Times Out
      ↓
Answer Evaluation
 ├─ Correct Answer: Positive Reinforcement (+3 Stars, Golden Chime, Visual Praise)
 ├─ Incorrect Answer: Gentle Correction (Preserves Stars, Soft Chime, Encouragement)
 └─ Timeout (60s): Soft Sound, Quiet Progression (No Harsh Buzzer, No Penalties)
      ↓
Log Granular Result to Cloud Firestore (`quizResults` Collection)
      ↓
Advance Question OR Transition to Celebratory Completion Screen
      ↓
Final Score Tally Recorded to Cloud Firestore (`sessions` Collection)
```

---

## 2. Implemented Features & Architecture

### 2.1 Task 2 & 8 — Quiz Session Management & Firestore Logging
- **`QuizProvider.startQuizSession()`**:
  - Associates assessment with `childId`, `categoryId`, and `sessionId`.
  - Records session creation to Firestore `sessions` via `SessionRepository`.
  - Persists each attempt into Firestore `quizResults` via `QuizRepository.recordQuizResult()`:
    - `resultId`: `result_{timestamp}`
    - `sessionId`: Associated quiz session
    - `childId`: Student profile
    - `questionId`: Active question identifier
    - `childResponse`: Selected choice ID or `'timeout'`
    - `isCorrect`: Boolean correctness flag
    - `responseTimeMs`: Millisecond latency tracking
    - `timestamp`: UTC DateTime

### 2.2 Task 3 — Quiz Question Model & Serialization
- Enhanced `QuizQuestionModel` (`lib/models/quiz_question_model.dart`):
  - `questionId`, `promptEn`, `promptAr`, `correctChoiceId`, `choices`, `categoryId`, `difficultyLevel`, and `targetItem`.
  - Full Firestore serialization: `toMap()` and `factory QuizQuestionModel.fromMap()`.
- Enhanced `QuizChoice`:
  - `id`, `labelEn`, `labelAr`, `imageUrl`, `icon`, `accentColor`, `vocabularyItem`.
  - Full serialization: `toMap()` and `fromMap()`.

### 2.3 Task 4, 11 & 12 — 3 Image-Based Options, Distractors & Randomization
- **Image Choice Cards (`QuizChoiceCard`)**:
  - Renders vocabulary illustrations with `BoxFit.contain` inside rounded pastel cards.
  - Safe fallback to vector icon and themed background if image is unavailable.
- **Distractor Generator (`BaseQuizRepository.getQuizQuestionsForCategory`)**:
  - Dynamically synthesizes 3 unique options per question (1 target item + 2 distractors).
  - Shuffles option order randomly across index 0, 1, and 2 (Task 11) to prevent position bias.
- **Difficulty Filtering (Task 12)**:
  - Filters question pool by `maxDifficulty` (Levels 1–3).

### 2.4 Task 5, 6 & 7 — Positive Reinforcement & Gentle Correction
- **Positive Reinforcement (Correct)**:
  - Awards 3 stars (`_starsCount += 3`).
  - Plays gentle star chime via `AudioService.playSuccessChime()`.
  - Displays celebratory `FeedbackBanner`: *"Great job! 🌟"* / *"You got it right! Keep going!"*
- **Gentle Correction (Incorrect)**:
  - Preserves stars (no star deduction or point penalty).
  - Plays soft chime via `AudioService.playGentleRetryChime()`.
  - Displays encouraging feedback: *"Good effort! 🌱"* / *"Let's try another one together!"*
  - Strict ASD compliance: zero red screens, no jarring buzzers, and no negative visual reinforcement.

### 2.5 Task 9 — 60-Second Peaceful Question Timer
- Built into `QuizProvider` and `QuizScreen`:
  - Displays a peaceful top-bar badge (`⏱️ 60s`).
  - Selecting an answer cancels the timer immediately.
  - **Quiet Timeout Progression**: If 60 seconds expire, `handleTimeout()` triggers soft non-alarming sound, records `childResponse: 'timeout'`, and displays *"Time's up! Let's keep going 🌱"* allowing quiet progression without stress.

### 2.6 Task 10 — Celebratory Quiz Completion Screen
- Answering the final question transitions to a celebratory completion view:
  - Large celebratory gold trophy / star badge.
  - Localized congratulations: *"Quiz Complete! 🌟"* / *"اكتمل الاختبار بنجاح! 🌟"*.
  - Score summary card: *"You got X out of Y right!"* along with accuracy percentage.
  - Action buttons:
    - **"Play Again 🔄"**: Restarts the quiz session with new questions.
    - **"Return Home 🏠"**: Cleanly navigates back to the home screen.
  - Final accuracy fraction written to `sessions` collection in Firestore.

---

## 3. Verification & Testing

All 14 tests in `test/interactive_quiz_module_test.dart` pass:

```text
Week 10 - Task 3: Quiz Question Model & Serialization
  ✓ QuizQuestionModel contains all required schema fields and helpers
  ✓ QuizResultModel serializes attempt telemetry accurately
Week 10 - Task 4, 11 & 12: Quiz Question Generation & Distractors
  ✓ Generates questions with exactly 3 options across categories
  ✓ Task 11: Correct choice position varies when choices are randomized
  ✓ Task 12: Filters quiz questions by difficulty level
Week 10 - Task 2, 5, 6, 7 & 8: QuizProvider Multi-Question Session State
  ✓ Initializes session with childId, categoryId, and persists to SessionRepository
  ✓ Evaluates correct choice: awards stars, plays positive chime, and logs result
  ✓ Evaluates incorrect choice: gentle correction, preserves stars (no penalty), logs result
  ✓ Advances across questions and finishes quiz with completion score
Week 10 - Task 9: 60-Second Peaceful Question Timer
  ✓ Automatic timeout triggers gentle chime and logs timeout attempt
  ✓ Selecting choice cancels active timer to prevent late trigger
Week 10 - Task 10: Quiz Screen UI & Completion Flow Tests
  ✓ Renders 3 image choices with aspect-ratio containment and feedback banner
  ✓ Multi-question quiz navigation advances to completion screen with score summary
  ✓ Bilingual Arabic RTL renders Harakat and localized completion messages
```
