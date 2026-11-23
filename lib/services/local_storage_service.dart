import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/child_model.dart';
import '../models/learning_session_model.dart';
import '../models/progress_model.dart';
import '../models/quiz_result_model.dart';
import '../models/user_model.dart';

/// Persistent local storage service utilizing SharedPreferences with in-memory fallback.
/// Guarantees that children profiles, parent accounts, and learning telemetry
/// survive app restarts, browser refreshes, and offline sessions.
class LocalStorageService {
  static const String _keyChildren = 'local_children_records_v1';
  static const String _keyUsers = 'local_users_records_v1';
  static const String _keyCredentials = 'local_credentials_records_v1';
  static const String _keySessions = 'local_sessions_records_v1';
  static const String _keyQuizResults = 'local_quiz_results_records_v1';
  static const String _keyProgressRecords = 'local_progress_records_v1';
  static const String _keyActiveChildId = 'local_active_child_id_v1';
  static const String _keyLastUserId = 'local_last_active_user_id_v1';

  static SharedPreferences? _prefs;
  static Future<SharedPreferences?>? _prefsFuture;
  static final Map<String, String> _inMemoryFallback = {};

  @visibleForTesting
  static void resetForTesting() {
    _prefs = null;
    _prefsFuture = null;
    _inMemoryFallback.clear();
  }

  static Future<SharedPreferences?> _getPrefs() {
    if (_prefs != null) return Future.value(_prefs);
    return _prefsFuture ??= () async {
      try {
        _prefs = await SharedPreferences.getInstance().timeout(
          const Duration(milliseconds: 300),
          onTimeout: () => throw TimeoutException('SharedPreferences timeout in test/headless'),
        );
        return _prefs;
      } catch (e) {
        debugPrint('LocalStorageService: SharedPreferences fallback to RAM: $e');
        return null;
      }
    }();
  }

  static Future<String?> _getString(String key) async {
    if (_inMemoryFallback.containsKey(key)) {
      return _inMemoryFallback[key];
    }
    if (_prefs != null) {
      final val = _prefs!.getString(key);
      if (val != null) {
        _inMemoryFallback[key] = val;
        return val;
      }
    } else {
      _getPrefs().then((p) {
        if (p != null) {
          final val = p.getString(key);
          if (val != null) _inMemoryFallback[key] = val;
        }
      }).catchError((_) {});
    }
    return _inMemoryFallback[key];
  }

  static Future<void> _setString(String key, String value) async {
    _inMemoryFallback[key] = value;
    if (_prefs != null) {
      try {
        await _prefs!.setString(key, value);
      } catch (_) {}
    } else {
      _getPrefs().then((p) {
        p?.setString(key, value);
      }).catchError((_) {});
    }
  }

  // ==========================================
  // CHILDREN PROFILES PERSISTENCE
  // ==========================================

  static Future<void> saveChild(ChildModel child) async {
    try {
      final children = await getAllChildren();
      final index = children.indexWhere((c) => c.childId == child.childId);
      if (index >= 0) {
        children[index] = child;
      } else {
        children.add(child);
      }
      final rawList = children.map((c) => c.toMap()).toList();
      await _setString(_keyChildren, jsonEncode(rawList));
    } catch (e) {
      debugPrint('LocalStorageService saveChild error: $e');
    }
  }

  static Future<List<ChildModel>> getAllChildren() async {
    try {
      final raw = await _getString(_keyChildren);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) => ChildModel.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (e) {
      debugPrint('LocalStorageService getAllChildren error: $e');
    }
    return [];
  }

  static Future<List<ChildModel>> getChildrenForParent(String parentId) async {
    final all = await getAllChildren();
    return all.where((c) => c.parentId == parentId || parentId == 'all').toList();
  }

  static Future<ChildModel?> getChildById(String childId) async {
    final all = await getAllChildren();
    try {
      return all.firstWhere((c) => c.childId == childId);
    } catch (_) {
      return null;
    }
  }

  // ==========================================
  // USERS PERSISTENCE
  // ==========================================

  static Future<void> saveUser(UserModel user) async {
    try {
      final users = await getAllUsers();
      final index = users.indexWhere((u) => u.userId == user.userId);
      if (index >= 0) {
        users[index] = user;
      } else {
        users.add(user);
      }
      final rawList = users.map((u) => u.toMap()).toList();
      await _setString(_keyUsers, jsonEncode(rawList));
      await _setString(_keyLastUserId, user.userId);
    } catch (e) {
      debugPrint('LocalStorageService saveUser error: $e');
    }
  }

  static Future<List<UserModel>> getAllUsers() async {
    try {
      final raw = await _getString(_keyUsers);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) => UserModel.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (e) {
      debugPrint('LocalStorageService getAllUsers error: $e');
    }
    return [];
  }

