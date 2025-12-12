import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../translation_service.dart';

/// Comprehensive GetX Controller for Translation Management
class TranslationController extends GetxController {
  static TranslationController get instance => Get.find();

  // Reactive variables
  final _currentLanguage = Rxn<Language>(); // Currently selected language
  final _previousLanguage = Rxn<Language>(); // Track previous language for back-translation
  final _isLoading = false.obs; // Loading state for translations
  final _isInitialized = false.obs; // Initialization state of the controller
  final _networkStatus = true.obs; // Network connectivity status
  final _cacheStats = <String, dynamic>{}.obs; // Cache statistics

  // In-memory translation cache with TTL
  final _memoryCache = <String, _CachedTranslation>{}.obs; // Cache for translations
  final _pendingTranslations = <String, Future<String>>{}; // Track pending translations

  // Store original texts to handle back-translation to English
  final _originalTexts = <String, String>{}.obs;

  // Batch processing
  final _batchQueue = <_BatchRequest>[]; // Queue for batch translation requests
  Timer? _batchTimer; // Timer for batch processing

  // Configuration
  static const int _maxCacheSize = 500; // Maximum number of cached translations
  static const Duration _cacheExpiry = Duration(hours: 6); // Cache expiry duration
  static const Duration _batchDelay = Duration(milliseconds: 150); // Delay for batch processing
  static const int _batchSize = 8; // Number of translations to process in a batch

  // Getters
  Language? get currentLanguage => _currentLanguage.value;
  Language? get previousLanguage => _previousLanguage.value;
  bool get isLoading => _isLoading.value;
  bool get isInitialized => _isInitialized.value;
  bool get isOnline => _networkStatus.value;
  Map<String, dynamic> get cacheStats => _cacheStats;

  @override
  void onInit() {
    super.onInit();
    _initializeController(); // Initialize the controller and translation service
  }

  @override
  void onClose() {
    _batchTimer?.cancel(); // Cancel batch timer
    TranslationService.instance.dispose(); // Dispose translation service
    super.onClose();
  }

  /// Initialize the controller and translation service
  Future<void> _initializeController() async {
    try {
      _isLoading.value = true;




      // Initialize translation service with configuration
      await TranslationService.instance.initialize(
        config: const TranslationConfig(
          cacheExpiry: Duration(days: 7),
          maxCacheSize: 1000,
          requestTimeout: Duration(seconds: 8),
          maxRetries: 3,
          retryDelay: Duration(milliseconds: 300),
          enableDebugLogs: true,
        ),
      );
      // Load saved language preference
      await _loadSavedLanguage();
      // Update cache stats
      await _updateCacheStats();
      _isInitialized.value = true;
      _networkStatus.value = true;
      // Setup periodic cache cleanup
      _setupCacheCleanup();
    } catch (e) {
      _networkStatus.value = false;
      _showError('Translation service initialization failed: $e');
      print('Translation service initialization failed: $e');

    } finally {
      _isLoading.value = false;
    }
  }

  /// Change language with optimization and preloading
  Future<void> changeLanguage(Language language, {bool showProgress = true}) async {
    if (_currentLanguage.value?.code == language.code) return;
    if (showProgress) _isLoading.value = true;
    try {
      // Store previous language before changing
      _previousLanguage.value = _currentLanguage.value;
      // Save language preference
      await _saveLanguagePreference(language);
      // Update reactive variable
      _currentLanguage.value = language;
      // Clear relevant cache entries for the new language
      _clearLanguageCache(language.code);
      // Preload common translations in background
      _preloadCommonTranslations(language.code);
      // Update app locale
      if (Get.context != null) {
        Get.updateLocale(Locale(language.code));
      }
      await _updateCacheStats();
      if (showProgress) {
        _showSuccess('Language changed to ${language.name}');
      }
    } catch (e) {
      _showError('Failed to change language: $e');
    } finally {
      if (showProgress) _isLoading.value = false;
    }
  }

