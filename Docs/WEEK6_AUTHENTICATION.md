# WEEK 6 — AUTHENTICATION AND USER MANAGEMENT IMPLEMENTATION REPORT

**Project:** GenAI Adaptive Learning Assistant for Children with Autism Spectrum Disorder (ASD)  
**Target Platform:** Flutter Web & Mobile (Android, iOS)  
**Evaluation Date:** October 2026  
**Status:** Completed & Validated (63/63 Tests Passing, 0 Analyzer Warnings)

---

## 1. Overview & Objectives

Week 6 establishes the secure authentication and user management foundation using Firebase Authentication and Cloud Firestore for the parent and educator portal.

The authentication and authorization architecture follows a strict unidirectional data flow:
```text
Login Screen (UI)
       ↓
Authentication Provider (ChangeNotifier State)
       ↓
Authentication Service & User Repository
       ↓
Firebase Authentication & Cloud Firestore
```

### Key Safety & ASD UI/UX Principles Enforced
1. **Protected Navigation Barrier:** Parents and educators must authenticate before accessing student profiles, progress dashboards, or sensitive sensory settings (`RouteGuard`). Unauthenticated access is automatically redirected to `/login`.
2. **Open Low-Friction Child Access:** Children are never encumbered by login barriers. Direct access to `/child/home`, `/child/learning`, and `/child/quiz` remains open and friction-free with dedicated guest bypass buttons.
3. **Gentle Error Messaging:** Technical authentication errors and stack traces are translated to user-friendly notifications in both Arabic and English. No harsh red alerts or punishing feedback.
4. **Zero Key & Secret Exposure:** User passwords and API keys are strictly forbidden from Firestore document storage. All credential verification is mediated securely through Firebase Authentication tokens.

---

## 2. Implemented Features & Architectural Verification

### 2.1 Firebase Authentication Integration (Task 2 & 3)
* **`AuthenticationService`** (`lib/services/auth_service.dart`):
  * Clean wrapper over `FirebaseAuth.instance`.
  * Implements `signInWithEmailAndPassword` and `signUpWithEmailAndPassword`.
  * Implements `signOut()` and continuous `authStateChanges` stream tracking.
  * Comprehensive error code mapping translating codes (`invalid-credential`, `wrong-password`, `user-not-found`, `invalid-email`, `weak-password`, `user-disabled`, `network-request-failed`, `too-many-requests`) into localized, calm messages.
  * Dependency injection support (`AuthenticationService({FirebaseAuth? firebaseAuth})`) enabling hermetic unit and widget testing without active cloud dependencies.

### 2.2 User Model & Role Hierarchy (Task 4)
* **`UserModel`** (`lib/models/user_model.dart`):
  * Aligns with the project database design:
    * `userId`: Unique Firebase Auth UID.
    * `email`: Parent/educator email address.
    * `displayName`: Optional educator title (e.g. "Teacher Nora").
    * `role`: `'parent' | 'educator' | 'child'`.
    * `preferredLanguage`: `'ar' | 'en'`.
    * `linkedChildIds`: `List<String>` of managed student IDs.
    * `difficultyLevel`: Initial difficulty level setting (default: 1).
    * `createdAt`: Account timestamp.
  * Role convenience helpers: `isParent`, `isEducator`, `isChild`.
  * Safe serialization (`toMap()` / `fromMap()`) strictly excluding credential or token data.

### 2.3 User Profile Management & State Controller (Task 5 & 7)
* **`AuthProvider`** (`lib/providers/auth_provider.dart`):
  * Maintains `currentUser`, `linkedChildren`, and `selectedChild`.
  * Reactive `_initAuthListener()` synchronizing session state with Firebase Auth streams.
  * `_loadUserProfile(uid, email)`: Fetches the user profile from `UserRepository.getUserById()`, creating an initial profile in Firestore if one does not exist, and loads linked child profiles via `UserRepository.getLinkedChildren()`.
  * `selectChild(ChildModel child)`: Persists the currently active student in application state across learning and progress modules.
  * `updatePreferredLanguage(String lang)`: Updates user preference in state and syncs to Firestore.
  * `signOut()`: Completely flushes `currentUser`, `linkedChildren`, `selectedChild`, and resets `UiState` to initial.

### 2.4 Login Screen & Feedback (Task 1, 2 & 3)
* **`LoginScreen`** (`lib/screens/parent/login_screen.dart`):
  * Preserves the sensory-friendly pastel styling and large touch buttons established in Week 4.
  * Form validation catches empty fields (`Please enter your email address`, `Please enter your password`) and malformed emails (`Please enter a valid email format`).
  * Shows non-disorienting loading indicator while authenticating (`Signing in...` / `جاري الدخول...`).
  * Displays inline warning container for incorrect credentials or network timeouts.
  * Guest child bypass button (`Continue as Child (No Login Required)`) preserves open access to student modules.

### 2.5 Authentication-Aware Navigation & Route Guards (Task 6)
* **`RouteGuard`** (`lib/core/routes/route_guard.dart`):
  * Protected routes: `/parent/child-selection`, `/parent/dashboard`, `/parent/settings`.
  * Open routes: `/child/home`, `/child/category-selection`, `/child/learning`, `/child/quiz`, `/login`, `/diagnostics`.
