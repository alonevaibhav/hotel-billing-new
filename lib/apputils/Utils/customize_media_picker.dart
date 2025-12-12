import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../app/core/constants/color_constant.dart';
import '../services/Translation/get_translation_controller/get_text_form.dart';
import '../services/Translation/get_translation_controller/get_translation_controller.dart';

class ImagePickerUtil {
  static const double sizeFactor = 0.75; // Size constant variable


  /// Build File Upload Field - Clean version for views
  static Widget buildFileUploadField({
    required String label,
    required String hint,
    required IconData icon,
    required RxList<String> uploadedFiles,
    required Function(List<String>) onFilesSelected,
    bool isRequired = false,
  }) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        buildTranslatableText(
          text: label,
          style: GoogleFonts.poppins(
            fontSize: 16.sp * sizeFactor,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Gap(8.h * sizeFactor),

        // Upload Button
        _buildUploadButton(
          icon: icon,
          hint: hint,
          uploadedFiles: uploadedFiles,
          onTap: () => _showFileUploadDialog(
            onFilesSelected: onFilesSelected,
          ),
        ),

        // Show uploaded files list
        if (uploadedFiles.isNotEmpty) ...[
          Gap(12.h * sizeFactor),
          _buildUploadedFilesList(uploadedFiles),
        ],
      ],
    ));
  }

  /// Build Section Header - Clean version
  static Widget buildSectionHeader({
    required String title,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w * sizeFactor,
        vertical: 12.h * sizeFactor,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r * sizeFactor),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryLight,
            size: 20.sp * sizeFactor,
          ),
          Gap(8.w * sizeFactor),
          buildTranslatableText(
            text: title,
            style: GoogleFonts.poppins(
              fontSize: 16.sp * sizeFactor,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }

  // ===== PRIVATE HELPER METHODS =====

  /// Build Upload Button
  static Widget _buildUploadButton({
    required IconData icon,
    required String hint,
    required RxList<String> uploadedFiles,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r * sizeFactor),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 16.w * sizeFactor,
          vertical: 16.h * sizeFactor,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12.r * sizeFactor),
          border: Border.all(
            color: uploadedFiles.isEmpty
                ? AppColors.lightColor.withOpacity(0.3)
                : AppColors.primaryLight.withOpacity(0.5),
            width: uploadedFiles.isEmpty ? 1 : 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primaryLight,
              size: 20.w * sizeFactor,
            ),
            Gap(12.w * sizeFactor),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTranslatableText(
                    text: uploadedFiles.isEmpty
                        ? hint
                        : '${uploadedFiles.length} file${uploadedFiles.length > 1 ? 's' : ''} selected',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp * sizeFactor,
                      color: uploadedFiles.isEmpty
                          ? AppColors.textSecondary
                          : AppColors.primaryLight,
                      fontWeight: uploadedFiles.isEmpty
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  ),
                  if (uploadedFiles.isNotEmpty) ...[
                    Gap(4.h * sizeFactor),
                    buildTranslatableText(
                      text: 'Tap to change files',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp * sizeFactor,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              uploadedFiles.isEmpty
                  ? PhosphorIcons.plus(PhosphorIconsStyle.regular)
                  : PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
              color: uploadedFiles.isEmpty
                  ? AppColors.textSecondary
                  : AppColors.primaryLight,
              size: 20.w * sizeFactor,
            ),
          ],
        ),
      ),
    );
  }

  /// Build Uploaded Files List
  static Widget _buildUploadedFilesList(RxList<String> uploadedFiles) {
    return Container(
      padding: EdgeInsets.all(12.w * sizeFactor),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r * sizeFactor),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.files(PhosphorIconsStyle.regular),
                color: AppColors.primaryLight,
                size: 16.w * sizeFactor,
              ),
              Gap(8.w * sizeFactor),
              buildTranslatableText(
                text: 'Uploaded Files',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp * sizeFactor,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => uploadedFiles.clear(),
                child: Container(
                  padding: EdgeInsets.all(4.w * sizeFactor),
                  child: Icon(
                    PhosphorIcons.trash(PhosphorIconsStyle.regular),
                    color: AppColors.error,
                    size: 16.w * sizeFactor,
                  ),
                ),
              ),
            ],
          ),
          Gap(8.h * sizeFactor),
          ...uploadedFiles.map((filePath) => _buildFileItem(filePath)).toList(),
        ],
      ),
    );
  }

  /// Build File Item
  static Widget _buildFileItem(String filePath) {
    final fileName = filePath.split('/').last;
    final isImage = _isImageFile(fileName);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h * sizeFactor),
      child: Row(
        children: [
          Icon(
            isImage
                ? PhosphorIcons.image(PhosphorIconsStyle.regular)
                : PhosphorIcons.file(PhosphorIconsStyle.regular),
            color: AppColors.textSecondary,
            size: 16.w * sizeFactor,
          ),
          Gap(8.w * sizeFactor),
          Expanded(
            child: Text(
              fileName,
              style: GoogleFonts.poppins(
                fontSize: 12.sp * sizeFactor,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Check if file is image
  static bool _isImageFile(String fileName) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    final extension = fileName.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  /// Show File Upload Dialog - Simplified version
  static void _showFileUploadDialog({
    required Function(List<String>) onFilesSelected,
  }) {
    showMediaPicker(
      context: Get.context!,
      title: 'Select Files',
      onImagesSelected: (imagePaths) {
        onFilesSelected(imagePaths);
      },
      onDocumentsSelected: (documentPaths) {
        onFilesSelected(documentPaths);
      },
      maxFileSize: 50, // 50MB limit
    );
  }

  /// Show Media Picker Bottom Sheet
  static Future<void> showMediaPicker({
    required BuildContext context,
    Function(List<String> imagePaths)? onImagesSelected,
    Function(List<String> documentPaths)? onDocumentsSelected,
    String title = 'Upload Media',
    int? maxFileSize = 50, // in MB
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMediaPickerSheet(
        context: context,
        onImagesSelected: onImagesSelected,
        onDocumentsSelected: onDocumentsSelected,
        title: title,
        maxFileSize: maxFileSize,
      ),
    );
  }

  /// Media Picker Bottom Sheet UI - Simplified
  static Widget _buildMediaPickerSheet({
    required BuildContext context,
    Function(List<String> imagePaths)? onImagesSelected,
    Function(List<String> documentPaths)? onDocumentsSelected,
    String title = 'Upload Media',
    int? maxFileSize = 50,
  }) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r * sizeFactor)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h * sizeFactor),
            width: 40.w * sizeFactor,
            height: 4.h * sizeFactor,
            decoration: BoxDecoration(
              color: AppColors.lightColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r * sizeFactor),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.all(20.w * sizeFactor),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.upload(PhosphorIconsStyle.fill),
                  color: AppColors.primaryLight,
                  size: 24.w * sizeFactor,
                ),
                Gap(12.w * sizeFactor),
                Expanded(
                  child: buildTranslatableText(
                    text: title,
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp * sizeFactor,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(20.r * sizeFactor),
                  child: Container(
                    padding: EdgeInsets.all(8.w * sizeFactor),
                    child: Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 20.w * sizeFactor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w * sizeFactor),
              child: Column(
                children: [
                  // Photos Section
                  _buildSectionHeader('Photos', PhosphorIcons.camera(PhosphorIconsStyle.fill)),
                  Gap(12.h * sizeFactor),

                  _buildMediaOptionTile(
                    icon: PhosphorIcons.camera(PhosphorIconsStyle.fill),
                    title: 'Take Photo',
                    subtitle: 'Capture a new photo',
                    onTap: () => _pickImage(context, ImageSource.camera, onImagesSelected),
                  ),

                  Gap(8.h * sizeFactor),

                  _buildMediaOptionTile(
                    icon: PhosphorIcons.image(PhosphorIconsStyle.fill),
                    title: 'Photo Gallery',
                    subtitle: 'Choose from gallery',
                    onTap: () => _pickImage(context, ImageSource.gallery, onImagesSelected),
                  ),

                  Gap(24.h * sizeFactor),

                  // Documents Section
                  _buildSectionHeader('Documents', PhosphorIcons.fileText(PhosphorIconsStyle.fill)),
                  Gap(12.h * sizeFactor),

                  _buildMediaOptionTile(
                    icon: PhosphorIcons.filePdf(PhosphorIconsStyle.fill),
                    title: 'PDF Files',
                    subtitle: 'Select PDF documents',
                    iconColor: Colors.red.shade600,
                    onTap: () => _pickDocuments(context, ['pdf'], onDocumentsSelected, maxFileSize),
                  ),

                  Gap(8.h * sizeFactor),

                  _buildMediaOptionTile(
                    icon: PhosphorIcons.fileDoc(PhosphorIconsStyle.fill),
                    title: 'Word Documents',
                    subtitle: 'DOC, DOCX files',
                    iconColor: Colors.blue.shade600,
                    onTap: () => _pickDocuments(context, ['doc', 'docx'], onDocumentsSelected, maxFileSize),
                  ),

                  Gap(24.h * sizeFactor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section Header for Media Picker
  static Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w * sizeFactor),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r * sizeFactor),
          ),
          child: Icon(icon, color: AppColors.primaryLight, size: 20.w * sizeFactor),
        ),
        Gap(12.w * sizeFactor),
        buildTranslatableText(
          text: title,
          style: GoogleFonts.poppins(
            fontSize: 16.sp * sizeFactor,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryLight,
          ),
        ),
        Expanded(
          child: Container(
            height: 1.h * sizeFactor,
            margin: EdgeInsets.only(left: 12.w * sizeFactor),
            color: AppColors.primaryLight.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  /// Media Option Tile
  static Widget _buildMediaOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r * sizeFactor),
        border: Border.all(color: AppColors.lightColor.withOpacity(0.3)),
        color: AppColors.background,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r * sizeFactor),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.w * sizeFactor),
          child: Row(
            children: [
              Container(
                width: 48.w * sizeFactor,
                height: 48.h * sizeFactor,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primaryLight).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r * sizeFactor),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.primaryLight,
                  size: 24.w * sizeFactor,
                ),
              ),
              Gap(16.w * sizeFactor),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTranslatableText(
                      text: title,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp * sizeFactor,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Gap(4.h * sizeFactor),
                    buildTranslatableText(
                      text: subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp * sizeFactor,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.regular),
                size: 16.w * sizeFactor,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pick Single Image
  static Future<void> _pickImage(
      BuildContext context,
      ImageSource source,
      Function(List<String> imagePaths)? onImagesSelected,
      ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        Navigator.of(context).pop();
        onImagesSelected?.call([image.path]);
        _showSuccessMessage('Photo added successfully');
      }
    } catch (e) {
      _showErrorMessage('Failed to pick image: $e');
    }
  }

  /// Pick Documents
  static Future<void> _pickDocuments(
      BuildContext context,
      List<String> allowedExtensions,
      Function(List<String> documentPaths)? onDocumentsSelected,
      int? maxFileSize,
      ) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result != null) {
        List<String> filePaths = result.paths.where((path) => path != null).cast<String>().toList();

        // Check file sizes
        if (maxFileSize != null) {
          for (String path in filePaths) {
            final file = File(path);
            final fileSize = await file.length();
            if (fileSize > (maxFileSize * 1024 * 1024)) {
              _showErrorMessage('Some files exceed the ${maxFileSize}MB limit');
              return;
            }
          }
        }

        if (filePaths.isNotEmpty) {
          Navigator.of(context).pop();
          onDocumentsSelected?.call(filePaths);
          _showSuccessMessage('${filePaths.length} ${filePaths.length == 1 ? 'document' : 'documents'} added successfully');
        }
      }
    } catch (e) {
      _showErrorMessage('Failed to pick documents: $e');
    }
  }

  /// Show Success Message
  static void _showSuccessMessage(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primaryLight,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w * sizeFactor),
      borderRadius: 12.r * sizeFactor,
      icon: Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: Colors.white),
    );
  }

  /// Show Error Message
  static void _showErrorMessage(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      margin: EdgeInsets.all(16.w * sizeFactor),
      borderRadius: 12.r * sizeFactor,
      icon: Icon(PhosphorIcons.warning(PhosphorIconsStyle.fill), color: Colors.white),
    );
  }

  static Widget buildTranslatableText({
    required String text,
    required TextStyle style,
    String sourceLanguage = 'en',
    String? targetLanguage,
    bool enableTranslation = true,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Widget? loadingWidget,
  }) {
    // Check if TranslationController is registered before using it
    if (!Get.isRegistered<TranslationController>()) {
      return Text(text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow);
    }

    return GetBuilder<TranslationController>(
      builder: (controller) {
        // Use a unique key that includes the language to force rebuilds when language changes
        final currentLang = controller.currentLanguage?.code ?? 'en';
        final key = Key('${text}_${sourceLanguage}_${currentLang}');

        return GetTranslatableText(
          text,
          key: key,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          enableTranslation: enableTranslation,
          loadingWidget: loadingWidget ??
              SizedBox(
                height: style.fontSize ?? 16,
                width: 20.w * sizeFactor,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  color: style.color ?? AppColors.primaryLight,
                ),
              ),
          useQueuedTranslation: true,
          enableCache: true,
          debounceDelay: const Duration(milliseconds: 150),
        );
      },
    );
  }

}