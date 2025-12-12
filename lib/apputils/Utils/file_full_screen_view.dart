import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:gap/gap.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

class FileFullScreenView extends StatefulWidget {
  final String filePath;
  final List<String> allFiles;
  final int initialIndex;

  const FileFullScreenView({
    Key? key,
    required this.filePath,
    required this.allFiles,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<FileFullScreenView> createState() => _FileFullScreenViewState();
}

class _FileFullScreenViewState extends State<FileFullScreenView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getFileName(String filePath) {
    return filePath.split('/').last.split('\\').last;
  }

  bool _isImageFile(String fileName) {
    final extensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final lowerName = fileName.toLowerCase();
    return extensions.any((ext) => lowerName.endsWith(ext));
  }

  bool _isPdfFile(String fileName) {
    return fileName.toLowerCase().endsWith('.pdf');
  }

  bool _isWordFile(String fileName) {
    final extensions = ['.doc', '.docx'];
    final lowerName = fileName.toLowerCase();
    return extensions.any((ext) => lowerName.endsWith(ext));
  }

  Widget _buildImageViewer(String imagePath) {
    return InteractiveViewer(
      child: Center(
        child: imagePath.startsWith('http://') || imagePath.startsWith('https://')
            ? Image.network(
          imagePath,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget('Failed to load image');
          },
        )
            : Image.file(
          File(imagePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget('Failed to load image');
          },
        ),
      ),
    );
  }

  Widget _buildPdfViewer(String pdfPath, int index) {
    return Stack(
      children: [
        PDFView(
          filePath: pdfPath,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: false,
          pageFling: false,
          pageSnap: true,
          defaultPage: 0,
          fitPolicy: FitPolicy.BOTH,
          preventLinkNavigation: false,
          onRender: (pages) {
            print("PDF Rendered: $pages pages");
          },
          onError: (error) {
            print("PDF Error: $error");
          },
          onPageError: (page, error) {
            print("PDF Page Error: $page - $error");
          },
          onViewCreated: (PDFViewController pdfViewController) {
            // PDF controller ready
          },
          onPageChanged: (int? page, int? total) {
            print('PDF Page changed: ${page! + 1}/$total');
          },
        ),
        // Fixed FloatingActionButtons with unique heroTags
        Positioned(
          bottom: 20.h,
          right: 20.w,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: "zoom_in_$index", // Unique hero tag
                mini: true,
                backgroundColor: Colors.black54,
                onPressed: () {
                  // Add zoom in functionality if needed
                },
                child: Icon(PhosphorIcons.magnifyingGlassPlus(PhosphorIconsStyle.regular)),
              ),
              Gap(8.h),
              FloatingActionButton(
                heroTag: "zoom_out_$index", // Unique hero tag
                mini: true,
                backgroundColor: Colors.black54,
                onPressed: () {
                  // Add zoom out functionality if needed
                },
                child: Icon(PhosphorIcons.magnifyingGlassMinus(PhosphorIconsStyle.regular)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentViewer(String filePath) {
    final fileName = _getFileName(filePath);
    final isWord = _isWordFile(fileName);

    return Center(
      child: Container(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Icon(
                PhosphorIcons.fileDoc(PhosphorIconsStyle.regular),
                size: 64.w,
                color: Colors.blue.shade800,
              ),
            ),
            Gap(24.h),
            Text(
              fileName,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(8.h),
            Text(
              'Word Document',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade300,
              ),
            ),
            Gap(32.h),
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _openFile(filePath),
                  icon: Icon(PhosphorIcons.eye(PhosphorIconsStyle.regular)),
                  label: Text('Open with External App'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                Gap(16.h),
                OutlinedButton.icon(
                  onPressed: () => _shareFile(filePath),
                  icon: Icon(PhosphorIcons.shareNetwork(PhosphorIconsStyle.regular)),
                  label: Text('Share File'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.warningCircle(PhosphorIconsStyle.regular),
            color: Colors.white,
            size: 64.w,
          ),
          Gap(16.h),
          Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openFile(String filePath) {
    Get.snackbar(
      'File Action',
      'Opening file with external app...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _shareFile(String filePath) {
    Get.snackbar(
      'File Action',
      'Sharing file...',
      // backgroundColor: Green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.x(PhosphorIconsStyle.regular), color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.allFiles.length}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.allFiles.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final filePath = widget.allFiles[index];
          final fileName = _getFileName(filePath);
          final isImage = _isImageFile(fileName);
          final isPdf = _isPdfFile(fileName);

          if (isImage) {
            return _buildImageViewer(filePath);
          } else if (isPdf) {
            return _buildPdfViewer(filePath, index); // Pass index for unique tags
          } else {
            return _buildDocumentViewer(filePath);
          }
        },
      ),
    );
  }
}
