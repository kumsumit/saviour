import 'package:saviour/app_theme.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/platform_widgets/platform_surface.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';
import 'package:yaru/yaru.dart' as yaru;

/// A single navigation destination.
///
/// The same model drives both presentations — a side rail and a bottom bar —
/// since a destination has the same shape (icon / selectedIcon / label)
/// regardless of where it is shown.
class PlatformNavigationItem {
  const PlatformNavigationItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  /// Icon shown when the destination is not selected.
  final IconData icon;

  /// Icon shown when the destination is selected. Falls back to [icon].
  final IconData? selectedIcon;

  /// The destination label.
  final String label;
}

/// Width-aware platform navigation.
///
/// Wraps [body] with a navigation affordance that adapts to the available
/// width: a bottom [PlatformNavigationBar] when narrow, and a side
/// [PlatformSidebar] when wide (compact at [railBreakpoint], extended with
/// labels at [extendedBreakpoint]). Each affordance is rendered with the native
/// look of the current platform.
///
/// ```dart
/// PlatformNavigation(
///   items: items,
///   selectedIndex: index,
///   onSelected: (i) => setState(() => index = i),
///   body: pages[index],
/// )
/// ```
class PlatformNavigation extends ConsumerWidget {
  const PlatformNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.body,
    this.header,
    this.footer,
    this.backgroundColor,
    this.railBreakpoint = 600,
    this.extendedBreakpoint = 1100,
  });

  /// The destinations. The native bars/rails require at least two.
  final List<PlatformNavigationItem> items;

  /// Index of the currently selected destination.
  final int selectedIndex;

  /// Called with the selected destination index.
  final ValueChanged<int> onSelected;

  /// The page content shown beside (rail) or above (bottom bar) the navigation.
  final Widget body;

  /// Optional header pinned above the rail's destinations (rail mode only).
  final Widget? header;

  /// Optional footer pinned below the rail's destinations (rail mode only).
  final Widget? footer;

  /// Background color of the navigation surface.
  final Color? backgroundColor;

  /// Width at/above which the bottom bar is replaced by a side rail.
  final double railBreakpoint;

  /// Width at/above which the rail shows labels next to icons (extended).
  final double extendedBreakpoint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(appPlatformProvider) == AppPlatform.windows) {
      return fluent.NavigationView(
        pane: fluent.NavigationPane(
          selected: selectedIndex,
          onChanged: onSelected,
          displayMode: fluent.PaneDisplayMode.auto,
          header: header,
          items: [
            for (final item in items)
              fluent.PaneItem(
                icon: Icon(item.icon),
                title: Text(item.label),
                body: body,
              ),
          ],
          footerItems: [
            if (footer != null) fluent.PaneItemWidgetAdapter(child: footer!),
          ],
        ),
        // The caller owns page state; NavigationView owns only the adaptive
        // Fluent navigation chrome and its compact/minimal breakpoints.
        paneBodyBuilder: (_, _) => body,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < railBreakpoint) {
          return Column(
            children: [
              Expanded(child: body),
              PlatformNavigationBar(
                items: items,
                selectedIndex: selectedIndex,
                onSelected: onSelected,
                backgroundColor: backgroundColor,
              ),
            ],
          );
        }

        return Row(
          children: [
            PlatformSidebar(
              items: items,
              selectedIndex: selectedIndex,
              onSelected: onSelected,
              header: header,
              footer: footer,
              backgroundColor: backgroundColor,
              extended: width >= extendedBreakpoint,
            ),
            Expanded(child: body),
          ],
        );
      },
    );
  }
}

// ───────────────────────────── Side rail ─────────────────────────────

