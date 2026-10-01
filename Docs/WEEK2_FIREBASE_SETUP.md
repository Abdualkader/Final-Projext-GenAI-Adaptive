# WEEK 2 — Firebase, Cloud Functions & AI Environment Setup
## GenAI Adaptive Learning Assistant for Children with Autism Spectrum Disorder (ASD)

---

## 1. Executive Summary & Architecture Overview

This document describes the backend infrastructure, security configuration, and connectivity verification established during **Week 2** for the *GenAI Adaptive Learning Assistant for Children with Autism Spectrum Disorder (ASD)*.

The solution is architected as a **Flutter Web-first** application communicating securely with Firebase managed services and server-side Cloud Functions proxying GenAI/LLM endpoints.

```text
  ┌────────────────────────────────────────────────────────┐
  │                 Flutter Web Frontend                   │
  │     (Material 3, ASD-Friendly Sensory Guidelines)      │
  └───────────────────────────┬────────────────────────────┘
                              │
             ┌────────────────┼────────────────┐
             │                │                │
             ▼                ▼                ▼
   ┌──────────────────┐ ┌───────────┐ ┌─────────────────┐
   │     Firebase     │ │   Cloud   │ │ Firebase Cloud  │
   │  Authentication  │ │ Firestore │ │     Storage     │
   │ (Parent/Educator)│ │(Datastore)│ │  (Audio/Images) │
   └──────────────────┘ └───────────┘ └─────────────────┘
                              │
                              ▼
                 ┌─────────────────────────┐
                 │ Firebase Cloud Function │
                 │  (Node.js 20 Backend)   │
                 └────────────┬────────────┘
                              │ (HTTPS / Server-Side Only)
                              ▼
                 ┌─────────────────────────┐
                 │       GenAI / NLP       │
                 │     (Gemini API /       │
                 │  Educational Fallback)  │
                 └─────────────────────────┘
```

---

## 2. Firebase Project & FlutterFire Web Configuration

### 2.1 Firebase Project
* **Project ID**: `studio-4aw7g`
* **Default Region**: `us-central1`
* **Web App ID**: `1:780303988370:web:4a29870122ffc6f97d984b`
* **Measurement ID**: `G-GFFS8Q49T9`

### 2.2 FlutterFire Web Integration
The Flutter project is configured using official FlutterFire packages with dedicated Web plugin implementations:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
  
  # Firebase Core & Services (Web Supported)
  firebase_core: ^4.15.0
  firebase_core_web: ^3.12.0
  firebase_auth: ^6.7.0
  firebase_auth_web: ^6.3.0
  cloud_firestore: ^6.10.0
  cloud_firestore_web: ^5.7.3
  firebase_storage: ^13.6.0
  firebase_storage_web: ^3.11.13
  cloud_functions: ^6.5.0
  cloud_functions_web: ^5.1.13
```

All credentials and Web configuration options are encapsulated within [`lib/firebase_options.dart`](file:///d:/StudentsKSAProjects/Students/مشروع%20تحسين%20القراءه%20للاطفال-شيخه/Final%20Projext%20GenAI%20Adaptive/lib/firebase_options.dart), initialized before `runApp()` in [`lib/main.dart`](file:///d:/StudentsKSAProjects/Students/مشروع%20تحسين%20القراءه%20للاطفال-شيخه/Final%20Projext%20GenAI%20Adaptive/lib/main.dart):

```dart
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

---

## 3. Enabled Firebase Services & Data Models

### 3.1 Firebase Authentication
* **Primary Scope**: Parent & Educator authentication.
* **Child Scope**: Anonymous child session support without requiring password entry or cognitive burden.
* **Connectivity Test**: Verified via `FirebaseAuth.instance.authStateChanges()`.

### 3.2 Cloud Firestore Database
Prepared for the 6 core educational collections defined in the Master Specification:

1. **`users`**: Parent/educator accounts, child profile links, ASD customization preferences (visual clutter level, sensory audio toggles).
2. **`categories`**: Vocabulary groupings (`animals`, `fruits`, `household`, `actions`).
3. **`vocabularyItems`**: Target words with Arabic text, transliteration, English translation, audio references, and image paths.
4. **`sessions`**: Interactive learning session tracking (start/end timestamp, attention markers).
5. **`quizResults`**: Multiple-choice outcome history, response latency, accuracy.
6. **`progressRecords`**: Aggregated mastery levels, word retention metrics, adaptive progression status.

### 3.3 Firebase Cloud Storage
Buckets structured for multi-sensory educational assets:
* `/vocabulary/images/` — High-contrast, uncluttered PNG/SVG illustrations.
* `/vocabulary/audio/ar/` — Clear Arabic pronunciation audio (MP3/WAV, spoken without background music).
* `/vocabulary/audio/en/` — English phonics pronunciation audio.
* `/_system_health/` — Connectivity verification ping targets.

---

## 4. Cloud Functions & AI Proxy Architecture

### 4.1 Strict Security Principle: Zero Client-Side Secrets
> **CRITICAL RULE**: AI API keys (e.g. Gemini, OpenAI) must **NEVER** be committed into Flutter client code or distributed to web clients where they could be extracted from browser JavaScript bundles.

All AI interactions are routed exclusively through server-side Cloud Functions:
1. Flutter Web client calls `generateAdaptiveExercise` callable function.
2. The function validates user authentication and session context.
3. The function checks for `GEMINI_API_KEY` stored securely in the server environment (e.g. Secret Manager or Firebase `.env`).
4. If the live AI endpoint is unavailable or API key not yet configured, the function returns a deterministic, curated ASD-appropriate educational exercise payload with zero disruption to the learner.

### 4.2 Available Functions
* **`healthCheck`**: Lightweight HTTP endpoint for ping and uptime monitoring.
* **`generateAdaptiveExercise`**: Callable Cloud Function receiving `targetWord`, `level`, and `childLanguage` to generate simplified questions and positive reinforcement hints.

---

## 5. Security Rules Configuration

### 5.1 Firestore Security Rules (`firestore.rules`)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Health check collection for connectivity testing
    match /_system_health/{docId} {
      allow read, write: if true;
    }
    
    // Educational content is readable by any authenticated/anonymous session
    match /categories/{categoryId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin managed
    }
    
    match /vocabularyItems/{itemId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin managed
    }
    
    // User data is strictly isolated to the authenticated owner
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /sessions/{sessionId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
    
    match /quizResults/{resultId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
    
    match /progressRecords/{recordId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
  }
}
```

### 5.2 Storage Security Rules (`storage.rules`)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /vocabulary/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if false; // Admin only
    }
    match /_system_health/{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

---

## 6. How Another Team Member Can Run the Project

### Prerequisites
* **Flutter SDK**: 3.24+ (verified with Flutter 3.47.5 / Dart 3.13.4)
* **Google Chrome** (or Chromium-based browser)
* **Node.js**: v18 or v20 LTS
* **Firebase CLI**: `npm install -g firebase-tools`

### Step-by-Step Instructions

1. **Clone the repository**:
   ```bash
   git clone <repo-url>
   cd "Final Projext GenAI Adaptive"
   ```

2. **Install Flutter Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify Code Analysis and Tests**:
   ```bash
   dart analyze lib test
   flutter test
   ```

4. **Run on Flutter Web**:
   ```bash
   flutter run -d chrome
   ```
   *The application will launch directly into the Week 2 Verification Dashboard, running real-time connectivity tests across Firebase Core, Auth, Firestore, Storage, and Cloud Functions.*

5. **Deploy Cloud Functions (Optional for Local Dev)**:
   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   ```
