const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp();
}

// Set global region to us-central1 (default)
setGlobalOptions({ region: "us-central1", maxInstances: 10 });

/**
 * Health Check Callable Function
 * Used to verify Flutter client -> Cloud Function connectivity.
 */
exports.healthCheck = onCall((request) => {
  return {
    status: "ok",
    service: "Cloud Functions v2",
    timestamp: new Date().toISOString(),
    projectId: process.env.GCLOUD_PROJECT || "studio-4aw7g",
    message: "Firebase Cloud Functions backend is connected and operational."
  };
});

// Canonical Whitelisted Educational Vocabulary Domain for Children with ASD (Task 13)
const VOCABULARY_DOMAIN = {
  animals: [
    { id: "cat", labelEn: "Cat", labelAr: "قطة", difficulty: 1 },
    { id: "dog", labelEn: "Dog", labelAr: "كلب", difficulty: 1 },
    { id: "bird", labelEn: "Bird", labelAr: "عصفور", difficulty: 1 },
    { id: "cow", labelEn: "Cow", labelAr: "بقرة", difficulty: 2 },
    { id: "lion", labelEn: "Lion", labelAr: "أسد", difficulty: 2 },
    { id: "elephant", labelEn: "Elephant", labelAr: "فيل", difficulty: 3 }
  ],
  colors: [
    { id: "red", labelEn: "Red", labelAr: "أحمر", difficulty: 1 },
    { id: "blue", labelEn: "Blue", labelAr: "أزرق", difficulty: 1 },
    { id: "green", labelEn: "Green", labelAr: "أخضر", difficulty: 1 },
    { id: "yellow", labelEn: "Yellow", labelAr: "أصفر", difficulty: 2 },
    { id: "orange", labelEn: "Orange", labelAr: "برتقالي", difficulty: 2 },
    { id: "purple", labelEn: "Purple", labelAr: "بنفسجي", difficulty: 3 }
  ],
  numbers: [
    { id: "one", labelEn: "One", labelAr: "واحد", difficulty: 1 },
    { id: "two", labelEn: "Two", labelAr: "اثنان", difficulty: 1 },
    { id: "three", labelEn: "Three", labelAr: "ثلاثة", difficulty: 1 },
    { id: "four", labelEn: "Four", labelAr: "أربعة", difficulty: 2 },
    { id: "five", labelEn: "Five", labelAr: "خمسة", difficulty: 3 }
  ],
  letters: [
    { id: "alef", labelEn: "Alef (A)", labelAr: "ألف (أ)", difficulty: 1 },
    { id: "baa", labelEn: "Baa (B)", labelAr: "باء (ب)", difficulty: 1 },
    { id: "taa", labelEn: "Taa (T)", labelAr: "تاء (ت)", difficulty: 1 },
    { id: "thaa", labelEn: "Thaa (Th)", labelAr: "ثاء (ث)", difficulty: 2 },
    { id: "jeem", labelEn: "Jeem (J)", labelAr: "جيم (ج)", difficulty: 3 }
  ]
};

