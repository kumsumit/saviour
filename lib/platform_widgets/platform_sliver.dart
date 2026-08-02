import 'package:flutter/material.dart'
    show IconButton, Icons, SliverAppBar, kToolbarHeight;
import 'package:flutter/widgets.dart';
import 'package:saviour/platform_widgets/platform_form.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';

// ---------------------------------------------------------------------------
// Sliver utilities
// ---------------------------------------------------------------------------

/// A [SliverPersistentHeaderDelegate] that pins a fixed-height child.
/// Replaces the old `SliverAppBarDelegate` from `custom_sliver_delegate.dart`.
class PlatformSliverDelegate extends SliverPersistentHeaderDelegate {
  const PlatformSliverDelegate({
    required this.child,
    required this.height,
  });

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;

  @override
  bool shouldRebuild(PlatformSliverDelegate old) =>
      height != old.height || child != old.child;
}

// ---------------------------------------------------------------------------
// Home-screen sliver widgets
// ---------------------------------------------------------------------------

/// A [SliverAppBar] showing a delivery location + estimated time, with an
/// optional profile icon action.
class PlatformDeliveryAppBar extends StatelessWidget {
  const PlatformDeliveryAppBar({
    super.key,
    required this.location,
    required this.deliveryTime,
    this.onProfileTap,
    this.toolbarHeight = kToolbarHeight + 10,
  });

  final String location;
  final String deliveryTime;
  final VoidCallback? onProfileTap;
  final double toolbarHeight;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return SliverAppBar(
      backgroundColor: theme.surface,
      automaticallyImplyLeading: false,
      toolbarHeight: toolbarHeight,
      actions: [
        if (onProfileTap != null)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: theme.onSurface),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(Icons.person, color: theme.onSurface, size: 20),
            ),
            onPressed: onProfileTap,
          ),
      ],
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'DELIVERY IN $location',
              maxLines: 1,
              style: theme.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              deliveryTime,
              maxLines: 1,
              style: theme.text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// A pinned sliver search bar — wraps [PlatformTextField] in a
/// [SliverPersistentHeader] so it sticks below the app bar while scrolling.
class PlatformSliverSearchBar extends StatelessWidget {
  const PlatformSliverSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.height = kToolbarHeight,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return SliverPersistentHeader(
      pinned: true,
      delegate: PlatformSliverDelegate(
        height: height,
        child: ColoredBox(
          color: theme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            // Reuses PlatformTextField so the input field is native on each platform.
            child: PlatformTextField(
              controller: controller,
              placeholder: hintText,
              prefix: Icon(Icons.search, color: theme.onSurfaceVariant, size: 20),
              onChanged: onChanged,
              onSubmitted: onSubmitted,
            ),
          ),
        ),
      ),
    );
  }
}

/// A banner carousel sliver — horizontal page view of arbitrary widgets.
///
/// Typical use: pass [itemBuilder] returning `Image.asset` or `Image.network`
/// items. The carousel uses natural page physics.
class PlatformBannerCarousel extends StatelessWidget {
  const PlatformBannerCarousel({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.height = 220,
    this.itemMargin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double height;
  final EdgeInsetsGeometry itemMargin;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return SliverToBoxAdapter(
      child: SizedBox(
        height: height,
        child: PageView.builder(
          itemCount: itemCount,
          itemBuilder: (context, index) => Container(
            margin: itemMargin,
            decoration: BoxDecoration(
              color: theme.surfaceContainer,
              borderRadius: BorderRadius.circular(theme.surfaceRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: itemBuilder(context, index),
          ),
        ),
      ),
    );
  }
}

/// A sliver grid of category tiles, fixed at [crossAxisCount] columns.
///
/// Pass [itemBuilder] returning [PlatformCategoryTile] (or any widget).
class PlatformCategoryGrid extends StatelessWidget {
  const PlatformCategoryGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 4,
    this.childAspectRatio = 0.65,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) => SliverGrid(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
    ),
    delegate: SliverChildBuilderDelegate(itemBuilder, childCount: itemCount),
  );
}

/// A sliver section: a bold title followed by a horizontally scrolling row of
/// items (e.g. products in a category). Replaces `CatgorywithProducts`.
class PlatformHorizontalSection extends StatelessWidget {
  const PlatformHorizontalSection({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    this.rowHeight = 240,
    this.titleStyle,
  });

  final String title;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double rowHeight;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Text(
              title,
              style: titleStyle ??
                  theme.text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: rowHeight,
            child: ListView.builder(
              itemCount: itemCount,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: itemBuilder,
            ),
          ),
        ],
      ),
    );
  }
}
