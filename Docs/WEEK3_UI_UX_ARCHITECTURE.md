# WEEK 3 — UI/UX & Application Architecture Documentation
## GenAI Adaptive Learning Assistant for Children with Autism Spectrum Disorder (ASD)

---

## 1. Overview & Clean Architecture Structure

During **Week 3**, the application architecture, sensory-friendly visual identity, bilingual localization engine (Arabic RTL / English LTR), and core UI skeletons were established based on the wireframes in the [`Docs/`](file:///d:/StudentsKSAProjects/Students/مشروع%20تحسين%20القراءه%20للاطفال-شيخه/Final%20Projext%20GenAI%20Adaptive/Docs) directory.

The project structure is organized cleanly to ensure maintainability, testability, and separation of concerns:

```text
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         # Calm ASD-friendly palette matching wireframes
│   │   ├── app_dimensions.dart     # 48dp+ touch target tokens & radii
│   │   └── app_routes.dart         # Named routing table
│   ├── theme/
│   │   └── app_theme.dart          # Material 3 calm typography & components
│   ├── localization/
│   │   └── app_localizations.dart  # Type-safe Arabic (RTL) & English (LTR) engine
│   └── utils/
│       └── responsive_layout.dart  # Responsive centering for Web & multi-screen
│
├── models/
│   ├── category_model.dart         # Category domain entity
│   ├── vocabulary_item_model.dart  # Bilingual flashcard model
│   ├── quiz_question_model.dart    # Interactive quiz & choices model
│   └── progress_model.dart         # Student progress & session records
│
├── repositories/
│   └── mock_data_repository.dart   # Separated mock layer for Week 3 wireframe data
│
├── screens/
│   ├── child/
│   │   ├── home_screen.dart                 # Wireframe 1 (Child View)
│   │   ├── category_selection_screen.dart   # Domain explorer
│   │   ├── vocabulary_learning_screen.dart  # Wireframe 4 (Flashcard & audio)
│   │   └── quiz_screen.dart                 # Wireframe 2 (Interactive Quiz)
│   ├── parent/
│   │   ├── login_screen.dart                # Educator/Parent login skeleton
│   │   ├── child_selection_screen.dart      # Student profile switcher
│   │   ├── progress_dashboard_screen.dart   # Wireframe 3 (Progress Dashboard)
│   │   └── settings_screen.dart             # Sensory settings & language toggle
│   └── developer/
│       └── backend_verification_screen.dart # Week 2 Firebase verification preserved
│
├── widgets/
│   ├── app_button.dart             # Accessible 48dp+ primary button
│   ├── large_icon_button.dart      # Audio (76dp), pagination, and back icons
│   ├── app_header.dart             # Child avatar, greeting, & parent shortcut
│   ├── category_card.dart          # 2x2 pastel card with friendly illustration
│   ├── vocabulary_card.dart        # Bilingual flashcard with large audio trigger
│   ├── quiz_choice_card.dart       # Choice frame with checkmark / ring indicator
│   ├── feedback_banner.dart        # Positive reinforcement star mascot banner
│   ├── stat_card.dart              # Dashboard metric card
│   └── category_bar_chart.dart     # Calm 0-100% mastery bar chart
│
├── services/
│   └── firebase_service.dart       # Preserved Week 2 backend service
├── firebase_options.dart           # Preserved Web configuration
└── main.dart                       # App entrypoint & dynamic locale state
```

---

## 2. Wireframe Implementation Mapping

All 4 design wireframes provided in the repository [`Docs/`](file:///d:/StudentsKSAProjects/Students/مشروع%20تحسين%20القراءه%20للاطفال-شيخه/Final%20Projext%20GenAI%20Adaptive/Docs) were translated into Flutter Web interfaces:

### 2.1 Wireframe 1 — Home Screen (Child View)
* **File**: [`lib/screens/child/home_screen.dart`](file:///d:/StudentsKSAProjects/Students/مشروع%20تحسين%20القراءه%20للاطفال-شيخه/Final%20Projext%20GenAI%20Adaptive/lib/screens/child/home_screen.dart)
* **Visual Elements**:
  * **Top Header**: Avatar circle with boy illustration, *"Hello, Adam! 👋"* greeting, *"Let's learn and have fun!"* subtitle, quick language toggle and parent shortcut.
  * **Daily Prompt**: *"What would you like to learn today?"* paired with a friendly smiling sun graphic in a rounded card.
  * **2x2 Category Grid**:
    * **Animals**: Pastel green (`#E8F5E9`), puppy illustration, dark green title.
    * **Colours**: Pastel yellow (`#FFF9C4`), rainbow illustration, warm brown title.
    * **Numbers**: Pastel cyan (`#E0F7FA`), 3D numbers illustration, navy title.
    * **Letters**: Pastel lavender (`#EDE7F6`), ABC illustration, purple title.
  * **Floating Bottom Navigation Bar**: Home (selected), Games (navigates to Quiz), Progress (navigates to Dashboard), Profile (navigates to Child Selection).

### 2.2 Wireframe 2 — Interactive Quiz Screen
* **File**: [`lib/screens/child/quiz_screen.dart`](file:///d:/StudentsKSAProjects/Students/مشروع%20تحسين%20القراءه%20للاطفال-شيخه/Final%20Projext%20GenAI%20Adaptive/lib/screens/child/quiz_screen.dart)
* **Visual Elements**:
  * **Top Bar**: Back button, Progress indicator (`3 / 10`) with smooth progress bar, points counter (`⭐ 12`).
  * **Question Card**: Speaker icon button with audio prompt + prompt text *"Where is the dog?"* / *"أين الكلب؟"*.
  * **3 Choices Grid**:
    * Dog (Doghouse, green border, checkmark badge when selected).
    * Cat (Armchair, blue border, selection ring).
    * Fish (Bowl, purple border, selection ring).
  * **Positive Reinforcement Banner**:
    * Default: Friendly Star mascot + *"Great job! You can do it!"*.
    * Correct Choice: Cheerful Star with celebratory copy *"Excellent! You found the dog!"* and 3 golden stars ⭐⭐⭐ (+3 points).
  * **Bottom Controls**: Previous, Replay Prompt, and Next Question.

### 2.3 Wireframe 3 — Progress Dashboard (Parent/Educator View)
* **File**: [`lib/screens/parent/progress_dashboard_screen.dart`](file:///d:/StudentsKSAProjects/Students/مشروع%20تحسين%20القراءه%20للاطفال-شيخه/Final%20Projext%20GenAI%20Adaptive/lib/screens/parent/progress_dashboard_screen.dart)
* **Visual Elements**:
  * **Top Bar**: Back button, title *"Progress Dashboard"*, subtitle *"Monitor learning and growth"*, and `Export` action button.
  * **Student Profile Card**: Adam's avatar, Age 5, interest badge (*"Loves Animals!"*), Total Sessions stat (`24`), and Overall Accuracy stat (`78%`).
  * **Filter Row**: Date range dropdown (*"May 1 – May 31, 2025"*) and category filter (*"All Categories"*).
  * **Category Bar Chart**: Visualizes category accuracy:
    * Animals: **85%** (Green bar with puppy badge).
    * Colours: **72%** (Amber bar with rainbow badge).
    * Numbers: **68%** (Blue bar with 123 badge).
    * Letters: **88%** (Purple bar with ABC badge).
  * **Recent Sessions List**: Date, Category, Score (`17/20`), Accuracy badge with green/amber smileys.

### 2.4 Wireframe 4 — Vocabulary Learning Screen
* **File**: [`lib/screens/child/vocabulary_learning_screen.dart`](file:///d:/StudentsKSAProjects/Students/مشروع%20تحسين%20القراءه%20للاطفال-شيخه/Final%20Projext%20GenAI%20Adaptive/lib/screens/child/vocabulary_learning_screen.dart)
* **Visual Elements**:
  * **Top Bar**: Back button, category badge (*"Animals"* with puppy icon), progress indicator (`1 / 3`).
  * **Main Flashcard**:
    * Large illustration/photo area with calm colored background.
    * Bilingual labels: English (*"Cat"*) and Arabic (*"قِطَّة"*) in bold 34sp typography.
  * **Action Controls**:
    * Previous word button (`LargeIconButton`).
    * **Prominent 76dp Audio Playback Button** (`Icons.volume_up_rounded`) with gentle outer glow.
    * Next word button (`LargeIconButton`), transitioning to quiz upon completion.

---

## 3. Sensory-Friendly & Accessibility Principles (ASD Guidelines)

1. **Touch Targets**:
   * All interactive elements meet or exceed the **48dp minimum touch target** guideline.
   * Standard buttons: **56dp**.
   * Primary audio speaker button: **76dp** with circular shape.
2. **Visual Calmness**:
   * No flashing animations, harsh contrasts, or high-saturation red errors.
   * Soft, pastel category card tones (soft mint greens, pastel yellows, soft cyans, lavenders).
   * Generous rounded corners (**24dp–32dp**) eliminating aggressive sharp edges.
3. **Cognitive Load & Autonomy**:
   * Children can use the app as guest learners without being forced to authenticate.
   * Audio prompts accompany every visual learning item.

---

## 4. Bilingual Localization Architecture (Arabic RTL & English LTR)

* Implemented in [`lib/core/localization/app_localizations.dart`](file:///d:/StudentsKSAProjects/Students/مشروع%20تحسين%20القراءه%20للاطفال-شيخه/Final%20Projext%20GenAI%20Adaptive/lib/core/localization/app_localizations.dart).
* Supports **English (`en`)** with LTR text direction and **Arabic (`ar`)** with native RTL layout.
* Dynamic switching at runtime via root state in [`lib/main.dart`](file:///d:/StudentsKSAProjects/Students/مشروع%20تحسين%20القراءه%20للاطفال-شيخه/Final%20Projext%20GenAI%20Adaptive/lib/main.dart) without reloading or duplicating any screen code.

---

## 5. Verification & Testing

* **Widget Tests (`flutter test`)**:
  * `Test 1`: Home Screen renders faithfully matching Wireframe 1 (PASSED).
  * `Test 2`: Dynamic RTL/LTR Bilingual Toggle works smoothly (PASSED).
  * `Test 3`: Vocabulary Learning Screen renders matching Wireframe 4 (PASSED).
  * `Test 4`: Interactive Quiz Screen renders matching Wireframe 2 with positive reinforcement (PASSED).
  * `Test 5`: Progress Dashboard Screen renders matching Wireframe 3 (PASSED).
  * `Test 6`: Child Selection Screen renders student profiles (PASSED).
* **Static Analysis (`dart analyze lib test`)**: **0 issues found**.
* **Flutter Web Build (`flutter build web --release`)**: Compiles production Web bundle cleanly.