// Verified Educational Fallback Bank (Task 6 & Task 15)
const FALLBACK_EXERCISE_BANKS = {
  animals: {
    1: {
      exerciseType: "identify_item",
      promptEn: "Where is the Cat?",
      promptAr: "أين القطة؟",
      correctChoiceId: "cat",
      choices: [
        { id: "cat", labelEn: "Cat", labelAr: "قطة" },
        { id: "dog", labelEn: "Dog", labelAr: "كلب" },
        { id: "bird", labelEn: "Bird", labelAr: "عصفور" }
      ]
    },
    2: {
      exerciseType: "select_correct_image",
      promptEn: "Find the Cow",
      promptAr: "اختر صورة البقرة",
      correctChoiceId: "cow",
      choices: [
        { id: "cow", labelEn: "Cow", labelAr: "بقرة" },
        { id: "lion", labelEn: "Lion", labelAr: "أسد" },
        { id: "cat", labelEn: "Cat", labelAr: "قطة" }
      ]
    },
    3: {
      exerciseType: "match_word_image",
      promptEn: "Which animal is the Elephant?",
      promptAr: "أي حيوان هو الفيل؟",
      correctChoiceId: "elephant",
      choices: [
        { id: "elephant", labelEn: "Elephant", labelAr: "فيل" },
        { id: "lion", labelEn: "Lion", labelAr: "أسد" },
        { id: "cow", labelEn: "Cow", labelAr: "بقرة" }
      ]
    }
  },
  colors: {
    1: {
      exerciseType: "identify_item",
      promptEn: "Select the Blue color",
      promptAr: "اختر اللون الأزرق",
      correctChoiceId: "blue",
      choices: [
        { id: "blue", labelEn: "Blue", labelAr: "أزرق" },
        { id: "red", labelEn: "Red", labelAr: "أحمر" },
        { id: "green", labelEn: "Green", labelAr: "أخضر" }
      ]
    },
    2: {
      exerciseType: "choose_between_items",
      promptEn: "Where is the Yellow color?",
      promptAr: "أين اللون الأصفر؟",
      correctChoiceId: "yellow",
      choices: [
        { id: "yellow", labelEn: "Yellow", labelAr: "أصفر" },
        { id: "orange", labelEn: "Orange", labelAr: "برتقالي" },
        { id: "blue", labelEn: "Blue", labelAr: "أزرق" }
      ]
    },
    3: {
      exerciseType: "match_word_image",
      promptEn: "Pick the Purple color",
      promptAr: "اختر اللون البنفسجي",
      correctChoiceId: "purple",
      choices: [
        { id: "purple", labelEn: "Purple", labelAr: "بنفسجي" },
        { id: "orange", labelEn: "Orange", labelAr: "برتقالي" },
        { id: "yellow", labelEn: "Yellow", labelAr: "أصفر" }
      ]
    }
  },
  numbers: {
    1: {
      exerciseType: "identify_item",
      promptEn: "Where is number One?",
      promptAr: "أين الرقم واحد؟",
      correctChoiceId: "one",
      choices: [
        { id: "one", labelEn: "One", labelAr: "واحد" },
        { id: "two", labelEn: "Two", labelAr: "اثنان" },
        { id: "three", labelEn: "Three", labelAr: "ثلاثة" }
      ]
    },
    2: {
      exerciseType: "select_correct_image",
      promptEn: "Find number Four",
      promptAr: "اختر الرقم أربعة",
      correctChoiceId: "four",
      choices: [
        { id: "four", labelEn: "Four", labelAr: "أربعة" },
        { id: "three", labelEn: "Three", labelAr: "ثلاثة" },
        { id: "two", labelEn: "Two", labelAr: "اثنان" }
      ]
    },
    3: {
      exerciseType: "choose_between_items",
      promptEn: "Which one is number Five?",
      promptAr: "أي رقم هو خمسة؟",
      correctChoiceId: "five",
      choices: [
        { id: "five", labelEn: "Five", labelAr: "خمسة" },
        { id: "four", labelEn: "Four", labelAr: "أربعة" },
        { id: "three", labelEn: "Three", labelAr: "ثلاثة" }
      ]
    }
  },
  letters: {
    1: {
      exerciseType: "identify_item",
      promptEn: "Where is letter Alef?",
      promptAr: "أين حرف الألف؟",
      correctChoiceId: "alef",
      choices: [
        { id: "alef", labelEn: "Alef (A)", labelAr: "ألف (أ)" },
        { id: "baa", labelEn: "Baa (B)", labelAr: "باء (ب)" },
        { id: "taa", labelEn: "Taa (T)", labelAr: "تاء (ت)" }
      ]
    },
    2: {
      exerciseType: "select_correct_image",
      promptEn: "Find letter Thaa",
      promptAr: "اختر حرف الثاء",
      correctChoiceId: "thaa",
      choices: [
        { id: "thaa", labelEn: "Thaa (Th)", labelAr: "ثاء (ث)" },
        { id: "taa", labelEn: "Taa (T)", labelAr: "تاء (ت)" },
        { id: "baa", labelEn: "Baa (B)", labelAr: "باء (ب)" }
      ]
    },
    3: {
      exerciseType: "match_word_image",
      promptEn: "Which one is letter Jeem?",
      promptAr: "أي حرف هو الجيم؟",
      correctChoiceId: "jeem",
      choices: [
        { id: "jeem", labelEn: "Jeem (J)", labelAr: "جيم (ج)" },
        { id: "thaa", labelEn: "Thaa (Th)", labelAr: "ثاء (ث)" },
        { id: "alef", labelEn: "Alef (A)", labelAr: "ألف (أ)" }
      ]
    }
  }
};

