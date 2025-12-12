import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MediaPickerWidget extends StatelessWidget {
  final Function(List<String> imagePaths)? onImagesSelected;
  final Function(List<String> videoPaths)? onVideosSelected;
  final Function(List<String> documentPaths)? onDocumentsSelected;
  final Function(List<String> audioPaths)? onAudioSelected;
  final bool allowMultipleImages;
  final bool allowMultipleVideos;
  final bool allowMultipleDocuments;
  final bool allowMultipleAudio;
  final bool allowImages;
  final bool allowVideos;
  final bool allowDocuments;
  final bool allowAudio;
  final String title;
  final Color? primaryColor;
  final Duration? maxVideoDuration;
  final List<String>? allowedDocumentExtensions;
  final int? maxFileSize; // in MB

  const MediaPickerWidget({
    Key? key,
    this.onImagesSelected,
    this.onVideosSelected,
    this.onDocumentsSelected,
    this.onAudioSelected,
    this.allowMultipleImages = true,
    this.allowMultipleVideos = false,
    this.allowMultipleDocuments = true,
    this.allowMultipleAudio = false,
    this.allowImages = true,
    this.allowVideos = true,
    this.allowDocuments = true,
    this.allowAudio = true,
    this.title = 'Select Media',
    this.primaryColor,
    this.maxVideoDuration = const Duration(minutes: 5),
    this.allowedDocumentExtensions,
    this.maxFileSize = 50, // 50MB default
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  // Image options
                  if (allowImages) ...[
                    _buildSectionHeader('Photos', Icons.photo, Colors.blue),
                    SizedBox(height: 8.h),

                    MediaOptionTile(
                      icon: Icons.camera_alt,
                      iconColor: Colors.blue,
                      title: 'Take Photo',
                      subtitle: 'Capture a new photo',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),

                    MediaOptionTile(
                      icon: Icons.photo_library,
                      iconColor: Colors.green,
                      title: 'Photo Gallery',
                      subtitle: 'Choose from gallery',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),

                    if (allowMultipleImages)
                      MediaOptionTile(
                        icon: Icons.photo_library_outlined,
                        iconColor: Colors.orange,
                        title: 'Multiple Photos',
                        subtitle: 'Choose multiple photos',
                        onTap: () => _pickMultipleImages(),
                      ),
                  ],

                  // Divider
                  if (allowImages && (allowVideos || allowDocuments || allowAudio)) ...[
                    SizedBox(height: 16.h),
                    Divider(color: Colors.grey[300], thickness: 1),
                    SizedBox(height: 8.h),
                  ],

                  // Video options
                  if (allowVideos) ...[
                    _buildSectionHeader('Videos', Icons.videocam, Colors.red),
                    SizedBox(height: 8.h),

                    MediaOptionTile(
                      icon: Icons.videocam,
                      iconColor: Colors.red,
                      title: 'Record Video',
                      subtitle: 'Record a new video',
                      onTap: () => _pickVideo(ImageSource.camera),
                    ),

                    MediaOptionTile(
                      icon: Icons.video_library,
                      iconColor: Colors.purple,
                      title: 'Video Gallery',
                      subtitle: 'Choose from gallery',
                      onTap: () => _pickVideo(ImageSource.gallery),
                    ),
                  ],

                  // Divider
                  if (allowVideos && (allowDocuments || allowAudio)) ...[
                    SizedBox(height: 16.h),
                    Divider(color: Colors.grey[300], thickness: 1),
                    SizedBox(height: 8.h),
                  ],

                  // Document options
                  if (allowDocuments) ...[
                    _buildSectionHeader('Documents', Icons.description, Colors.indigo),
                    SizedBox(height: 8.h),

                    MediaOptionTile(
                      icon: Icons.picture_as_pdf,
                      iconColor: Colors.red.shade700,
                      title: 'PDF Files',
                      subtitle: 'Select PDF documents',
                      onTap: () => _pickDocuments(['pdf']),
                    ),

                    MediaOptionTile(
                      icon: Icons.description,
                      iconColor: Colors.blue.shade700,
                      title: 'Word Documents',
                      subtitle: 'DOC, DOCX files',
                      onTap: () => _pickDocuments(['doc', 'docx']),
                    ),

                    MediaOptionTile(
                      icon: Icons.table_chart,
                      iconColor: Colors.green.shade700,
                      title: 'Spreadsheets',
                      subtitle: 'XLS, XLSX, CSV files',
                      onTap: () => _pickDocuments(['xls', 'xlsx', 'csv']),
                    ),

                    MediaOptionTile(
                      icon: Icons.slideshow,
                      iconColor: Colors.orange.shade700,
                      title: 'Presentations',
                      subtitle: 'PPT, PPTX files',
                      onTap: () => _pickDocuments(['ppt', 'pptx']),
                    ),

                    MediaOptionTile(
                      icon: Icons.text_snippet,
                      iconColor: Colors.grey.shade700,
                      title: 'Text Files',
                      subtitle: 'TXT, RTF files',
                      onTap: () => _pickDocuments(['txt', 'rtf']),
                    ),

                    MediaOptionTile(
                      icon: Icons.folder_open,
                      iconColor: Colors.indigo,
                      title: 'All Documents',
                      subtitle: 'Any document type',
                      onTap: () => _pickDocuments(null),
                    ),
                  ],

                  // Divider
                  if (allowDocuments && allowAudio) ...[
                    SizedBox(height: 16.h),
                    Divider(color: Colors.grey[300], thickness: 1),
                    SizedBox(height: 8.h),
                  ],

                  // Audio options
                  if (allowAudio) ...[
                    _buildSectionHeader('Audio', Icons.audiotrack, Colors.deepOrange),
                    SizedBox(height: 8.h),

                    MediaOptionTile(
                      icon: Icons.music_note,
                      iconColor: Colors.deepOrange,
                      title: 'Music Files',
                      subtitle: 'MP3, WAV, AAC files',
                      onTap: () => _pickAudio(['mp3', 'wav', 'aac', 'm4a']),
                    ),

                    MediaOptionTile(
                      icon: Icons.keyboard_voice,
                      iconColor: Colors.teal,
                      title: 'Voice Records',
                      subtitle: 'All audio formats',
                      onTap: () => _pickAudio(null),
                    ),
                  ],

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Expanded(
          child: Container(
            height: 1.h,
            margin: EdgeInsets.only(left: 12.w),
            color: color.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        Get.back();
        onImagesSelected?.call([image.path]);
        _showSuccessSnackbar('Photo added successfully');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image: $e');
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        Get.back();
        onImagesSelected?.call(images.map((image) => image.path).toList());
        _showSuccessSnackbar('${images.length} photos added successfully');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick images: $e');
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: source,
        maxDuration: maxVideoDuration,
      );

      if (video != null) {
        Get.back();
        onVideosSelected?.call([video.path]);
        _showSuccessSnackbar('Video added successfully');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick video: $e');
    }
  }

  Future<void> _pickDocuments(List<String>? allowedExtensions) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultipleDocuments,
      );

      if (result != null) {
        List<String> filePaths = result.paths.where((path) => path != null).cast<String>().toList();

        // Check file sizes
        bool hasOversizedFile = false;
        if (maxFileSize != null) {
          for (String path in filePaths) {
            final file = File(path);
            final fileSize = await file.length();
            if (fileSize > (maxFileSize! * 1024 * 1024)) {
              hasOversizedFile = true;
              break;
            }
          }
        }

        if (hasOversizedFile) {
          _showErrorSnackbar('Some files exceed the ${maxFileSize}MB limit');
          return;
        }

        if (filePaths.isNotEmpty) {
          Get.back();
          onDocumentsSelected?.call(filePaths);
          _showSuccessSnackbar('${filePaths.length} ${filePaths.length == 1 ? 'document' : 'documents'} added successfully');
        }
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick documents: $e');
    }
  }

  Future<void> _pickAudio(List<String>? allowedExtensions) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.audio,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultipleAudio,
      );

      if (result != null) {
        List<String> filePaths = result.paths.where((path) => path != null).cast<String>().toList();

        if (filePaths.isNotEmpty) {
          Get.back();
          onAudioSelected?.call(filePaths);
          _showSuccessSnackbar('${filePaths.length} audio ${filePaths.length == 1 ? 'file' : 'files'} added successfully');
        }
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick audio files: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
      borderRadius: 8.r,
      icon: Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: EdgeInsets.all(16.w),
      borderRadius: 8.r,
      icon: Icon(Icons.error, color: Colors.white),
    );
  }
}

class MediaOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const MediaOptionTile({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