  /// High-performance text translation with multiple optimization layers
  Future<String> translateText(
      String text, {
        String? targetLanguage,
        String sourceLanguage = 'auto',
        bool useCache = true,
        Duration? timeout,
        String? originalText, // Added to handle back-translation
      }) async {
    if (text.trim().isEmpty) return text;
    final targetLang = targetLanguage ?? currentLanguage?.code ?? 'en';
    // Handle translation to English - check if we have original text
    if (targetLang == 'en') {
      // If we have the original English text stored, return it
      final storedOriginal = _originalTexts[text];
      if (storedOriginal != null) {
        return storedOriginal;
      }
      // If originalText is provided, use it
      if (originalText != null) {
        _originalTexts[text] = originalText;
        return originalText;
      }
      // If source language is auto and we're going to English,
      // we might need to translate back from the previous language
      if (sourceLanguage == 'auto' && _previousLanguage.value != null) {
        sourceLanguage = _previousLanguage.value!.code;
      }
    }
    // If source and target are the same, return original
    if (sourceLanguage == targetLang && targetLang != 'auto') {
      return text;
    }
    final cacheKey = _generateCacheKey(text, sourceLanguage, targetLang);
    // Check memory cache first (fastest)
    if (useCache) {
      final cached = _getFromMemoryCache(cacheKey);
      if (cached != null) return cached;
    }
    // Check if translation is already pending
    if (_pendingTranslations.containsKey(cacheKey)) {
      return await _pendingTranslations[cacheKey]!;
    }
    // Create translation future
    final translationFuture = _performTranslation(
      text,
      targetLang,
      sourceLanguage,
      timeout ?? const Duration(seconds: 10),
    );
    _pendingTranslations[cacheKey] = translationFuture;
    try {
      final result = await translationFuture;
      if (useCache) {
        _addToMemoryCache(cacheKey, result);
      }
      // Store original text mapping for back-translation
      if (targetLang != 'en' && sourceLanguage == 'en') {
        _originalTexts[result] = text;
      }
      return result;
    } finally {
      _pendingTranslations.remove(cacheKey);
    }
  }

  /// Optimized batch translation with intelligent batching
  Future<Map<String, String>> translateBatch(
      List<String> texts, {
        String? targetLanguage,
        String sourceLanguage = 'auto',
        bool useCache = true,
      }) async {
    if (texts.isEmpty) return {};
    final targetLang = targetLanguage ?? currentLanguage?.code ?? 'en';
    final results = <String, String>{};
    final textsToTranslate = <String>[];
    // Handle English target language with original text lookup
    if (targetLang == 'en') {
      for (final text in texts) {
        if (text.trim().isEmpty) {
          results[text] = text;
          continue;
        }
        final storedOriginal = _originalTexts[text];
        if (storedOriginal != null) {
          results[text] = storedOriginal;
          continue;
        }
        textsToTranslate.add(text);
      }
    } else {
      // Check cache for each text
      for (final text in texts) {
        if (text.trim().isEmpty) {
          results[text] = text;
          continue;
        }
        if (useCache) {
          final cacheKey = _generateCacheKey(text, sourceLanguage, targetLang);
          final cached = _getFromMemoryCache(cacheKey);
          if (cached != null) {
            results[text] = cached;
            continue;
          }
        }
        textsToTranslate.add(text);
      }
    }
    // Translate remaining texts
    if (textsToTranslate.isNotEmpty) {
      try {
        // Adjust source language for back-translation to English
        String actualSourceLang = sourceLanguage;
        if (targetLang == 'en' &&
            sourceLanguage == 'auto' &&
            _previousLanguage.value != null) {
          actualSourceLang = _previousLanguage.value!.code;
        }
        final translationResults =
        await TranslationService.instance.translateBatch(
          texts: textsToTranslate,
          targetLanguage: targetLang,
          sourceLanguage: actualSourceLang,
          batchSize: _batchSize,
          delayBetweenBatches: const Duration(milliseconds: 100),
        );
        // Process results and cache them
        translationResults.forEach((original, result) {
          results[original] = result.text;
          if (useCache) {
            final cacheKey =
            _generateCacheKey(original, actualSourceLang, targetLang);
            _addToMemoryCache(cacheKey, result.text);
          }
          // Store original text mapping for back-translation
          if (targetLang != 'en' && actualSourceLang == 'en') {
            _originalTexts[result.text] = original;
          }
        });
      } catch (e) {
        // Fallback to original texts on error
        for (final text in textsToTranslate) {
          results[text] = text;
        }
      }
    }
    return results;
  }