/**
 * Validates AI Exercise Schema (Task 5 & Task 13)
 * Rejects any malformed exercise, wrong choice count, missing correct answer,
 * or items outside the educational domain.
 */
function validateAiExercise(exercise, categoryId, difficultyLevel) {
  if (!exercise || typeof exercise !== "object") return false;
  if (!exercise.promptEn || typeof exercise.promptEn !== "string") return false;
  if (!exercise.promptAr || typeof exercise.promptAr !== "string") return false;
  if (!exercise.correctChoiceId || typeof exercise.correctChoiceId !== "string") return false;
  if (!Array.isArray(exercise.choices) || exercise.choices.length !== 3) return false;

  // Verify correctChoiceId is among the 3 choices
  const choiceIds = exercise.choices.map((c) => c && c.id);
  if (!choiceIds.includes(exercise.correctChoiceId)) return false;

  // Verify domain adherence (Task 13: strictly whitelisted educational vocabulary)
  const categoryVocab = VOCABULARY_DOMAIN[categoryId] || [];
  const validDomainIds = new Set(categoryVocab.map((v) => v.id));

  for (const choice of exercise.choices) {
    if (!choice || typeof choice !== "object") return false;
    if (!choice.id || !choice.labelEn || !choice.labelAr) return false;
    if (validDomainIds.size > 0 && !validDomainIds.has(choice.id)) {
      // Reject hallucinated vocabulary outside curriculum
      return false;
    }
  }

  return true;
}

/**
 * Generates an educational exercise using Gemini / External AI or Safe Fallback
 * 
 * ARCHITECTURE PRINCIPLES (Tasks 2, 3, 13, 14, 16):
 * 1. AI API keys are stored solely in backend secrets/environment.
 * 2. Flutter receives only validated educational exercises.
 * 3. No PII (names, emails, credentials) is transmitted to AI.
 * 4. Safe logging without sensitive credentials.
 */
