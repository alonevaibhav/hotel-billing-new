// translation_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:translator/translator.dart';

/// Configuration class for translation service
class TranslationConfig {
  final Duration cacheExpiry;
  final int maxCacheSize;
  final Duration requestTimeout;
  final int maxRetries;
  final Duration retryDelay;
  final bool enableDebugLogs;
  final String cachePrefix;

  const TranslationConfig({
    this.cacheExpiry = const Duration(days: 7),
    this.maxCacheSize = 1000,
    this.requestTimeout = const Duration(seconds: 10),
    this.maxRetries = 3,
    this.retryDelay = const Duration(milliseconds: 500),
    this.enableDebugLogs = kDebugMode,
    this.cachePrefix = 'translation_cache_',
  });
}

/// Language model for supported languages
class Language {
  final String name;
  final String code;
  final String flag;
  final String nativeName;

  const Language({
    required this.name,
    required this.code,
    required this.flag,
    required this.nativeName,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'flag': flag,
      'nativeName': nativeName,
    };
  }

  factory Language.fromMap(Map<String, dynamic> map) {
    return Language(
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      flag: map['flag'] ?? '',
      nativeName: map['nativeName'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Language && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}

/// Translation result with metadata
class TranslationResult {
  final String text;
  final String sourceLanguage;
  final String targetLanguage;
  final bool fromCache;
  final DateTime timestamp;

  const TranslationResult({
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.fromCache,
    required this.timestamp,
  });
}

/// Exception classes for better error handling
class TranslationException implements Exception {
  final String message;
  final String? originalText;
  final String? targetLanguage;

  const TranslationException(this.message, {this.originalText, this.targetLanguage});

  @override
  String toString() => 'TranslationException: $message';
}

class NetworkException extends TranslationException {
  const NetworkException(String message, {String? originalText, String? targetLanguage})
      : super(message, originalText: originalText, targetLanguage: targetLanguage);
}

class CacheException extends TranslationException {
  const CacheException(String message, {String? originalText, String? targetLanguage})
      : super(message, originalText: originalText, targetLanguage: targetLanguage);
}

/// Main Translation Service
class TranslationService {
  static TranslationService? _instance;
  static TranslationService get instance => _instance ??= TranslationService._internal();

  TranslationService._internal();

  late final TranslationConfig _config;
  late final GoogleTranslator _translator;

  // In-memory cache for fast access
  final Map<String, Map<String, _CacheEntry>> _memoryCache = {};

  // Pending translations to avoid duplicate requests
  final Map<String, Completer<String>> _pendingTranslations = {};

  // Connectivity stream
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = true;

  bool _isInitialized = false;

  /// Initialize the translation service
  Future<void> initialize({TranslationConfig? config}) async {
    if (_isInitialized) return;

    _config = config ?? const TranslationConfig();
    _translator = GoogleTranslator();

    // Monitor connectivity
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);

    // Check initial connectivity
    await _checkConnectivity();

    // Clean expired cache
    await _cleanExpiredCache();

    _isInitialized = true;
    _log('Translation service initialized');
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _pendingTranslations.clear();
    _isInitialized = false;
  }

  /// Translate text with caching and error handling
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'auto',
  }) async {
    _ensureInitialized();

    if (text.trim().isEmpty) {
      return TranslationResult(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        fromCache: false,
        timestamp: DateTime.now(),
      );
    }

    final cacheKey = _generateCacheKey(text, sourceLanguage, targetLanguage);

    // Check memory cache first
    final cachedResult = _getFromMemoryCache(cacheKey);
    if (cachedResult != null) {
      _log('Translation served from memory cache: ${text.substring(0, text.length.clamp(0, 50))}...');
      return TranslationResult(
        text: cachedResult,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        fromCache: true,
        timestamp: DateTime.now(),
      );
    }

    // Check if translation is already in progress
    if (_pendingTranslations.containsKey(cacheKey)) {
      _log('Translation already in progress, waiting...');
      final result = await _pendingTranslations[cacheKey]!.future;
      return TranslationResult(
        text: result,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        fromCache: false,
        timestamp: DateTime.now(),
      );
    }

    // Create completer for this translation
    final completer = Completer<String>();
    _pendingTranslations[cacheKey] = completer;

    try {
      String translatedText;

      if (_isOnline) {
        // Try online translation with retries
        translatedText = await _translateWithRetry(text, targetLanguage, sourceLanguage);

        // Cache the result
        await _cacheTranslation(cacheKey, translatedText);
        _addToMemoryCache(cacheKey, translatedText);
      } else {
        // Try persistent cache when offline
        translatedText = await _getFromPersistentCache(cacheKey) ?? text;
        if (translatedText == text) {
          throw NetworkException('No internet connection and no cached translation available');
        }
      }

      completer.complete(translatedText);
      return TranslationResult(
        text: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        fromCache: !_isOnline,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      final errorMessage = e is TranslationException ? e.message : e.toString();
      completer.completeError(e);

      // Try to return cached version as fallback
      final fallbackResult = await _getFromPersistentCache(cacheKey);
      if (fallbackResult != null) {
        _log('Returning cached result as fallback due to error: $errorMessage');
        return TranslationResult(
          text: fallbackResult,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          fromCache: true,
          timestamp: DateTime.now(),
        );
      }

      throw TranslationException(errorMessage, originalText: text, targetLanguage: targetLanguage);
    } finally {
      _pendingTranslations.remove(cacheKey);
    }
  }

  /// Translate multiple texts in batch
  Future<Map<String, TranslationResult>> translateBatch({
    required List<String> texts,
    required String targetLanguage,
    String sourceLanguage = 'auto',
    int batchSize = 5,
    Duration delayBetweenBatches = const Duration(milliseconds: 100),
  }) async {
    _ensureInitialized();

    final Map<String, TranslationResult> results = {};

    for (int i = 0; i < texts.length; i += batchSize) {
      final batch = texts.skip(i).take(batchSize).toList();
      final batchFutures = batch.map((text) => translate(
        text: text,
        targetLanguage: targetLanguage,
        sourceLanguage: sourceLanguage,
      ));

      final batchResults = await Future.wait(batchFutures);

      for (int j = 0; j < batch.length; j++) {
        results[batch[j]] = batchResults[j];
      }

      // Delay between batches to avoid rate limiting
      if (i + batchSize < texts.length) {
        await Future.delayed(delayBetweenBatches);
      }
    }

    return results;
  }

  /// Preload common translations for a language
  Future<void> preloadTranslations({
    required String targetLanguage,
    List<String>? customTexts,
  }) async {
    _ensureInitialized();

    final textsToPreload = customTexts ?? _getCommonTexts();

    _log('Preloading ${textsToPreload.length} translations for $targetLanguage');

    await translateBatch(
      texts: textsToPreload,
      targetLanguage: targetLanguage,
      batchSize: 3,
      delayBetweenBatches: const Duration(milliseconds: 200),
    );

    _log('Preloading completed for $targetLanguage');
  }

  /// Clear all cached translations
  Future<void> clearCache() async {
    _memoryCache.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_config.cachePrefix));