  /// Queue text for batch translation (for widgets)
  Future<String> queueTranslation(
      String text, {
        String? targetLanguage,
        String sourceLanguage = 'auto',
        String? originalText,
      }) async {
    if (text.trim().isEmpty) return text;
    final targetLang = targetLanguage ?? currentLanguage?.code ?? 'en';
    // Handle translation to English
    if (targetLang == 'en') {
      final storedOriginal = _originalTexts[text];
      if (storedOriginal != null) {
        return storedOriginal;
      }
      if (originalText != null) {
        _originalTexts[text] = originalText;
        return originalText;
      }
      // Adjust source language for back-translation
      if (sourceLanguage == 'auto' && _previousLanguage.value != null) {
        sourceLanguage = _previousLanguage.value!.code;
      }
    }
    // If source and target are the same, return original
    if (sourceLanguage == targetLang && targetLang != 'auto') {
      return text;
    }
    final cacheKey = _generateCacheKey(text, sourceLanguage, targetLang);
    // Check cache first
    final cached = _getFromMemoryCache(cacheKey);
    if (cached != null) return cached;
    // Create completer for this request
    final completer = Completer<String>();
    // Add to batch queue
    _batchQueue.add(_BatchRequest(
      text: text,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLang,
      completer: completer,
      cacheKey: cacheKey,
      originalText: originalText,
    ));
    // Setup batch processing timer
    _batchTimer?.cancel();
    _batchTimer = Timer(_batchDelay, _processBatchQueue);
    return completer.future;
  }

  /// Process queued translations in batches
  Future<void> _processBatchQueue() async {
    if (_batchQueue.isEmpty) return;
    final batch = _batchQueue.take(_batchSize).toList();
    _batchQueue.removeRange(0, batch.length.clamp(0, _batchQueue.length));
    try {
      final textsToTranslate = batch.map((req) => req.text).toList();
      final targetLang = batch.first.targetLanguage;
      String sourceLang = batch.first.sourceLanguage;
      // Adjust source language for back-translation to English
      if (targetLang == 'en' &&
          sourceLang == 'auto' &&
          _previousLanguage.value != null) {
        sourceLang = _previousLanguage.value!.code;
      }
      final results = await TranslationService.instance.translateBatch(
        texts: textsToTranslate,
        targetLanguage: targetLang,
        sourceLanguage: sourceLang,
      );
      // Complete all requests
      for (final request in batch) {
        final result = results[request.text];
        if (result != null) {
          _addToMemoryCache(request.cacheKey, result.text);
          // Store original text mapping
          if (targetLang != 'en' && sourceLang == 'en') {
            _originalTexts[result.text] = request.text;
          } else if (targetLang == 'en' && request.originalText != null) {
            _originalTexts[request.text] = request.originalText!;
          }
          request.completer.complete(result.text);
        } else {
          request.completer.complete(request.text);
        }
      }
    } catch (e) {
      // Complete with original text on error
      for (final request in batch) {
        request.completer.complete(request.text);
      }
    }
    // Process remaining queue
    if (_batchQueue.isNotEmpty) {
      _batchTimer = Timer(_batchDelay, _processBatchQueue);
    }
  }

  /// Clear all caches
  Future<void> clearCache() async {
    _memoryCache.clear();
    _originalTexts.clear(); // Clear original text mappings too
    await TranslationService.instance.clearCache();
    await _updateCacheStats();
    _showSuccess('Cache cleared successfully');
  }

  /// Clear original text mappings (useful when switching languages)
  void clearOriginalTexts() {
    _originalTexts.clear();
  }

  Future<String> _performTranslation(
      String text,
      String targetLang,
      String sourceLanguage,
      Duration timeout,
      ) async {
    try {
      final result = await TranslationService.instance
          .translate(
        text: text,
        targetLanguage: targetLang,
        sourceLanguage: sourceLanguage,
      )
          .timeout(timeout);
      return result.text;
    } catch (e) {
      return text; // Fallback to original text
    }
  }