exports.generateAdaptiveExercise = onCall(async (request) => {
  const startTime = Date.now();
  const data = request.data || {};

  // Task 14: Privacy Sanitization - Strictly discard any personal information
  const categoryId = ["animals", "colors", "numbers", "letters"].includes(data.categoryId)
    ? data.categoryId
    : "animals";

  // Task 8: Difficulty Boundaries - 1 (Easy), 2 (Medium), 3 (Hard)
  let difficultyLevel = parseInt(data.difficultyLevel, 10);
  if (isNaN(difficultyLevel) || difficultyLevel < 1) difficultyLevel = 1;
  if (difficultyLevel > 3) difficultyLevel = 3;

  const preferredLanguage = data.preferredLanguage === "ar" ? "ar" : "en";
  const exerciseType = [
    "identify_item",
    "select_correct_image",
    "match_word_image",
    "choose_between_items"
  ].includes(data.exerciseType)
    ? data.exerciseType
    : "identify_item";

  // Performance context for adaptive tailoring
  const recentAccuracy = typeof data.recentAccuracy === "number" ? data.recentAccuracy : 0.75;

  // Safe backend audit log (Task 16: No keys, no PII)
  console.log(
    `[AI Adaptive Service] Request -> Category: ${categoryId}, Diff: ${difficultyLevel}, Lang: ${preferredLanguage}, Type: ${exerciseType}, Accuracy: ${recentAccuracy.toFixed(2)}`
  );

  const openRouterKey = process.env.OPENROUTER_API_KEY;
  const geminiKey = process.env.GENAI_API_KEY;
  const defaultFreeModel = process.env.OPENROUTER_MODEL || "meta-llama/llama-3.3-70b-instruct";

  if (openRouterKey || geminiKey) {
    try {
      const allowedVocab = VOCABULARY_DOMAIN[categoryId] || [];
      const vocabListDescription = allowedVocab
        .map((v) => `${v.id} (English: ${v.labelEn}, Arabic: ${v.labelAr})`)
        .join(", ");

      const systemPrompt = `You are an educational assistant for children with Autism Spectrum Disorder (ASD).
Create a simple, predictable, gentle multiple-choice exercise.
Domain category: "${categoryId}".
Difficulty level: ${difficultyLevel} (1=Easy, 2=Medium, 3=Hard).
Exercise type: "${exerciseType}".
Learner accuracy context: ${recentAccuracy.toFixed(2)}.
Allowed vocabulary pool (USE ONLY THESE ITEMS): [${vocabListDescription}].

Rules:
1. Provide exactly 3 choices from the allowed vocabulary pool.
2. Provide non-empty English prompt ("promptEn") and Arabic prompt ("promptAr").
3. Set "correctChoiceId" to one of the 3 choices.
4. Output MUST be ONLY valid JSON matching this schema:
{
  "promptEn": "Where is the Cat?",
  "promptAr": "أين القطة؟",
  "correctChoiceId": "cat",
  "choices": [
    {"id": "cat", "labelEn": "Cat", "labelAr": "قطة"},
    {"id": "dog", labelEn: "Dog", labelAr: "كلب"},
    {"id": "bird", labelEn: "Bird", labelAr: "عصفور"}
  ]
}`;

      let candidateText = null;
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 6000);

      if (openRouterKey) {
        // Primary: OpenRouter API with Free Model
        const openRouterResponse = await fetch("https://openrouter.ai/api/v1/chat/completions", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${openRouterKey}`,
            "HTTP-Referer": "https://asd-learning-assistant.edu",
            "X-Title": "ASD Adaptive Learning Assistant"
          },
          signal: controller.signal,
          body: JSON.stringify({
            model: defaultFreeModel,
            messages: [
              { role: "system", content: systemPrompt },
              { role: "user", content: "Generate 1 exercise now. Output pure JSON only." }
            ],
            temperature: 0.2
          })
        });

        clearTimeout(timeoutId);

        if (openRouterResponse.ok) {
          const resJson = await openRouterResponse.json();
          candidateText = resJson.choices?.[0]?.message?.content;
        } else {
          console.warn(`[AI Adaptive Service] OpenRouter status ${openRouterResponse.status}, trying fallback.`);
        }
      } else if (geminiKey) {
        // Fallback: Gemini Direct REST API
        const geminiEndpoint = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${encodeURIComponent(geminiKey)}`;
        const response = await fetch(geminiEndpoint, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          signal: controller.signal,
          body: JSON.stringify({
            contents: [{ parts: [{ text: systemPrompt }] }],
            generationConfig: {
              temperature: 0.2,
              responseMimeType: "application/json"
            }
          })
        });

        clearTimeout(timeoutId);

        if (response.ok) {
          const jsonResponse = await response.json();
          candidateText = jsonResponse.candidates?.[0]?.content?.parts?.[0]?.text;
        }
      }

      if (candidateText) {
        // Clean markdown backticks if present
        let cleaned = candidateText.trim();
        if (cleaned.startsWith("```json")) {
          cleaned = cleaned.substring(7);
        } else if (cleaned.startsWith("```")) {
          cleaned = cleaned.substring(3);
        }
        if (cleaned.endsWith("```")) {
          cleaned = cleaned.substring(0, cleaned.length - 3);
        }

        const parsed = JSON.parse(cleaned.trim());

        // Task 5: Rigorous response validation
        if (validateAiExercise(parsed, categoryId, difficultyLevel)) {
          const executionDurationMs = Date.now() - startTime;
          console.log(
            `[AI Adaptive Service] Generation SUCCESS via AI in ${executionDurationMs}ms`
          );

          return {
            id: `ai_${categoryId}_${Date.now()}`,
            promptEn: parsed.promptEn,
            promptAr: parsed.promptAr,
            correctChoiceId: parsed.correctChoiceId,
            choices: parsed.choices,
            categoryId: categoryId,
            difficultyLevel: difficultyLevel,
            exerciseType: exerciseType,
            source: openRouterKey ? "openrouter_free_model" : "genai_live_api",
            model: openRouterKey ? defaultFreeModel : "gemini-1.5-flash",
            validated: true,
            durationMs: executionDurationMs,
            generatedAt: new Date().toISOString()
          };
        } else {
          console.warn(
            "[AI Adaptive Service] Validation failed for AI response, activating fallback bank."
          );
        }
      }
    } catch (err) {
      // Task 15 & 16: Safe error handling and logging (no credentials in logs)
      const errMessage = err.name === "AbortError" ? "Request Timeout" : err.message;
      console.warn(
        `[AI Adaptive Service] AI call interrupted (${errMessage}), switching to verified educational fallback.`
      );
    }
  }

  // Task 6: Verified Educational Fallback Bank
  const categoryBank = FALLBACK_EXERCISE_BANKS[categoryId] || FALLBACK_EXERCISE_BANKS.animals;
  const fallbackExercise = categoryBank[difficultyLevel] || categoryBank[1];
  const executionDurationMs = Date.now() - startTime;

  console.log(
    `[AI Adaptive Service] Served verified fallback exercise for ${categoryId} (level ${difficultyLevel}) in ${executionDurationMs}ms`
  );

  return {
    id: `fallback_${categoryId}_${Date.now()}`,
    promptEn: fallbackExercise.promptEn,
    promptAr: fallbackExercise.promptAr,
    correctChoiceId: fallbackExercise.correctChoiceId,
    choices: fallbackExercise.choices,
    categoryId: categoryId,
    difficultyLevel: difficultyLevel,
    exerciseType: fallbackExercise.exerciseType,
    source: "verified_educational_fallback",
    validated: true,
    durationMs: executionDurationMs,
    generatedAt: new Date().toISOString()
  };
});

