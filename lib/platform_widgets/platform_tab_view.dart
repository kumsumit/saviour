import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';

/// A single tab in a [PlatformTabView].
class PlatformTab {
  const PlatformTab({required this.label, required this.content, this.icon});

  /// The tab's label.
  final String label;

  /// The page shown when this tab is selected.
  final Widget content;

  /// Optional leading icon for the tab.
  final IconData? icon;
}

/// A platform-aware tabbed view: a row of tabs over a swappable content area.
///
/// Each platform renders its native tab component — macOS `MacosTabView`,
/// Windows `fluent.TabView`, Material `TabBar` + `TabBarView` — while iOS uses
/// the native `CupertinoSlidingSegmentedControl` over an [IndexedStack] (core
/// Cupertino has no top tab container).
///
/// The view owns its selected tab; pass [initialIndex] to set the starting tab
/// and [onChanged] to observe selection.
class PlatformTabView extends ConsumerStatefulWidget {
  const PlatformTabView({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onChanged,
  });

  /// The tabs. Requires at least one (the native bars expect two or more).
  final List<PlatformTab> tabs;

  /// The initially selected tab index.
  final int initialIndex;

  /// Called with the selected index whenever the active tab changes.
  final ValueChanged<int>? onChanged;

  @override
  ConsumerState<PlatformTabView> createState() => _PlatformTabViewState();
}

class _PlatformTabViewState extends ConsumerState<PlatformTabView>
    with TickerProviderStateMixin {
  late int _index;
  late material.TabController _materialController;
  late macos.MacosTabController _macosController;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.tabs.length - 1);
    _initControllers();
  }

  @override
  void didUpdateWidget(PlatformTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _disposeControllers();
      _index = _index.clamp(0, widget.tabs.length - 1);
      _initControllers();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _initControllers() {
    _materialController = material.TabController(
      length: widget.tabs.length,
      initialIndex: _index,
      vsync: this,
    )..addListener(_onMaterialChanged);
    _macosController = macos.MacosTabController(
      length: widget.tabs.length,
      initialIndex: _index,
    )..addListener(_onMacosChanged);
  }

  void _disposeControllers() {
    _materialController
      ..removeListener(_onMaterialChanged)
      ..dispose();
    _macosController
      ..removeListener(_onMacosChanged)
      ..dispose();
  }

  void _onMaterialChanged() {
    if (_materialController.index != _index) _select(_materialController.index);
  }

  void _onMacosChanged() {
    if (_macosController.index != _index) _select(_macosController.index);
  }

  /// Single source of truth for selection: updates state, keeps every native
  /// controller in sync and notifies [PlatformTabView.onChanged].
  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    if (_materialController.index != index) {
      _materialController.animateTo(index);
    }
    if (_macosController.index != index) {
      _macosController.index = index;
    }
    widget.onChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.ios => _buildCupertino(context),
      AppPlatform.macos => _buildMacos(context),
      AppPlatform.windows => _buildFluent(context),
      AppPlatform.linux ||
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => _buildMaterial(context),
    };
  }

  /// Material / Linux `TabBar` + `TabBarView`.
  Widget _buildMaterial(BuildContext context) {
    final theme = context.platformTheme;
    return Column(
      children: [
        material.Material(
          color: const Color(0x00000000),
          child: material.TabBar(
            controller: _materialController,
            labelColor: theme.primary,
            unselectedLabelColor: theme.onSurfaceVariant,
            indicatorColor: theme.primary,
            tabs: [
              for (final tab in widget.tabs)
                material.Tab(
                  text: tab.label,
                  icon: tab.icon != null ? Icon(tab.icon) : null,
                ),
            ],
          ),
        ),
        Expanded(
          child: material.TabBarView(
            controller: _materialController,
            children: [for (final tab in widget.tabs) tab.content],
          ),
        ),
      ],
    );
  }

  /// macOS `MacosTabView` (native tabbed container).
  Widget _buildMacos(BuildContext context) {
    return macos.MacosTabView(
      controller: _macosController,
      tabs: [for (final tab in widget.tabs) macos.MacosTab(label: tab.label)],
      children: [for (final tab in widget.tabs) tab.content],
    );
  }

  /// Windows `fluent.TabView` (close buttons hidden, equal-width tabs).
  Widget _buildFluent(BuildContext context) {
    return fluent.TabView(
      currentIndex: _index,
      onChanged: _select,
      showScrollButtons: false,
      closeButtonVisibility: fluent.CloseButtonVisibilityMode.never,
      tabWidthBehavior: fluent.TabWidthBehavior.equal,
      tabs: [
        for (final tab in widget.tabs)
          fluent.Tab(
            text: Text(tab.label),
            icon: tab.icon != null ? Icon(tab.icon) : const SizedBox.shrink(),
            body: tab.content,
          ),
      ],
    );
  }

  /// iOS `CupertinoSlidingSegmentedControl` over an [IndexedStack].
  Widget _buildCupertino(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: cupertino.CupertinoSlidingSegmentedControl<int>(
            groupValue: _index,
            onValueChanged: (value) {
              if (value != null) _select(value);
            },
            children: {
              for (var i = 0; i < widget.tabs.length; i++)
                i: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Text(widget.tabs[i].label),
                ),
            },
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _index,
            children: [for (final tab in widget.tabs) tab.content],
          ),
        ),
      ],
    );
  }
}