  String _generateCacheKey(String text, String sourceLang, String targetLang) {
    return '${sourceLang}_${targetLang}_${text.hashCode}';
  }

  String? _getFromMemoryCache(String key) {
    final cached = _memoryCache[key];
    if (cached != null && !cached.isExpired) {
      return cached.text;
    }
    if (cached != null && cached.isExpired) {
      _memoryCache.remove(key);
    }
    return null;
  }

  void _addToMemoryCache(String key, String text) {
    // Manage cache size
    if (_memoryCache.length >= _maxCacheSize) {
      _cleanOldestCacheEntries();
    }
    _memoryCache[key] = _CachedTranslation(
      text: text,
      timestamp: DateTime.now(),
      expiry: DateTime.now().add(_cacheExpiry),
    );
  }

  void _cleanOldestCacheEntries() {
    final entries = _memoryCache.entries.toList();
    entries.sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));
    final toRemove = entries.take(_maxCacheSize ~/ 4);
    for (final entry in toRemove) {
      _memoryCache.remove(entry.key);
    }
  }

  void _clearLanguageCache(String languageCode) {
    final keysToRemove = _memoryCache.keys
        .where((key) => key.contains('_${languageCode}_'))
        .toList();
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
    }
    // Also clear original texts when changing language
    if (languageCode == 'en') {
      _originalTexts.clear();
    }
  }

  void _setupCacheCleanup() {
    Timer.periodic(const Duration(minutes: 30), (timer) {
      final now = DateTime.now();
      final expiredKeys = _memoryCache.entries
          .where((entry) => now.isAfter(entry.value.expiry))
          .map((entry) => entry.key)
          .toList();
      for (final key in expiredKeys) {
        _memoryCache.remove(key);
      }
    });
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString('selected_language') ?? 'en';
      final savedLanguage = SupportedLanguages.findByCode(savedLanguageCode);
      if (savedLanguage != null) {
        _currentLanguage.value = savedLanguage;
      } else {
        _currentLanguage.value = SupportedLanguages.defaultLanguage;
      }
    } catch (e) {
      _currentLanguage.value = SupportedLanguages.defaultLanguage;
    }
  }

  Future<void> _saveLanguagePreference(Language language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', language.code);
    } catch (e) {
      debugPrint('Failed to save language preference: $e');
    }
  }

  Future<void> _preloadCommonTranslations(String languageCode) async {
    final commonTexts = ['Welcome', /* Add more common texts here */];
    try {
      await translateBatch(commonTexts, targetLanguage: languageCode);
    } catch (e) {
      debugPrint('Failed to preload common translations: $e');
    }
  }

  Future<void> _updateCacheStats() async {
    try {
      final serviceStats = await TranslationService.instance.getCacheStats();
      _cacheStats.value = {
        ...serviceStats,
        'memoryCache': _memoryCache.length,
        'originalTexts': _originalTexts.length,
        'pendingTranslations': _pendingTranslations.length,
        'batchQueue': _batchQueue.length,
      };
    } catch (e) {
      _cacheStats.value = {
        'error': e.toString(),
        'memoryCache': _memoryCache.length,
        'originalTexts': _originalTexts.length,
        'pendingTranslations': _pendingTranslations.length,
        'batchQueue': _batchQueue.length,
      };
    }
  }

  void _showSuccess(String message) {
    if (Get.context != null) {
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(8),
      );
    }
  }

  void _showError(String message) {
    if (Get.context != null) {
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
      );
    }
  }
}

/// Cached translation with expiry
class _CachedTranslation {
  final String text;
  final DateTime timestamp;
  final DateTime expiry;

  _CachedTranslation({
    required this.text,
    required this.timestamp,
    required this.expiry,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// Batch request for queued translations
class _BatchRequest {
  final String text;
  final String sourceLanguage;
  final String targetLanguage;
  final Completer<String> completer;
  final String cacheKey;
  final String? originalText; // Added for back-translation

  _BatchRequest({
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.completer,
    required this.cacheKey,
    this.originalText,
  });
}