// Specification alias matching PROJECT_REFERENCE.md Section 10
exports.generateAdaptiveQuiz = exports.generateAdaptiveExercise;

/**
 * Callable Function for AI Adaptive Matching Game
 * Returns a customized card set (pairs of images and words) adapted to child's level.
 */
exports.generateAdaptiveMatchingGame = onCall(async (request) => {
  const data = request.data || {};
  const categoryId = ["animals", "colors", "numbers", "letters"].includes(data.categoryId)
    ? data.categoryId
    : "animals";

  let difficultyLevel = parseInt(data.difficultyLevel, 10);
  if (isNaN(difficultyLevel) || difficultyLevel < 1) difficultyLevel = 1;
  if (difficultyLevel > 3) difficultyLevel = 3;

  // Level 1: 2 pairs (4 cards total)
  // Level 2: 3 pairs (6 cards total)
  // Level 3: 4 pairs (8 cards total)
  const pairCount = difficultyLevel === 1 ? 2 : (difficultyLevel === 2 ? 3 : 4);
  const allowedVocab = VOCABULARY_DOMAIN[categoryId] || VOCABULARY_DOMAIN.animals;

  // Select items matching or below difficulty level
  let eligible = allowedVocab.filter((v) => v.difficulty <= difficultyLevel);
  if (eligible.length < pairCount) eligible = allowedVocab;

  // Pick pairCount random items
  const shuffled = [...eligible].sort(() => 0.5 - Math.random());
  const selectedItems = shuffled.slice(0, pairCount);

  return {
    gameId: `game_${categoryId}_${Date.now()}`,
    categoryId: categoryId,
    difficultyLevel: difficultyLevel,
    pairCount: pairCount,
    items: selectedItems,
    instructionsEn: "Match each picture with its word!",
    instructionsAr: "طابق كل صورة مع كلمتها المناسبة!",
    generatedAt: new Date().toISOString()
  };
});