/// A platform-aware vertical navigation sidebar / rail.
///
/// Renders the native rail for each platform — macOS `SidebarItems`, Yaru's
/// `YaruNavigationRail`, Material `NavigationRail` — and a platform-styled
/// custom highlighted list on iOS, where Cupertino has no standalone rail.
class PlatformSidebar extends ConsumerWidget {
  const PlatformSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.header,
    this.footer,
    this.extended = false,
    this.backgroundColor,
    this.width,
  });

  final List<PlatformNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Optional widget pinned above the destinations (e.g. a logo or title).
  final Widget? header;

  /// Optional widget pinned below the destinations (e.g. a settings button).
  final Widget? footer;

  /// Whether labels are shown next to the icons (wide sidebar) instead of a
  /// compact icon-only rail.
  final bool extended;

  /// Background color. Defaults to the platform theme surface.
  final Color? backgroundColor;

  /// Explicit width. Defaults to 240 when [extended], otherwise 72.
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.macos => _buildMacos(context),
      AppPlatform.linux => _buildYaru(context),
      // Standalone sidebars can still be requested directly. The full
      // PlatformNavigation composition uses Fluent NavigationView instead.
      AppPlatform.windows => _buildCustom(context, showAccentBar: true),
      AppPlatform.ios => _buildCustom(context, showAccentBar: false),
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => _buildMaterial(context),
    };
  }

  /// Material `NavigationRail` — already a complete rail with its own
  /// width / leading / trailing slots.
  Widget _buildMaterial(BuildContext context) {
    final theme = context.platformTheme;
    return material.NavigationRail(
      backgroundColor: backgroundColor ?? theme.surface,
      extended: extended,
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      leading: header,
      trailing: footer,
      labelType: extended
          ? material.NavigationRailLabelType.none
          : material.NavigationRailLabelType.all,
      destinations: [
        for (final item in items)
          material.NavigationRailDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon ?? item.icon),
            label: Text(item.label),
          ),
      ],
    );
  }

  /// Linux `YaruNavigationRail` wrapped in a [_frame] for header/footer.
  Widget _buildYaru(BuildContext context) {
    final style = extended
        ? yaru.YaruNavigationRailStyle.labelledExtended
        : yaru.YaruNavigationRailStyle.labelled;
    return _frame(
      context,
      yaru.YaruNavigationRail(
        length: items.length,
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        itemBuilder: (context, index, selected) {
          final item = items[index];
          return yaru.YaruNavigationRailItem(
            selected: selected,
            style: style,
            icon: Icon(selected ? (item.selectedIcon ?? item.icon) : item.icon),
            label: Text(item.label),
          );
        },
      ),
    );
  }

  /// macOS `SidebarItems` wrapped in a [_frame] for header/footer.
  Widget _buildMacos(BuildContext context) {
    return _frame(
      context,
      SingleChildScrollView(
        child: macos.SidebarItems(
          currentIndex: selectedIndex,
          onChanged: onSelected,
          items: [
            for (final item in items)
              macos.SidebarItem(
                leading: Icon(item.icon),
                label: Text(item.label),
              ),
          ],
        ),
      ),
    );
  }

  /// Windows (Fluent) / iOS (Cupertino) custom column of platform-styled tiles.
  Widget _buildCustom(BuildContext context, {required bool showAccentBar}) {
    return _frame(
      context,
      ListView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        children: [
          for (var i = 0; i < items.length; i++)
            _SidebarTile(
              item: items[i],
              selected: i == selectedIndex,
              extended: extended,
              accent: context.platformTheme.primary,
              showAccentBar: showAccentBar,
              onTap: () => onSelected(i),
            ),
        ],
      ),
    );
  }

  /// Shared chrome (width, background, header/footer) for the non-Material rails.
  Widget _frame(BuildContext context, Widget child) {
    final theme = context.platformTheme;
    return SizedBox(
      width: width ?? (extended ? 240 : 72),
      child: GlassSurface(
        tint: backgroundColor ?? theme.surface,
        border: false,
        child: SafeArea(
          right: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ?header,
              Expanded(child: child),
              ?footer,
            ],
          ),
        ),
      ),
    );
  }
}

