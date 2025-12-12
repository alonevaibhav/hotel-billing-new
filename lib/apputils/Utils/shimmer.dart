import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ScreenUtil-based responsive sizing helper
class ResponsiveSize {
  static double textHeight(BuildContext context, {TextStyle? style}) {
    final defaultStyle = style ?? Theme.of(context).textTheme.bodyMedium!;
    final textPainter = TextPainter(
      text: TextSpan(text: 'Ag', style: defaultStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.height;
  }

  // ScreenUtil responsive helpers
  static double width(double width) => width.w;
  static double height(double height) => height.h;
  static double radius(double radius) => radius.r;
  static double fontSize(double size) => size.sp;

  // Common spacing using ScreenUtil
  static double get smallSpacing => 8.w;
  static double get mediumSpacing => 16.w;
  static double get largeSpacing => 24.w;
  static double get xLargeSpacing => 32.w;
}

// Enhanced Shimmer Element with ScreenUtil support
class ShimmerElement {
  final double? width;
  final double? height;
  final double? widthSU; // ScreenUtil width
  final double? heightSU; // ScreenUtil height
  final TextStyle? textStyle; // For text-based height calculation
  final BorderRadius? borderRadius;
  final double? borderRadiusSU; // ScreenUtil border radius
  final EdgeInsets? margin;
  final EdgeInsets? marginSU; // ScreenUtil margin
  final bool isExpanded;
  final bool isFlexible;
  final int flex;

  const ShimmerElement({
    this.width,
    this.height,
    this.widthSU,
    this.heightSU,
    this.textStyle,
    this.borderRadius,
    this.borderRadiusSU,
    this.margin,
    this.marginSU,
    this.isExpanded = false,
    this.isFlexible = false,
    this.flex = 1,
  });

  // ScreenUtil-based helper constructors
  factory ShimmerElement.box({
    double? width,
    double? height,
    double? widthSU,
    double? heightSU,
    BorderRadius? borderRadius,
    double? borderRadiusSU,
    EdgeInsets? margin,
    EdgeInsets? marginSU,
  }) => ShimmerElement(
    width: width,
    height: height,
    widthSU: widthSU,
    heightSU: heightSU,
    borderRadius: borderRadius,
    borderRadiusSU: borderRadiusSU,
    margin: margin,
    marginSU: marginSU,
  );

  factory ShimmerElement.circle({
    double? size,
    double? sizeSU, // ScreenUtil size
    EdgeInsets? margin,
    EdgeInsets? marginSU,
  }) => ShimmerElement(
    width: size,
    height: size,
    widthSU: sizeSU,
    heightSU: sizeSU,
    borderRadius: null, // Will be calculated as circular
    margin: margin,
    marginSU: marginSU,
  );

  // FIXED: Added heightSU parameter to text factory constructor
  factory ShimmerElement.text({
    double? width,
    double? widthSU,
    double? height,
    double? heightSU,
    TextStyle? style,
    EdgeInsets? margin,
    EdgeInsets? marginSU,
  }) => ShimmerElement(
    width: width,
    height: height,
    widthSU: widthSU,
    heightSU: heightSU,
    textStyle: style,
    borderRadiusSU: 4,
    margin: margin,
    marginSU: marginSU,
  );

  // Fixed expanded constructor - provide default height
  factory ShimmerElement.expanded({
    double? height,
    double? heightSU,
    TextStyle? style,
    EdgeInsets? margin,
    EdgeInsets? marginSU,
    int flex = 1,
  }) => ShimmerElement(
    height: height ?? 16, // Default height to prevent layout issues
    heightSU: heightSU,
    textStyle: style,
    isExpanded: true,
    flex: flex,
    margin: margin,
    marginSU: marginSU,
  );

  factory ShimmerElement.flexible({
    double? width,
    double? widthSU,
    double? height,
    double? heightSU,
    TextStyle? style,
    EdgeInsets? margin,
    EdgeInsets? marginSU,
    int flex = 1,
  }) => ShimmerElement(
    width: width,
    widthSU: widthSU,
    height: height ?? 16, // Default height
    heightSU: heightSU,
    textStyle: style,
    isFlexible: true,
    flex: flex,
    margin: margin,
    marginSU: marginSU,
  );

  // Calculate responsive dimensions using ScreenUtil
  double? getWidth(BuildContext context) {
    if (widthSU != null) return widthSU!.w;
    return width;
  }

  double getHeight(BuildContext context) {
    if (heightSU != null) return heightSU!.h;
    if (textStyle != null) {
      return ResponsiveSize.textHeight(context, style: textStyle);
    }
    // Always return a valid height to prevent layout issues
    return height ?? 16.h;
  }

  BorderRadius getBorderRadius(BuildContext context) {
    if (borderRadius != null) return borderRadius!;

    if (borderRadiusSU != null) {
      return BorderRadius.all(Radius.circular(borderRadiusSU!.r));
    }

    // For circles, calculate radius based on size
    final w = getWidth(context);
    final h = getHeight(context);
    if (w != null && w == h) {
      return BorderRadius.circular(w / 2);
    }

    return BorderRadius.all(Radius.circular(8.r));
  }

  EdgeInsets getMargin(BuildContext context) {
    if (marginSU != null) return marginSU!;
    return margin ?? EdgeInsets.all(ResponsiveSize.smallSpacing);
  }
}

// Type-safe shimmer child union
abstract class ShimmerChild {}

class ShimmerElementChild extends ShimmerChild {
  final ShimmerElement element;
  ShimmerElementChild(this.element);
}

class ShimmerLayoutChild extends ShimmerChild {
  final ShimmerLayout layout;
  ShimmerLayoutChild(this.layout);
}

class ShimmerSpacerChild extends ShimmerChild {
  final double? width;
  final double? height;
  final double? widthSU;
  final double? heightSU;

  ShimmerSpacerChild({this.width, this.height, this.widthSU, this.heightSU});
}

// Enhanced Shimmer Layout with ScreenUtil support
class ShimmerLayout {
  final List<ShimmerChild> children;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets? padding;
  final EdgeInsets? paddingSU; // ScreenUtil padding

  const ShimmerLayout({
    required this.children,
    this.direction = Axis.vertical,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.padding,
    this.paddingSU,
  });

  factory ShimmerLayout.column({
    required List<ShimmerChild> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    EdgeInsets? padding,
    EdgeInsets? paddingSU,
  }) => ShimmerLayout(
    children: children,
    direction: Axis.vertical,
    mainAxisAlignment: mainAxisAlignment,
    crossAxisAlignment: crossAxisAlignment,
    padding: padding,
    paddingSU: paddingSU,
  );

  factory ShimmerLayout.row({
    required List<ShimmerChild> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    EdgeInsets? padding,
    EdgeInsets? paddingSU,
  }) => ShimmerLayout(
    children: children,
    direction: Axis.horizontal,
    mainAxisAlignment: mainAxisAlignment,
    crossAxisAlignment: crossAxisAlignment,
    padding: padding,
    paddingSU: paddingSU,
  );

  EdgeInsets getPadding(BuildContext context) {
    if (paddingSU != null) return paddingSU!;
    return padding ?? EdgeInsets.all(ResponsiveSize.mediumSpacing);
  }
}

// Helper extension methods for easier usage
extension ShimmerChildHelpers on List<ShimmerChild> {
  void addElement(ShimmerElement element) {
    add(ShimmerElementChild(element));
  }

  void addLayout(ShimmerLayout layout) {
    add(ShimmerLayoutChild(layout));
  }

  void addSpacer({double? width, double? height, double? widthSU, double? heightSU}) {
    add(ShimmerSpacerChild(
        width: width,
        height: height,
        widthSU: widthSU,
        heightSU: heightSU
    ));
  }

  void addSpacerSU(double widthSU, [double? heightSU]) {
    add(ShimmerSpacerChild(widthSU: widthSU, heightSU: heightSU));
  }
}

// Enhanced Universal Shimmer Widget
class UniversalShimmer extends StatelessWidget {
  final ShimmerLayout layout;
  final Duration period;
  final Color? baseColor;
  final Color? highlightColor;
  final EdgeInsets? cardPadding;
  final EdgeInsets? cardPaddingSU; // ScreenUtil card padding
  final EdgeInsets? cardMargin;
  final EdgeInsets? cardMarginSU; // ScreenUtil card margin
  final bool showCard;
  final int count;
  final bool isScrollable;
  final double? cardElevation;

  const UniversalShimmer({
    Key? key,
    required this.layout,
    this.period = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
    this.cardPadding,
    this.cardPaddingSU,
    this.cardMargin,
    this.cardMarginSU,
    this.showCard = true,
    this.count = 1,
    this.isScrollable = false,
    this.cardElevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = List.generate(count, (index) => _buildShimmerItem(context));

    if (isScrollable && count > 3) {
      return ListView.builder(
        itemCount: count,
        itemBuilder: (context, index) => _buildShimmerItem(context),
      );
    }

    return Column(children: items);
  }

  Widget _buildShimmerItem(BuildContext context) {
    final shimmerContent = Shimmer.fromColors(
      baseColor: baseColor ?? Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: highlightColor ?? Theme.of(context).colorScheme.surface,
      period: period,
      child: Padding(
        padding: layout.getPadding(context),
        child: _buildLayout(context, layout),
      ),
    );

    if (showCard) {
      final cardMarginValue = cardMarginSU ?? cardMargin ?? EdgeInsets.only(bottom: 12.h);
      final cardPaddingValue = cardPaddingSU ?? cardPadding ?? EdgeInsets.all(ResponsiveSize.mediumSpacing);

      return Card(
        margin: cardMarginValue,
        elevation: cardElevation ?? 2.0,
        child: Padding(
          padding: cardPaddingValue,
          child: shimmerContent,
        ),
      );
    }

    return Padding(
      padding: cardMarginSU ?? cardMargin ?? EdgeInsets.only(bottom: 12.h),
      child: shimmerContent,
    );
  }

  Widget _buildLayout(BuildContext context, ShimmerLayout layout) {
    final widgets = layout.children.map((child) => _buildChild(context, child)).toList();

    if (layout.direction == Axis.horizontal) {
      return Row(
        mainAxisAlignment: layout.mainAxisAlignment,
        crossAxisAlignment: layout.crossAxisAlignment,
        children: widgets,
      );
    } else {
      return Column(
        mainAxisAlignment: layout.mainAxisAlignment,
        crossAxisAlignment: layout.crossAxisAlignment,
        children: widgets,
      );
    }
  }

  Widget _buildChild(BuildContext context, ShimmerChild child) {
    if (child is ShimmerElementChild) {
      return _buildShimmerElement(context, child.element);
    } else if (child is ShimmerLayoutChild) {
      return _buildLayout(context, child.layout);
    } else if (child is ShimmerSpacerChild) {
      return _buildSpacer(context, child);
    }
    return const SizedBox.shrink();
  }

  Widget _buildSpacer(BuildContext context, ShimmerSpacerChild spacer) {
    final width = spacer.widthSU?.w ?? spacer.width;
    final height = spacer.heightSU?.h ?? spacer.height;

    return SizedBox(width: width, height: height);
  }

  Widget _buildShimmerElement(BuildContext context, ShimmerElement element) {
    final width = element.getWidth(context);
    final height = element.getHeight(context);
    final margin = element.getMargin(context);
    final borderRadius = element.getBorderRadius(context);

    Widget shimmerBox = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
    );

    if (element.isExpanded) {
      return Expanded(
        flex: element.flex,
        child: Container(
          height: height,
          margin: margin,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius,
          ),
        ),
      );
    }

    if (element.isFlexible) {
      return Flexible(
        flex: element.flex,
        child: shimmerBox,
      );
    }

    return shimmerBox;
  }
}

// Fixed ScreenUtil-based shimmer patterns
class ScreenUtilShimmerPatterns {
  // User profile pattern - fixed to prevent layout issues
  static ShimmerLayout userProfile() {
    final children = <ShimmerChild>[];

    children.addElement(ShimmerElement.circle(
      sizeSU: 60,
      marginSU: EdgeInsets.only(right: 16.w),
    ));

    final textColumn = <ShimmerChild>[];
    textColumn.addElement(ShimmerElement.text(
      widthSU: 160,
      heightSU: 20, // Now this parameter exists!
      marginSU: EdgeInsets.only(bottom: 8.h),
    ));
    textColumn.addElement(ShimmerElement.text(
      widthSU: 200,
      heightSU: 16, // Now this parameter exists!
      marginSU: EdgeInsets.only(bottom: 4.h),
    ));
    textColumn.addElement(ShimmerElement.text(
      widthSU: 100,
      heightSU: 14, // Now this parameter exists!
    ));

    children.addLayout(ShimmerLayout.column(children: textColumn));

    return ShimmerLayout.row(
      children: children,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  // Product card pattern - fixed
  static ShimmerLayout productCard() {
    final children = <ShimmerChild>[];

    children.addElement(ShimmerElement.box(
      heightSU: 200,
      widthSU: 360, // Fixed infinity issue
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      marginSU: EdgeInsets.only(bottom: 16.h),
    ));

    final contentColumn = <ShimmerChild>[];
    contentColumn.addElement(ShimmerElement.text(
      widthSU: 250,
      heightSU: 20,
      marginSU: EdgeInsets.only(bottom: 8.h),
    ));
    contentColumn.addElement(ShimmerElement.text(
      widthSU: 300,
      heightSU: 16,
      marginSU: EdgeInsets.only(bottom: 12.h),
    ));

    final priceRow = <ShimmerChild>[];
    priceRow.addElement(ShimmerElement.text(
      widthSU: 80,
      heightSU: 18,
    ));
    priceRow.addElement(ShimmerElement.text(
      widthSU: 100,
      heightSU: 36, // Button height
    ));

    contentColumn.addLayout(ShimmerLayout.row(
      children: priceRow,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    ));

    children.addLayout(ShimmerLayout.column(
      children: contentColumn,
      paddingSU: EdgeInsets.all(16.w),
    ));

    return ShimmerLayout.column(children: children);
  }

  // Article pattern - fixed
  static ShimmerLayout article() {
    final children = <ShimmerChild>[];

    children.addElement(ShimmerElement.box(
      widthSU: 80,
      heightSU: 80,
      marginSU: EdgeInsets.only(right: 16.w),
    ));

    final textColumn = <ShimmerChild>[];
    textColumn.addElement(ShimmerElement.text(
      widthSU: 220,
      heightSU: 18,
      marginSU: EdgeInsets.only(bottom: 8.h),
    ));
    textColumn.addElement(ShimmerElement.text(
      widthSU: 200,
      heightSU: 14,
      marginSU: EdgeInsets.only(bottom: 4.h),
    ));
    textColumn.addElement(ShimmerElement.text(
      widthSU: 120,
      heightSU: 14,
    ));

    children.addLayout(ShimmerLayout.column(children: textColumn));

    return ShimmerLayout.row(
      children: children,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  // API data list item - fixed
  static ShimmerLayout apiListItem() {
    final children = <ShimmerChild>[];

    children.addElement(ShimmerElement.circle(
      sizeSU: 40,
      marginSU: EdgeInsets.only(right: 12.w),
    ));

    final contentColumn = <ShimmerChild>[];
    contentColumn.addElement(ShimmerElement.text(
      widthSU: 220,
      heightSU: 16,
      marginSU: EdgeInsets.only(bottom: 6.h),
    ));
    contentColumn.addElement(ShimmerElement.text(
      widthSU: 180,
      heightSU: 14,
    ));

    children.addLayout(ShimmerLayout.column(children: contentColumn));

    return ShimmerLayout.row(
      children: children,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  // Stats/metrics pattern - fixed
  static ShimmerLayout statsRow() {
    final children = <ShimmerChild>[];

    for (int i = 0; i < 3; i++) {
      final statColumn = <ShimmerChild>[];
      statColumn.addElement(ShimmerElement.text(
        widthSU: 60,
        heightSU: 20,
        marginSU: EdgeInsets.only(bottom: 4.h),
      ));
      statColumn.addElement(ShimmerElement.text(
        widthSU: 80,
        heightSU: 16,
      ));

      children.addLayout(ShimmerLayout.column(
        children: statColumn,
        crossAxisAlignment: CrossAxisAlignment.center,
      ));
    }

    return ShimmerLayout.row(
      children: children,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    );
  }
}