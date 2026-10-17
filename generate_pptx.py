import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

def create_deck():
    prs = Presentation()
    # 16:9 widescreen dimensions
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)

    blank_layout = prs.slide_layouts[6]

    # Color Palette
    C_BG = RGBColor(15, 23, 42)         # #0F172A Navy
    C_CARD = RGBColor(30, 41, 59)       # #1E293B Slate Dark
    C_PRIMARY = RGBColor(56, 189, 248)   # #38BDF8 Sky Blue
    C_ACCENT = RGBColor(52, 211, 153)    # #34D399 Mint Green
    C_WARM = RGBColor(251, 191, 36)      # #FBBF24 Amber
    C_TEXT = RGBColor(248, 250, 252)     # #F8FAFC White/Light
    C_MUTED = RGBColor(148, 163, 184)    # #94A3B8 Gray

    def add_slide_background(slide):
        bg = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
        bg.fill.solid()
        bg.fill.fore_color.rgb = C_BG
        bg.line.fill.background()
        return bg

    def add_header(slide, topic, title, slide_num):
        # Topic badge
        tb_topic = slide.shapes.add_textbox(Inches(0.8), Inches(0.4), Inches(8.0), Inches(0.4))
        p_top = tb_topic.text_frame.paragraphs[0]
        p_top.text = f"● {topic.upper()}"
        p_top.font.size = Pt(11)
        p_top.font.bold = True
        p_top.font.color.rgb = C_PRIMARY

        # Slide Number
        tb_num = slide.shapes.add_textbox(Inches(11.0), Inches(0.4), Inches(1.5), Inches(0.4))
        p_num = tb_num.text_frame.paragraphs[0]
        p_num.alignment = PP_ALIGN.RIGHT
        p_num.text = f"{slide_num:02d} / 14"
        p_num.font.size = Pt(11)
        p_num.font.color.rgb = C_MUTED

        # Main Title
        tb_title = slide.shapes.add_textbox(Inches(0.8), Inches(0.75), Inches(11.7), Inches(0.8))
        p_title = tb_title.text_frame.paragraphs[0]
        p_title.text = title
        p_title.font.size = Pt(24)
        p_title.font.bold = True
        p_title.font.color.rgb = C_TEXT

    def add_card(slide, left, top, width, height, title, items, title_color=C_PRIMARY):
        card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(left), Inches(top), Inches(width), Inches(height))
        card.fill.solid()
        card.fill.fore_color.rgb = C_CARD
        card.line.color.rgb = RGBColor(51, 65, 85)
        card.line.width = Pt(1)

        tf = card.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.25)
        tf.margin_top = Inches(0.2)
        tf.margin_right = Inches(0.25)
        tf.margin_bottom = Inches(0.2)

        p_t = tf.paragraphs[0]
        p_t.text = title
        p_t.font.size = Pt(15)
        p_t.font.bold = True
        p_t.font.color.rgb = title_color
        p_t.space_after = Pt(10)

        for item in items:
            p = tf.add_paragraph()
            p.text = f"• {item}"
            p.font.size = Pt(12)
            p.font.color.rgb = C_TEXT
            p.space_after = Pt(6)

    def set_notes(slide, notes):
        notes_slide = slide.notes_slide
        tf = notes_slide.notes_text_frame
        tf.text = notes

    # =========================================================================
    # SLIDE 1: Title Slide
    # =========================================================================
    s1 = prs.slides.add_slide(blank_layout)
    add_slide_background(s1)
    
    # Title Box
    tbox = s1.shapes.add_textbox(Inches(1.0), Inches(1.5), Inches(11.333), Inches(4.5))
    tf1 = tbox.text_frame
    tf1.word_wrap = True

    p0 = tf1.paragraphs[0]
    p0.text = "GRADUATION PROJECT MID-EVALUATION"
    p0.font.size = Pt(13)
    p0.font.bold = True
    p0.font.color.rgb = C_PRIMARY
    p0.space_after = Pt(14)

    p1 = tf1.add_paragraph()
    p1.text = "GenAI Adaptive Learning Assistant\nfor Children with ASD"
    p1.font.size = Pt(36)
    p1.font.bold = True
    p1.font.color.rgb = C_TEXT
    p1.space_after = Pt(16)

    p2 = tf1.add_paragraph()
    p2.text = "A neurodivergent-calibrated, bilingual multi-sensory educational platform combining clinical sensory safety, real-time closed-loop adaptation, and enterprise serverless cloud architecture."
    p2.font.size = Pt(15)
    p2.font.color.rgb = C_MUTED
    p2.space_after = Pt(30)

    p3 = tf1.add_paragraph()
    p3.text = "Milestone: Weeks 1–7 Achievements  |  Status: 95/95 Tests Passing  |  Flutter & Google Cloud Firebase"
    p3.font.size = Pt(13)
    p3.font.bold = True
    p3.font.color.rgb = C_ACCENT

    set_notes(s1, "Good morning, esteemed committee members. Today, we are proud to present the mid-evaluation progress for our graduation project: The GenAI Adaptive Learning Assistant for Children with Autism Spectrum Disorder. Traditional educational applications present severe sensory hurdles: flashing neon colors, loud buzzers, and rigid difficulties. Our platform resolves this with a calm, bilingual, multi-sensory environment powered by Flutter and Google Cloud Firebase, with 50% of the project milestones fully achieved.")

    # =========================================================================
    # SLIDE 2: Architecture & Design Implementation (Topic 1)
    # =========================================================================
    s2 = prs.slides.add_slide(blank_layout)
    add_slide_background(s2)
    add_header(s2, "Topic 1: Architecture & Design", "Three-Tier Architecture & Clean Design", 2)
    
    add_card(s2, 0.8, 1.8, 5.7, 4.8, "Three-Tier Architectural Model", [
        "Presentation Tier: Cross-platform Flutter client with reactive Provider state management.",
        "Application Logic Tier: Firebase Cloud Functions for AI Prompt Orchestration and Item Response Theory (IRT) adaptation.",
        "Data Tier: Cloud Firestore (NoSQL document store) and Firebase Cloud Storage for audio & visual assets.",
        "Unidirectional Data Flow: UI Widgets → ChangeNotifier Providers → Repositories → Services → Firebase SDK."
    ], C_PRIMARY)

    add_card(s2, 6.8, 1.8, 5.7, 4.8, "Security & Clean Design Principles", [
        "Zero Key Exposure Rule: Private Generative AI API keys NEVER touch the client binary. All AI requests run behind serverless Cloud Functions.",
        "Decoupled Service Contracts: Repository interfaces abstract data access from UI screens completely.",
        "Dependency Injection: Repositories accept injectable Firestore/Storage services, enabling 100% offline unit and integration test hermeticity.",
        "UiState Presentation Containers: Screens observe Loading, Success, Empty, and Error states cleanly."
    ], C_ACCENT)

    set_notes(s2, "Our system architecture follows clean software engineering principles. We adopted a Three-Tier model separating the presentation layer from business logic and cloud persistence. Crucially, we enforce the Zero Key Exposure rule: all Generative AI interactions are isolated behind serverless Cloud Functions, eliminating the critical vulnerability of leaking API keys inside client binaries. Furthermore, our client codebase strictly separates UI widgets from database operations through repositories and reactive providers.")

    # =========================================================================
    # SLIDE 3: Core Functionality Implementation (Topic 2)
    # =========================================================================
    s3 = prs.slides.add_slide(blank_layout)
    add_slide_background(s3)
    add_header(s3, "Topic 2: Core Functionality", "Multi-Sensory Learning & Bilingual Engine", 3)

    add_card(s3, 0.8, 1.8, 5.7, 4.8, "Multi-Sensory Curriculum (4 Categories)", [
        "Letters (الحروف): Alphabet identification with clear phonetic pronunciation audio.",
        "Numbers (الأرقام): Visual quantity cards, numerals, and counted audio prompts.",
        "Colors (الألوان): Spectrum recognition paired with familiar real-world items.",
        "Animals (الحيوانات): Animal flashcards with bilingual vocalizations.",
        "Dynamic Arabic RTL & English LTR: Instant language flipping with full diacritics (Tashkeel) support without app reload."
    ], C_PRIMARY)

    add_card(s3, 6.8, 1.8, 5.7, 4.8, "Dual-Persona Navigation & Telemetry", [
        "Open Child Learner Access: Zero password gates, captcha, or login hurdles preventing student focus.",
        "Secure Parent/Educator Portal: Protected by RouteGuard; requires authenticated credentials to access analytics and sensory controls.",
        "Interactive 3-Option Matching Trials: Calm visual selection with star celebrations and gentle retry cues.",
        "Session Telemetry Logging: Automatically tracks session duration, items presented, response times, and accuracy."
    ], C_WARM)

    set_notes(s3, "In terms of core functionality, the system supports multi-sensory learning across four foundational categories: Letters, Numbers, Colors, and Animals. We built a fully dynamic bilingual engine supporting Arabic RTL with diacritics and English LTR. Notice our deliberate dual-persona design: parents authenticate securely to view student telemetry, while children enjoy an open, low-friction learning experience free of frustrating password barriers.")

    # =========================================================================
    # SLIDE 4: Backend & Database Implementation (Topic 3)
    # =========================================================================
    s4 = prs.slides.add_slide(blank_layout)
    add_slide_background(s4)
    add_header(s4, "Topic 3: Backend & Database", "Cloud Firestore & Storage Data Layer", 4)

    add_card(s4, 0.8, 1.8, 5.7, 4.8, "7 Cloud Firestore Collections", [
        "users: Parent/educator profiles (userId, role, preferredLanguage, linkedChildIds).",
        "children: Student learner profiles (childId, parentId, name, age, asdLevel).",
        "categories: Learning domains (id, nameEn, nameAr, iconName, orderIndex).",
        "vocabularyItems: Flashcard cards (itemId, categoryId, imageUrl, audioUrls, difficulty).",
        "sessions: Telemetry logs (sessionId, childId, startTime, endTime, score).",
        "quizResults: Question trials (resultId, questionId, childResponse, isCorrect).",
        "progressRecords: Daily mastery aggregation (recordId, childId, date, accuracy)."
    ], C_PRIMARY)

    add_card(s4, 6.8, 1.8, 5.7, 4.8, "Optimized Indexing & Cloud Storage", [
        "Composite Indexes in firestore.indexes.json:",
        "  • sessions: childId ASC + startTime DESC (Instant session history)",
        "  • vocabularyItems: categoryId ASC + difficultyLevel ASC (Rapid filtering)",
        "  • progressRecords: childId ASC + date DESC (Fast analytics generation)",
        "Firebase Storage Service: Resolves media paths (vocabulary/images/, vocabulary/audio/ar/, vocabulary/audio/en/).",
        "Offline Fallback: Clean resolution with bundled local asset fallbacks."
    ], C_ACCENT)

    set_notes(s4, "Our backend implementation leverages Cloud Firestore and Firebase Cloud Storage. We established seven structured collections capturing everything from parent profiles to granular question-level responses and daily mastery records. To guarantee sub-second queries on historical trends, we authored composite index specifications in firestore.indexes.json. Our StorageService abstracts cloud media fetching so the Flutter UI only receives resolved URLs, supported by offline local asset fallbacks.")

    # =========================================================================
    # SLIDE 5: Security Architecture & Access Control (Topic 3 & 8)
    # =========================================================================
    s5 = prs.slides.add_slide(blank_layout)
    add_slide_background(s5)
    add_header(s5, "Topic 3 & 8: Security & Privacy", "Server-Side Security Rules & Route Guards", 5)

    add_card(s5, 0.8, 1.8, 5.7, 4.8, "Server-Side Firestore Rules", [
        "User Privacy: request.auth.uid == userId blocks parents from querying or modifying unrelated adult accounts.",
        "Child Data Scoping: request.auth.uid == resource.data.parentId restricts student profiles, sessions, and quiz metrics strictly to the owning parent/educator.",
        "Content Immutability: Category and vocabulary items are read-only for authenticated learners; write/delete operations are strictly blocked.",
        "Storage Access Rules: Educational media is readable; write operations are locked down."
    ], C_PRIMARY)

    add_card(s5, 6.8, 1.8, 5.7, 4.8, "Client Navigation Protection (RouteGuard)", [
        "Protected Routes: /parent/child-selection, /parent/dashboard, /parent/settings.",
        "Open Child Routes: /child/home, /child/learning, /child/quiz.",
        "Intercept & Redirect: Direct route or deep-link navigation by unauthenticated users is intercepted and routed to /login.",
        "No Hardcoded Credentials: Client codebase contains zero API keys, passwords, or cloud credentials."
    ], C_WARM)

    set_notes(s5, "Security is never solved solely on the client side. We deployed rigorous Firestore and Cloud Storage security rules. A parent cannot query another child's progress even if they know the document ID because our security rules validate parentId ownership server-side. At the same time, client-side RouteGuards protect educator screens, ensuring our application is safe, compliant, and private.")

    # =========================================================================
    # SLIDE 6: Frontend & Sensory UI/UX Implementation (Topic 4)
    # =========================================================================
    s6 = prs.slides.add_slide(blank_layout)
    add_slide_background(s6)
    add_header(s6, "Topic 4: Frontend UI/UX", "Sensory-Calibrated Design System for ASD", 6)

    add_card(s6, 0.8, 1.8, 5.7, 4.8, "Sensory Safety & Calm Color System", [
        "Soft Sky Blue (#E8F4F8): Tranquil primary background preventing ocular strain.",
        "Mint Green (#E8F8F5): Gentle affirmation tone for positive reinforcement.",
        "Warm Amber (#FFF8E7): Supportive corrective cue replacing harsh red error alerts.",
        "High-Contrast Slate (#1A2B3C): Crisp typography ensuring legibility without glare.",
        "No Strobing / Rapid Flashes: Transitions adhere to gentle easing curves (≥400 ms)."
    ], C_PRIMARY)

    add_card(s6, 6.8, 1.8, 5.7, 4.8, "Ergonomics & Cognitive Architecture", [
        "Generous Touch Targets: Buttons and flashcards adhere to ≥64×64 dp to accommodate developing fine-motor coordination.",
        "Non-Punitive Sound Design: Wrong answers trigger gentle encouraging chimes; zero loud buzzers.",
        "Predictable Spatial Layout: Consistent button positions (Audio, Next, Back) build confidence and security.",
        "Zero Distraction: No third-party advertisements, flashing tickers, or cognitive clutter."
    ], C_ACCENT)

    set_notes(s6, "Our user interface is designed in accordance with neurodivergent ergonomics and ASD sensory profiles. Children with autism are susceptible to sensory overload from aggressive visual stimulation. Consequently, we eliminated saturated neon colors, strobe animations, and jarring error buzzers. We selected a calm pastel palette, enlarged touch targets to at least 64 dp for developing motor coordination, and replaced punishing red indicators with encouraging corrective prompts.")

    # =========================================================================
    # SLIDE 7: Screens Showcase (Topic 4)
    # =========================================================================
    s7 = prs.slides.add_slide(blank_layout)
    add_slide_background(s7)
    add_header(s7, "Topic 4: Frontend Screens", "7 Interactive Production Screens Implemented", 7)

    add_card(s7, 0.8, 1.8, 5.7, 4.8, "Child Learner Screens", [
        "1. Home Screen: 4 calm category cards with voice prompts and bilingual toggle.",
        "2. Vocabulary Learning Screen: High-contrast flashcard, image display, Arabic/English audio buttons, previous/next controls.",
        "3. Interactive Quiz Screen: 3-option visual choice trial, star particle reward celebrations, and kind retry cues.",
        "Sensory Feedback: 'Let's try again gently! 🌱' instead of negative error alerts."
    ], C_PRIMARY)

    add_card(s7, 6.8, 1.8, 5.7, 4.8, "Parent & Educator Screens", [
        "4. Parent Login Screen: Form validation, gentle error alerts, guest child bypass.",
        "5. Child Selection Screen: Student profile cards displaying age, ASD level, and accuracy badges.",
        "6. Progress Dashboard Screen: Mastered vocabulary counter, accuracy meters, session duration metrics.",
        "7. Sensory Settings Screen: Audio volume slider, session time limiter (5–30 min to prevent cognitive fatigue), and bilingual toggle."
    ], C_WARM)

    set_notes(s7, "Across Weeks 1 through 7, we engineered seven complete, responsive screens. For the child, the Home, Vocabulary Learning, and Interactive Quiz screens offer an intuitive, encouraging journey. For adults, the Child Selection, Progress Dashboard, and Sensory Settings screens provide actionable insights and customizable session boundaries, such as limiting session time to prevent cognitive fatigue.")

    # =========================================================================
    # SLIDE 8: Testing Strategy & Methodology (Topic 5)
    # =========================================================================
    s8 = prs.slides.add_slide(blank_layout)
    add_slide_background(s8)
    add_header(s8, "Topic 5: Testing Strategy", "Multi-Tier Testing Pyramid & Hermetic Isolation", 8)

    add_card(s8, 0.8, 1.8, 5.7, 4.8, "Multi-Tier Testing Pyramid", [
        "Unit Tests: Model serialization (toMap/fromMap), repository contracts, exception mapping, and UiState lifecycle states.",
        "Widget & UI Tests: Screen rendering, bilingual RTL/LTR flipping, touch target measurements, sensory constraint verification, form validation.",
        "Integration Tests: Complete end-to-end data pipeline simulation (Login → User Profile → Child Selection → Categories → Vocabulary → Storage URLs).",
        "Sensory Assertions: Tests verify absence of harsh red alerts and ensure child-friendly messages output correctly."
    ], C_PRIMARY)

    add_card(s8, 6.8, 1.8, 5.7, 4.8, "Hermetic Testability Architecture", [
        "Fake Services & Sample Data: Built FakeAuthService and SampleDataService with in-memory caching.",
        "100% Offline Testability: All test suites execute cleanly in CI environments without active internet connection or initialized Firebase apps.",
        "Zero Flakiness: Isolated hermetic tests guarantee deterministic execution with zero cloud timeout errors.",
        "Automated CI Gates: Commits must pass both full test suites and dart analyze with zero warnings."
    ], C_ACCENT)

    set_notes(s8, "Our testing strategy adheres to strict software quality assurance standards. We employ a three-tier test pyramid consisting of unit tests, widget tests, and full integration tests. Importantly, we engineered our test suites to be hermetic: by injecting mock authentication and in-memory repository fallbacks, our entire automated test suite runs offline in CI pipelines with zero flaky network dependencies.")

    # =========================================================================
    # SLIDE 9: Testing Results & Bug Fixing (Topic 6)
    # =========================================================================
    s9 = prs.slides.add_slide(blank_layout)
    add_slide_background(s9)
    add_header(s9, "Topic 6: Testing Results", "Quality Verification Metrics & Resolved Issues", 9)

    add_card(s9, 0.8, 1.8, 5.7, 4.8, "Quantitative Quality Metrics", [
        "Total Automated Tests: 95 Tests Executed.",
        "Test Pass Rate: 100% (95 / 95 Passed).",
        "Static Analysis: 0 Errors, 0 Warnings (dart analyze lib test).",
        "Test Suite Execution Speed: < 7.0 seconds across entire suite.",
        "Code Coverage: High coverage across all repositories, models, services, providers, and sensory screens."
    ], C_ACCENT)

    add_card(s9, 6.8, 1.8, 5.7, 4.8, "Resolved Bugs & Edge Cases", [
        "Bug 1 - Arabic Diacritics (Tashkeel) Matching: Exact matching failed on words like 'قِطَّة' due to Kasra diacritics. Resolved via diacritical normalization.",
        "Bug 2 - Headless Test Firestore Uninitialized: Headless flutter test threw [core/no-app]. Resolved by building in-memory fallbacks into all repository write methods.",
        "Bug 3 - Dynamic RTL Text Overflow: Rapid language flipping clipped text on small screens. Fixed using responsive LayoutBuilder constraints.",
        "Bug 4 - Dual-Mode Sensory Errors: Technical errors were prevented from reaching child views via UiState and AppException child-mode translation."
    ], C_WARM)

    set_notes(s9, "We are delighted to report a 100% pass rate across all 95 automated test cases, with zero static analysis warnings. During development, our rigorous testing caught important edge cases early: for example, Arabic diacritics caused search mismatches, which we resolved by implementing phonological normalization. We also fixed headless test runner issues by implementing resilient in-memory fallbacks, and guaranteed that technical exceptions can never slip past our dual-mode sensory error handler.")

    # =========================================================================
    # SLIDE 10: System Integration Status (Topic 7)
    # =========================================================================
    s10 = prs.slides.add_slide(blank_layout)
    add_slide_background(s10)
    add_header(s10, "Topic 7: System Integration", "Client-to-Cloud Integration Status", 10)

    add_card(s10, 0.8, 1.8, 5.7, 4.8, "Live Operational Cloud Pipelines", [
        "Client ↔ Firebase Authentication: Live auth state stream, token persistence, role assignment, and route guards. (OPERATIONAL)",
        "Client ↔ Cloud Firestore: Live read/write across 7 collections with data model mapping and offline fallbacks. (OPERATIONAL)",
        "Client ↔ Cloud Storage: Dynamic URL resolution for flashcard images and bilingual pronunciation audio. (OPERATIONAL)",
        "Client ↔ State Providers: ChangeNotifier providers supply live reactive data to UI widgets without direct polling. (OPERATIONAL)"
    ], C_PRIMARY)

    add_card(s10, 6.8, 1.8, 5.7, 4.8, "Generative AI Cloud Integration (Week 12)", [
        "Cloud Functions AI Gateway: Interface contracts and prompt templates specified.",
        "Prompt Validation Gatekeeper: Validates LLM output against predetermined vocabulary dictionaries to prevent hallucinations.",
        "Scheduled Deployment: Cloud Functions and GenAI LLM integration scheduled for Week 12 implementation.",
        "Zero Key Exposure Architecture: Private API keys remain completely secure behind Google Cloud IAM."
    ], C_ACCENT)

    set_notes(s10, "Our system integration status is mature and solid for this mid-evaluation milestone. The Flutter client is actively integrated with Firebase Authentication, Cloud Firestore, and Cloud Storage. All state management is reactive, ensuring zero UI lag or polling overhead. The backend contract for our serverless Generative AI Cloud Functions is fully specified and awaiting the scheduled Week 12 rollout.")

    # =========================================================================
    # SLIDE 11: Deployment Readiness (Topic 8)
    # =========================================================================
    s11 = prs.slides.add_slide(blank_layout)
    add_slide_background(s11)
    add_header(s11, "Topic 8: Deployment Readiness", "Cross-Platform Build & Infrastructure Audit", 11)

    add_card(s11, 0.8, 1.8, 5.7, 4.8, "Cross-Platform Build Readiness", [
        "Android Target: Clean Gradle configuration targeting API 21 through 34 (APK & App Bundle ready).",
        "iOS Target: Clean Xcode workspace supporting iPhone and iPad screen sizes.",
        "Web Target: Fast CanvasKit and HTML rendering for educator desktop dashboard access.",
        "Asset Bundles: SVG icons, flashcard images, and sample datasets bundled and verified."
    ], C_PRIMARY)

    add_card(s11, 6.8, 1.8, 5.7, 4.8, "Cloud & Compliance Audit", [
        "Firebase Config Committed: firebase.json, .firebaserc, and index configurations.",
        "Security Rules Deployed: firestore.rules and storage.rules active.",
        "Zero Key Exposure Audit: 100% verified; zero secrets or API keys in client code.",
        "ASD Sensory Compliance: Verified against neurodivergent accessibility heuristics.",
        "CI/CD Pipeline: Automated test suite and static analysis pass cleanly."
    ], C_WARM)

    set_notes(s11, "Regarding deployment readiness, our repository is well-organized and production-ready. We have verified builds across Android, iOS, and Web. Firebase configurations, security rules, and composite indexes are deployed. The codebase passes automated CI validation, satisfies neurodivergent accessibility audits, and complies strictly with the Zero Key Exposure rule.")

    # =========================================================================
    # SLIDE 12: Achieved Milestones & Progress (Topic 9)
    # =========================================================================
    s12 = prs.slides.add_slide(blank_layout)
    add_slide_background(s12)
    add_header(s12, "Topic 9: Achieved Milestones", "50% Project Milestone Completion (Weeks 1–7)", 12)

    add_card(s12, 0.8, 1.8, 5.7, 4.8, "Completed Weekly Milestones", [
        "Week 1: Problem definition, ASD clinical literature review, sensory requirements.",
        "Week 2: Firebase environment setup, security rules, multi-platform init.",
        "Week 3: Calm design system tokens, pastel color palette, bilingual wireframing.",
        "Week 4: Core UI implementation (Home, Learning, Quiz, Dashboard, Settings).",
        "Week 5: Clean core architecture, unidirectional data flow, Provider state management.",
        "Week 6: Parent authentication, child profile linking, and navigation RouteGuard.",
        "Week 7: Live Cloud Firestore and Storage data layer, composite indexes, 95 tests."
    ], C_PRIMARY)

    add_card(s12, 6.8, 1.8, 5.7, 4.8, "Current Status Summary", [
        "Progress Metric: 50% of the 14-Week Lifecycle Completed.",
        "Software Quality: 95/95 Tests Passing (100% pass rate).",
        "Architecture Status: 3-Tier clean architecture locked and verified.",
        "Data Layer Status: Cloud Firestore & Storage operational with composite indexing.",
        "Sensory Status: Complete compliance with ASD sensory heuristics."
    ], C_ACCENT)

    set_notes(s12, "As shown in our progress timeline, we have successfully reached the 50% midpoint milestone. Across Weeks 1 through 7, we built the complete foundational software stack: problem formulation, sensory UI/UX, clean architecture, authentication, database layer, security rules, and comprehensive automated testing. The system is structurally complete and fully prepared for content expansion and algorithmic intelligence.")

    # =========================================================================
    # SLIDE 13: Remaining Work & Plan to Completion (Topic 10)
    # =========================================================================
    s13 = prs.slides.add_slide(blank_layout)
    add_slide_background(s13)
    add_header(s13, "Topic 10: Plan to Completion", "Roadmap to Final Defense (Weeks 8–14)", 13)

    add_card(s13, 0.8, 1.8, 5.7, 4.8, "Second-Half Development Plan", [
        "Week 8: Full vocabulary catalog ingestion & studio pronunciation audio recordings.",
        "Week 9: Closed-loop Adaptive Engine (Item Response Theory & Spaced Repetition).",
        "Week 10: Advanced assessment suite & calibrated positive sensory reinforcement.",
        "Week 11: Analytics visualizations, mastery rate graphs, and parent PDF exports.",
        "Week 12: GenAI Cloud Functions integration under Zero Key Exposure rule.",
        "Week 13: Usability & clinical validation pilot with ASD educators and parents.",
        "Week 14: Final performance optimization, documentation freeze, and graduation defense."
    ], C_PRIMARY)

    add_card(s13, 6.8, 1.8, 5.7, 4.8, "Risk Management & Mitigation", [
        "Risk: Live cloud timeouts during clinical trials. → Mitigation: Bundled offline asset fallbacks ensure 100% uninterrupted local operation.",
        "Risk: GenAI hallucinations in exercises. → Mitigation: Server-side Prompt Gatekeeper validates all questions against approved vocabulary dictionaries.",
        "Risk: Child cognitive fatigue. → Mitigation: Configurable session duration limiter (5–30 min) in educator settings."
    ], C_WARM)

    set_notes(s13, "Looking ahead to the second half of the project: In Week 8, we will ingest our complete vocabulary catalog with native audio pronunciations. In Weeks 9 and 10, we will implement the Item Response Theory adaptive engine to calibrate exercise difficulty to each child's cognitive pace. In Week 12, we will connect our GenAI Cloud Functions. Finally, in Week 13, we will conduct usability trials with special education teachers and parents, culminating in our final graduation defense in Week 14.")

    # =========================================================================
    # SLIDE 14: Conclusion & Q&A
    # =========================================================================
    s14 = prs.slides.add_slide(blank_layout)
    add_slide_background(s14)
    
    tbox14 = s14.shapes.add_textbox(Inches(1.0), Inches(1.2), Inches(11.333), Inches(5.0))
    tf14 = tbox14.text_frame
    tf14.word_wrap = True

    p14_0 = tf14.paragraphs[0]
    p14_0.text = "MID-EVALUATION SUMMARY & DEMONSTRATION"
    p14_0.font.size = Pt(13)
    p14_0.font.bold = True
    p14_0.font.color.rgb = C_PRIMARY
    p14_0.space_after = Pt(14)

    p14_1 = tf14.add_paragraph()
    p14_1.text = "Transforming Autism Education\nThrough Sensory-Safe Adaptive AI"
    p14_1.font.size = Pt(36)
    p14_1.font.bold = True
    p14_1.font.color.rgb = C_TEXT
    p14_1.space_after = Pt(20)

    p14_2 = tf14.add_paragraph()
    p14_2.text = "Live Demonstration Highlights:\n• Dynamic bilingual RTL (Arabic with diacritics) & LTR (English) instant switching\n• Multi-sensory flashcard learning with native audio pronunciation\n• Gentle, non-punitive 3-option quiz interaction with star celebrations\n• Parent authentication barrier, student selection, and sensory settings controls"
    p14_2.font.size = Pt(14)
    p14_2.font.color.rgb = C_TEXT
    p14_2.space_after = Pt(24)

    p14_3 = tf14.add_paragraph()
    p14_3.text = "Thank You! We warmly welcome questions from the examination committee."
    p14_3.font.size = Pt(16)
    p14_3.font.bold = True
    p14_3.font.color.rgb = C_ACCENT

    set_notes(s14, "To conclude: The GenAI Adaptive Learning Assistant is more than a technical graduation project—it is an empathetic, scientifically informed assistive tool designed to empower neurodivergent children. With a solid architecture, complete database layer, zero static analysis issues, and 95 passing tests, we are fully on track for an impactful completion. We thank the committee for their time and guidance, and we are now delighted to present a live demonstration and take your questions.")

    out_path = os.path.join("Docs", "MID_EVALUATION_PRESENTATION.pptx")
    prs.save(out_path)
    print(f"Presentation successfully saved to: {out_path}")

if __name__ == "__main__":
    create_deck()