      for (final key in keys) {
        await prefs.remove(key);
      }

      _log('Cache cleared successfully');
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final memoryCount = _memoryCache.values.fold<int>(0, (sum, map) => sum + map.length);

    try {
      final prefs = await SharedPreferences.getInstance();
      final persistentCount = prefs.getKeys().where((key) => key.startsWith(_config.cachePrefix)).length;

      return {
        'memoryCache': memoryCount,
        'persistentCache': persistentCount,
        'isOnline': _isOnline,
        'pendingTranslations': _pendingTranslations.length,
      };
    } catch (e) {
      return {
        'memoryCache': memoryCount,
        'persistentCache': 'Error: $e',
        'isOnline': _isOnline,
        'pendingTranslations': _pendingTranslations.length,
      };
    }
  }

  // Private methods

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('TranslationService not initialized. Call initialize() first.');
    }
  }

  Future<String> _translateWithRetry(String text, String targetLanguage, String sourceLanguage) async {
    Exception? lastException;

    for (int attempt = 1; attempt <= _config.maxRetries; attempt++) {
      try {
        _log('Translation attempt $attempt for: ${text.substring(0, text.length.clamp(0, 30))}...');

        final translation = await _translator
            .translate(text, from: sourceLanguage, to: targetLanguage)
            .timeout(_config.requestTimeout);

        return translation.text;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        _log('Translation attempt $attempt failed: $e');

        if (attempt < _config.maxRetries) {
          await Future.delayed(_config.retryDelay * attempt);
        }
      }
    }

    throw TranslationException(
      'Translation failed after ${_config.maxRetries} attempts: ${lastException.toString()}',
      originalText: text,
      targetLanguage: targetLanguage,
    );
  }

  String _generateCacheKey(String text, String sourceLanguage, String targetLanguage) {
    return '${sourceLanguage}_${targetLanguage}_${text.hashCode}';
  }

  String? _getFromMemoryCache(String cacheKey) {
    final parts = cacheKey.split('_');
    if (parts.length < 2) return null;

    final targetLanguage = parts[1];
    final entry = _memoryCache[targetLanguage]?[cacheKey];

    if (entry != null && !entry.isExpired) {
      return entry.value;
    }

    return null;
  }

  void _addToMemoryCache(String cacheKey, String value) {
    final parts = cacheKey.split('_');
    if (parts.length < 2) return;

    final targetLanguage = parts[1];
    _memoryCache[targetLanguage] ??= {};

    // Check cache size limit
    if (_memoryCache[targetLanguage]!.length >= _config.maxCacheSize) {
      _memoryCache[targetLanguage]!.clear();
    }

    _memoryCache[targetLanguage]![cacheKey] = _CacheEntry(
      value: value,
      timestamp: DateTime.now(),
      expiry: DateTime.now().add(_config.cacheExpiry),
    );
  }

  Future<void> _cacheTranslation(String cacheKey, String translation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'value': translation,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiry': DateTime.now().add(_config.cacheExpiry).millisecondsSinceEpoch,
      };

      await prefs.setString(
        '${_config.cachePrefix}$cacheKey',
        jsonEncode(cacheData),
      );
    } catch (e) {
      _log('Failed to cache translation: $e');
    }
  }

  Future<String?> _getFromPersistentCache(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('${_config.cachePrefix}$cacheKey');

      if (cachedData != null) {
        final data = jsonDecode(cachedData) as Map<String, dynamic>;
        final expiry = DateTime.fromMillisecondsSinceEpoch(data['expiry']);

        if (DateTime.now().isBefore(expiry)) {
          return data['value'] as String;
        } else {
          // Remove expired cache
          await prefs.remove('${_config.cachePrefix}$cacheKey');
        }
      }
    } catch (e) {
      _log('Failed to read from persistent cache: $e');
    }

    return null;
  }

  Future<void> _cleanExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_config.cachePrefix));

      for (final key in keys) {
        final cachedData = prefs.getString(key);
        if (cachedData != null) {
          try {
            final data = jsonDecode(cachedData) as Map<String, dynamic>;
            final expiry = DateTime.fromMillisecondsSinceEpoch(data['expiry']);

            if (DateTime.now().isAfter(expiry)) {
              await prefs.remove(key);
            }
          } catch (e) {
            // Remove corrupted cache entries
            await prefs.remove(key);
          }
        }
      }
    } catch (e) {
      _log('Failed to clean expired cache: $e');
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      _isOnline = connectivityResults.contains(ConnectivityResult.mobile) ||
          connectivityResults.contains(ConnectivityResult.wifi) ||
          connectivityResults.contains(ConnectivityResult.ethernet);
    } catch (e) {
      _log('Connectivity check failed: $e');
      _isOnline = false;
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);

    if (!wasOnline && _isOnline) {
      _log('Connection restored');
    } else if (wasOnline && !_isOnline) {
      _log('Connection lost');
    }
  }

  List<String> _getCommonTexts() {
    return [
      'Hello',
    ];
  }

  void _log(String message) {
    if (_config.enableDebugLogs) {
      debugPrint('[TranslationService] $message');
    }
  }
}

/// Cache entry for memory cache
class _CacheEntry {
  final String value;
  final DateTime timestamp;
  final DateTime expiry;

  _CacheEntry({
    required this.value,
    required this.timestamp,
    required this.expiry,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// Predefined languages with comprehensive list
class SupportedLanguages {
  static const List<Language> all = [
    Language(name: 'English', code: 'en', flag: '🇺🇸', nativeName: 'English'),
    Language(name: 'Hindi', code: 'hi', flag: '🇮🇳', nativeName: 'हिंदी'),
    Language(name: 'Marathi', code: 'mr', flag: '🇮🇳', nativeName: 'मराठी'),
  ];


  static Language? findByCode(String code) {
    try {
      return all.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }

  static Language get defaultLanguage => all.first;
}