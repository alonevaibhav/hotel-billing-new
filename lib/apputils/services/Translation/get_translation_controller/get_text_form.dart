import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'get_translation_controller.dart';

class GetTranslatableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  // Translation specific properties
  final String? targetLanguage;
  final String sourceLanguage;
  final bool enableTranslation;
  final Widget? loadingWidget;
  final Duration debounceDelay;
  final bool useQueuedTranslation;
  final bool enableCache;
  final VoidCallback? onTranslationComplete;
  final Function(String error)? onTranslationError;

  const GetTranslatableText(
    this.text, {
    Key? key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.targetLanguage,
    this.sourceLanguage = 'en', // Changed default to 'en' instead of 'auto'
    this.enableTranslation = true,
    this.loadingWidget,
    this.debounceDelay = const Duration(milliseconds: 200),
    this.useQueuedTranslation = true,
    this.enableCache = true,
    this.onTranslationComplete,
    this.onTranslationError,
  }) : super(key: key);

  @override
  State<GetTranslatableText> createState() => _GetTranslatableTextState();
}

class _GetTranslatableTextState extends State<GetTranslatableText> {
  final RxString _displayText = ''.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  Timer? _debounceTimer;
  String? _lastTranslationKey;
  String? _originalText; // Store the original English text

  @override
  void initState() {
    super.initState();
    // Store original text if source language is English
    if (widget.sourceLanguage == 'en') {
      _originalText = widget.text;
    }
    _displayText.value = widget.text;
    _performTranslation();
  }

  @override
  void didUpdateWidget(GetTranslatableText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update original text if source language is English
    if (widget.sourceLanguage == 'en' && widget.text != oldWidget.text) {
      _originalText = widget.text;
    }

    if (oldWidget.text != widget.text ||
        oldWidget.targetLanguage != widget.targetLanguage ||
        oldWidget.enableTranslation != widget.enableTranslation ||
        oldWidget.sourceLanguage != widget.sourceLanguage) {
      _displayText.value = widget.text;
      _performTranslation();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _performTranslation() {
    if (!widget.enableTranslation ||
        widget.text.trim().isEmpty ||
        !Get.isRegistered<TranslationController>()) {
      _displayText.value = widget.text;
      _isLoading.value = false;
      _hasError.value = false;
      return;
    }

    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Debounce translation requests
    _debounceTimer = Timer(widget.debounceDelay, () async {
      if (!mounted) return;

      final controller = TranslationController.instance;
      if (!controller.isInitialized) {
        _displayText.value = widget.text;
        _isLoading.value = false;
        _hasError.value = false;
        return;
      }

      final targetLang =
          widget.targetLanguage ?? controller.currentLanguage?.code ?? 'en';

      // If target language is same as source, no translation needed
      if (targetLang == widget.sourceLanguage) {
        _displayText.value = widget.text;
        _isLoading.value = false;
        _hasError.value = false;
        return;
      }

      // Generate translation key for deduplication
      final translationKey =
          '${widget.sourceLanguage}_${targetLang}_${widget.text}';
      if (_lastTranslationKey == translationKey && !_hasError.value) {
        return; // Skip if same translation already processed
      }

      _lastTranslationKey = translationKey;

      _isLoading.value = true;
      _hasError.value = false;

      try {
        String translatedText;

        if (widget.useQueuedTranslation) {
          // Use queued translation for better batching
          translatedText = await controller.queueTranslation(
            widget.text,
            targetLanguage: targetLang,
            sourceLanguage: widget.sourceLanguage,
            originalText:
                _originalText, // Pass original text for back-translation
          );
        } else {
          // Use direct translation
          translatedText = await controller.translateText(
            widget.text,
            targetLanguage: targetLang,
            sourceLanguage: widget.sourceLanguage,
            useCache: widget.enableCache,
            originalText:
                _originalText, // Pass original text for back-translation
          );
        }

        if (mounted) {
          _displayText.value = translatedText;
          _isLoading.value = false;
          _hasError.value = false;

          widget.onTranslationComplete?.call();
        }
      } catch (e) {
        if (mounted) {
          _displayText.value = widget.text; // Fallback to original
          _isLoading.value = false;
          _hasError.value = true;

          widget.onTranslationError?.call(e.toString());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // This makes the widget reactive to language changes
      final controller = Get.find<TranslationController>();
      final currentLang = controller.currentLanguage;

      // Trigger translation when language changes
      if (widget.enableTranslation &&
          currentLang != null &&
          widget.text.trim().isNotEmpty) {
        final newTargetLang = widget.targetLanguage ?? currentLang.code;
        final newTranslationKey =
            '${widget.sourceLanguage}_${newTargetLang}_${widget.text}';

        // Only retranslate if language actually changed
        if (_lastTranslationKey != newTranslationKey) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _performTranslation();
          });
        }
      }

      // Show loading widget if specified and currently loading
      if (_isLoading.value && widget.loadingWidget != null) {
        return widget.loadingWidget!;
      }

      return Text(
        _displayText.value,
        key: widget.key,
        style: widget.style,
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        locale: widget.locale,
        softWrap: widget.softWrap,
        overflow: widget.overflow,
        textScaleFactor: widget.textScaleFactor,
        maxLines: widget.maxLines,
        semanticsLabel: widget.semanticsLabel,
        textWidthBasis: widget.textWidthBasis,
        textHeightBehavior: widget.textHeightBehavior,
        selectionColor: widget.selectionColor,
      );
    });
  }
}