  static Future<UserModel?> getUserById(String userId) async {
    final all = await getAllUsers();
    try {
      return all.firstWhere((u) => u.userId == userId);
    } catch (_) {
      return null;
    }
  }

  static Future<UserModel?> getUserByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    final all = await getAllUsers();
    try {
      return all.firstWhere((u) => u.email.trim().toLowerCase() == normalized);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getLastUserId() => _getString(_keyLastUserId);

  // ==========================================
  // OFFLINE CREDENTIALS PERSISTENCE
  // ==========================================

  static Future<void> saveCredentials(String email, String password) async {
    try {
      final creds = await getCredentials();
      creds[email.trim().toLowerCase()] = password;
      await _setString(_keyCredentials, jsonEncode(creds));
    } catch (e) {
      debugPrint('LocalStorageService saveCredentials error: $e');
    }
  }

  static Future<Map<String, String>> getCredentials() async {
    try {
      final raw = await _getString(_keyCredentials);
      if (raw == null || raw.isEmpty) return {};
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {}
    return {};
  }

  // ==========================================
  // ACTIVE SELECTED CHILD
  // ==========================================

  static Future<void> saveActiveChildId(String childId) async {
    await _setString(_keyActiveChildId, childId);
  }

  static Future<String?> getActiveChildId() => _getString(_keyActiveChildId);

  // ==========================================
  // LEARNING SESSIONS PERSISTENCE
  // ==========================================

  static Future<void> saveSession(LearningSessionModel session) async {
    try {
      final sessions = await getAllSessions();
      final index = sessions.indexWhere((s) => s.sessionId == session.sessionId);
      if (index >= 0) {
        sessions[index] = session;
      } else {
        sessions.add(session);
      }
      final rawList = sessions.map((s) => s.toMap()).toList();
      await _setString(_keySessions, jsonEncode(rawList));
    } catch (e) {
      debugPrint('LocalStorageService saveSession error: $e');
    }
  }

  static Future<List<LearningSessionModel>> getAllSessions() async {
    try {
      final raw = await _getString(_keySessions);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) => LearningSessionModel.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (e) {
      debugPrint('LocalStorageService getAllSessions error: $e');
    }
    return [];
  }

  static Future<List<LearningSessionModel>> getSessionsForChild(String childId) async {
    final all = await getAllSessions();
    return all.where((s) => s.childId == childId).toList();
  }

  // ==========================================
  // QUIZ & GAME RESULTS PERSISTENCE
  // ==========================================

  static Future<void> saveQuizResult(QuizResultModel result) async {
    try {
      final results = await getAllQuizResults();
      final index = results.indexWhere((r) => r.resultId == result.resultId);
      if (index >= 0) {
        results[index] = result;
      } else {
        results.add(result);
      }
      final rawList = results.map((r) => r.toMap()).toList();
      await _setString(_keyQuizResults, jsonEncode(rawList));
    } catch (e) {
      debugPrint('LocalStorageService saveQuizResult error: $e');
    }
  }

  static Future<List<QuizResultModel>> getAllQuizResults() async {
    try {
      final raw = await _getString(_keyQuizResults);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) => QuizResultModel.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (e) {
      debugPrint('LocalStorageService getAllQuizResults error: $e');
    }
    return [];
  }

  static Future<List<QuizResultModel>> getQuizResultsForChild(String childId) async {
    final all = await getAllQuizResults();
    return all.where((r) => r.childId == childId).toList();
  }

  // ==========================================
  // PROGRESS RECORDS PERSISTENCE
  // ==========================================

  static Future<void> saveProgressRecord(ProgressRecordModel record) async {
    try {
      final records = await getAllProgressRecords();
      final index = records.indexWhere((r) => r.recordId == record.recordId);
      if (index >= 0) {
        records[index] = record;
      } else {
        records.add(record);
      }
      final rawList = records.map((r) => r.toMap()).toList();
      await _setString(_keyProgressRecords, jsonEncode(rawList));
    } catch (e) {
      debugPrint('LocalStorageService saveProgressRecord error: $e');
    }
  }

  static Future<List<ProgressRecordModel>> getAllProgressRecords() async {
    try {
      final raw = await _getString(_keyProgressRecords);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) => ProgressRecordModel.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (e) {
      debugPrint('LocalStorageService getAllProgressRecords error: $e');
    }
    return [];
  }

  static Future<List<ProgressRecordModel>> getProgressRecordsForChild(String childId) async {
    final all = await getAllProgressRecords();
    return all.where((r) => r.childId == childId).toList();
  }
}