/// A custom sidebar destination used on platforms without a native rail
/// (Windows / iOS). Shows a selected highlight and, optionally, a Fluent-style
/// leading accent bar.
class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.selected,
    required this.extended,
    required this.accent,
    required this.showAccentBar,
    required this.onTap,
  });

  final PlatformNavigationItem item;
  final bool selected;
  final bool extended;
  final Color accent;
  final bool showAccentBar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    final foreground = selected ? accent : theme.onSurfaceVariant;
    final icon = Icon(
      selected ? (item.selectedIcon ?? item.icon) : item.icon,
      color: foreground,
      size: 22,
    );

    final Widget content = extended
        ? Row(
            children: [
              const SizedBox(width: 12),
              icon,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          )
        : Center(child: icon);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        child: _NavigationTapTarget(
          fluentStyle: showAccentBar,
          onTap: onTap,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: selected ? accent.withValues(alpha: 0.12) : null,
              borderRadius: BorderRadius.circular(theme.controlRadius),
            ),
            child: Row(
              children: [
                if (showAccentBar)
                  Container(
                    width: 3,
                    height: 22,
                    decoration: BoxDecoration(
                      color: selected ? accent : SaviourPalette.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                Expanded(child: ExcludeSemantics(child: content)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── Bottom bar ───────────────────────────

/// A platform-aware bottom navigation bar.
///
/// The mobile platforms get the real native bar — `CupertinoTabBar` on iOS,
/// Material `NavigationBar` on Android — while the desktop kits (which have no
/// bottom bar) get a clean, platform-themed custom bar: Fluent uses a top accent
/// indicator on Windows, and macOS uses a highlighted selection.
class PlatformNavigationBar extends ConsumerWidget {
  const PlatformNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.backgroundColor,
    this.height = 64,
  });

  final List<PlatformNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Background color. Defaults to the platform theme surface.
  final Color? backgroundColor;

  /// Bar height (used by the Material and custom bars).
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.ios => _buildCupertino(context),
      AppPlatform.windows => _buildCustom(context, topIndicator: true),
      AppPlatform.macos => _buildCustom(context, topIndicator: false),
      AppPlatform.linux ||
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => _buildMaterial(context),
    };
  }

  /// iOS `CupertinoTabBar`.
  Widget _buildCupertino(BuildContext context) {
    final theme = context.platformTheme;
    return cupertino.CupertinoTabBar(
      currentIndex: selectedIndex,
      onTap: onSelected,
      backgroundColor: backgroundColor ?? theme.surface,
      activeColor: theme.primary,
      inactiveColor: theme.onSurfaceVariant,
      items: [
        for (final item in items)
          cupertino.BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(item.selectedIcon ?? item.icon),
            label: item.label,
          ),
      ],
    );
  }

  /// Material / Linux `NavigationBar` (Material 3).
  Widget _buildMaterial(BuildContext context) {
    final theme = context.platformTheme;
    return material.NavigationBar(
      backgroundColor: backgroundColor ?? theme.surface,
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      height: height,
      destinations: [
        for (final item in items)
          material.NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon ?? item.icon),
            label: item.label,
          ),
      ],
    );
  }

  /// Windows (Fluent) / macOS custom bottom bar of evenly-sized tiles.
  Widget _buildCustom(BuildContext context, {required bool topIndicator}) {
    final theme = context.platformTheme;
    return SizedBox(
      height: height,
      child: GlassSurface(
        tint: backgroundColor ?? theme.surface,
        border: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.outlineVariant)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavBarTile(
                      item: items[i],
                      selected: i == selectedIndex,
                      accent: context.platformTheme.primary,
                      topIndicator: topIndicator,
                      onTap: () => onSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A single destination tile for the custom desktop (Windows / macOS) bar.
class _NavBarTile extends StatelessWidget {
  const _NavBarTile({
    required this.item,
    required this.selected,
    required this.accent,
    required this.topIndicator,
    required this.onTap,
  });

  final PlatformNavigationItem item;
  final bool selected;
  final Color accent;
  final bool topIndicator;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    final foreground = selected ? accent : theme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: _NavigationTapTarget(
        fluentStyle: topIndicator,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Stack(
            children: [
              if (topIndicator && selected)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(height: 2, color: accent),
                ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selected ? (item.selectedIcon ?? item.icon) : item.icon,
                      color: foreground,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: foreground,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationTapTarget extends StatelessWidget {
  const _NavigationTapTarget({
    required this.fluentStyle,
    required this.onTap,
    required this.child,
  });

  final bool fluentStyle;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (fluentStyle) {
      return fluent.HoverButton(
        cursor: SystemMouseCursors.click,
        onPressed: onTap,
        builder: (context, states) => Opacity(
          opacity: states.contains(WidgetState.pressed) ? 0.72 : 1,
          child: child,
        ),
      );
    }

    return cupertino.CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: child,
    );
  }
}