* **`AppRouter`** (`lib/core/routes/app_router.dart`):
  * Dynamic `onGenerateRoute` intercepts unauthorized attempts to access protected routes and redirects them to `LoginScreen`.
  * Permitted authenticated requests proceed directly to `ChildSelectionScreen`, `ProgressDashboardScreen`, or `SettingsScreen`.

### 2.6 Child Profile Selection (Task 7)
* **`ChildSelectionScreen`** (`lib/screens/parent/child_selection_screen.dart`):
  * Connected to `AuthProvider.linkedChildren`.
  * Presents multiple student profiles (Adam, Sara, Omar) with age, accuracy badges, and interest highlights.
  * Tapping a profile sets `AuthProvider.selectChild(child)` and navigates to the student's `ProgressDashboardScreen`.

### 2.7 Logout Flow (Task 8)
* Added accessible Logout action in `ChildSelectionScreen` app bar.
* Clears all session tokens, user profile, and active child state in `AuthProvider`.
* Navigates back to `LoginScreen` via `Navigator.pushNamedAndRemoveUntil(context, AppRoutes.parentLogin, (route) => false)`.

### 2.8 Language Preference & Dynamic RTL/LTR Sync (Task 9)
* After successful login, `AuthProvider` checks the user's `preferredLanguage` (`ar` or `en`).
* If the user prefers Arabic, the interface dynamically reconfigures to Arabic RTL layout; if English, to English LTR layout.

### 2.9 Firestore Security Rules (Task 10)
* **`firestore.rules`**:
  * Users can only read and write their own document: `request.auth.uid == userId`.
  * Children collection allows access only if `resource.data.parentId == request.auth.uid`.
  * Client-side roles are not trusted for database authorization; Firestore checks `request.auth.uid`.
  * Strict prohibition of password storage.

---

## 3. Automated Test Verification (Task 11)

### 3.1 Static Code Analysis
* Command: `dart analyze lib test`
* Result: **0 issues found!** (Clean code, zero warnings, zero dead code).

### 3.2 Test Suites Execution
* Command: `flutter test`
* **Test Suite 1: Week 6 Auth & User Management (`test/auth_and_user_management_test.dart`): 23/23 Tests Passed**
  * `UserModel` fields, defaults, roles (`parent`, `educator`, `child`), serialization, copyWith, and password absence security check.
  * `AuthenticationService` and `AuthException` mapping for invalid credentials and network failures.
  * `UserRepository` profile retrieval, fallback creation, and linked children loading.
  * `AuthProvider` initial state, empty validation, invalid credentials, network failure, profile loading, `selectChild`, `signOut`, and `updatePreferredLanguage`.
  * `RouteGuard` route permissions and `AppRouter` unauthenticated redirect / authenticated access.
  * Widget tests for `LoginScreen` input validation, fake authentication, child profile rendering, selection navigation, and logout.
* **Test Suite 2: Week 5 Core Architecture (`test/core_architecture_test.dart`): 30/30 Tests Passed**
* **Test Suite 3: Week 4 Main Interfaces (`test/widget_test.dart`): 10/10 Tests Passed**
* **Total: 63/63 Unit & Widget Tests Passing.**

---

## 4. Key Files Created & Modified

| File Path | Description of Changes |
|---|---|
| `lib/models/user_model.dart` | Added `difficultyLevel` and `isChild` helper; verified password exclusion |
| `lib/services/auth_service.dart` | Enhanced error mapping for invalid credentials and network errors; added dependency injection |
| `lib/repositories/user_repository.dart` | Updated linked children retrieval for multi-profile support and profile persistence |
| `lib/providers/auth_provider.dart` | Added `linkedChildren`, `selectedChild`, `selectChild()`, `signUp()`, `updatePreferredLanguage()` |
| `lib/screens/parent/login_screen.dart` | Connected to `AuthProvider.signIn()`, added loading state, validation, and language sync |
| `lib/screens/parent/child_selection_screen.dart` | Connected to `AuthProvider`, added `selectChild()` logic and Logout action in AppBar |
| `lib/core/routes/app_router.dart` | Injected `AuthProvider` and enforced authentication-aware route dispatch |
| `lib/main.dart` | Wrapped in `MultiProvider` with `AuthProvider` and authentication-aware routing |
| `firestore.rules` | Hardened security rules with user and children ownership checks |
| `pubspec.yaml` | Added `provider: ^6.1.5+1` dependency |
| `test/auth_and_user_management_test.dart` | 23 comprehensive unit and widget tests for Week 6 |
| `Docs/WEEK6_AUTHENTICATION.md` | Formal Week 6 specification and implementation documentation |

---

## 5. Scope Boundaries & Items Deferred

In accordance with the project schedule:
* **Real Vocabulary Firestore Seeding:** Real vocabulary loading and Firestore collections belong to **Week 7**.
* **Adaptive Learning Session Telemetry:** Dynamic session adaptation belongs to **Week 8**.
* **Quiz Logic & IRT Evaluation:** Item response theory scoring belongs to **Week 9**.
* **AI Assistance & Cloud Functions:** Gemini GenAI integration belongs to **Week 12** under the Zero Key Exposure Rule.

---

## 6. Readiness for Week 7

**Confirmed.** The application has a fully working, secure authentication and user management system with linked child profiles, route protection, and dynamic bilingual support. The architecture is completely primed for **Week 7 (Firestore Data Layer & Vocabulary Database)**.
