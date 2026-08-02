import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru/yaru.dart' as yaru;

/// A platform-aware top-level window surface.
///
/// macOS receives its native [macos.MacosWindow]. Windows and Linux can expose
/// an optional draggable title region when custom client-side chrome is used.
class PlatformWindow extends ConsumerWidget {
  const PlatformWindow({
    super.key,
    required this.child,
    this.titleBar,
    this.backgroundColor,
    this.disableWallpaperTinting = false,
  });

  final Widget child;
  final Widget? titleBar;
  final Color? backgroundColor;
  final bool disableWallpaperTinting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(appPlatformProvider);
    final content = backgroundColor == null
        ? child
        : ColoredBox(color: backgroundColor!, child: child);

    return switch (platform) {
      AppPlatform.macos => macos.MacosWindow(
        backgroundColor: backgroundColor,
        disableWallpaperTinting: disableWallpaperTinting,
        child: content,
      ),
      AppPlatform.windows || AppPlatform.linux => Column(
        children: [
          if (titleBar != null) DragToMoveArea(child: titleBar!),
          Expanded(child: content),
        ],
      ),
      AppPlatform.ios ||
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => content,
    };
  }
}

/// A platform-aware primary/detail split view.
class PlatformSplitView extends ConsumerWidget {
  const PlatformSplitView({
    super.key,
    required this.pane,
    required this.content,
    this.initialPaneSize = 280,
    this.minPaneSize = 180,
    this.maxPaneSize = 480,
    this.minContentSize = 320,
    this.breakpoint = 700,
    this.resizable = true,
    this.onPaneSizeChanged,
  }) : assert(minPaneSize <= initialPaneSize),
       assert(initialPaneSize <= maxPaneSize);

  final Widget pane;
  final Widget content;
  final double initialPaneSize;
  final double minPaneSize;
  final double maxPaneSize;
  final double minContentSize;

  /// Below this width the detail content is shown without a side pane.
  final double breakpoint;

  final bool resizable;
  final ValueChanged<double>? onPaneSizeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) return content;

        final platform = ref.watch(appPlatformProvider);
        return switch (platform) {
          AppPlatform.macos => Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              macos.ResizablePane.noScrollBar(
                minSize: minPaneSize,
                maxSize: maxPaneSize,
                startSize: initialPaneSize,
                isResizable: resizable,
                resizableSide: macos.ResizableSide.right,
                child: pane,
              ),
              Expanded(child: content),
            ],
          ),
          AppPlatform.linux => yaru.YaruPanedView(
            pane: pane,
            page: content,
            layoutDelegate: resizable
                ? yaru.YaruResizablePaneDelegate(
                    initialPaneSize: initialPaneSize,
                    minPaneSize: minPaneSize,
                    minPageSize: minContentSize,
                  )
                : yaru.YaruFixedPaneDelegate(paneSize: initialPaneSize),
            onPaneSizeChange: onPaneSizeChanged,
          ),
          AppPlatform.windows => _ResizableSplitView(
            pane: pane,
            content: content,
            initialPaneSize: initialPaneSize,
            minPaneSize: minPaneSize,
            maxPaneSize: maxPaneSize,
            minContentSize: minContentSize,
            resizable: resizable,
            dividerColor: context.platformTheme.outlineVariant,
            onPaneSizeChanged: onPaneSizeChanged,
          ),
          AppPlatform.ios ||
          AppPlatform.android ||
          AppPlatform.web ||
          AppPlatform.fuchsia => Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: initialPaneSize, child: pane),
              material.VerticalDivider(
                width: 1,
                thickness: 1,
                color: context.platformTheme.outlineVariant,
              ),
              Expanded(child: content),
            ],
          ),
        };
      },
    );
  }
}

class _ResizableSplitView extends StatefulWidget {
  const _ResizableSplitView({
    required this.pane,
    required this.content,
    required this.initialPaneSize,
    required this.minPaneSize,
    required this.maxPaneSize,
    required this.minContentSize,
    required this.resizable,
    required this.dividerColor,
    required this.onPaneSizeChanged,
  });

  final Widget pane;
  final Widget content;
  final double initialPaneSize;
  final double minPaneSize;
  final double maxPaneSize;
  final double minContentSize;
  final bool resizable;
  final Color dividerColor;
  final ValueChanged<double>? onPaneSizeChanged;

  @override
  State<_ResizableSplitView> createState() => _ResizableSplitViewState();
}

class _ResizableSplitViewState extends State<_ResizableSplitView> {
  late double _paneSize = widget.initialPaneSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maximum = (constraints.maxWidth - widget.minContentSize).clamp(
          widget.minPaneSize,
          widget.maxPaneSize,
        );
        _paneSize = _paneSize.clamp(widget.minPaneSize, maximum);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: _paneSize, child: widget.pane),
            MouseRegion(
              cursor: widget.resizable
                  ? SystemMouseCursors.resizeColumn
                  : MouseCursor.defer,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: widget.resizable
                    ? (details) {
                        setState(() {
                          _paneSize = (_paneSize + details.delta.dx).clamp(
                            widget.minPaneSize,
                            maximum,
                          );
                        });
                        widget.onPaneSizeChanged?.call(_paneSize);
                      }
                    : null,
                child: SizedBox(
                  width: 5,
                  child: Center(
                    child: ColoredBox(
                      color: widget.dividerColor,
                      child: const SizedBox(width: 1, height: double.infinity),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: widget.content),
          ],
        );
      },
    );
  }
}
