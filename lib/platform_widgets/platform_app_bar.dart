import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/platform_widgets/platform_surface.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru/yaru.dart' as yaru;

/// A platform-aware top bar description.
///
/// Each platform exposes a *different* concrete bar type — Material expects a
/// [PreferredSizeWidget], Cupertino an [ObstructingPreferredSizeWidget], macOS a
/// [macos.ToolBar] and Fluent a plain title-bar [Widget] — so a single widget
/// can't be dropped into every scaffold slot. Instead this class holds the
/// shared content (title / leading / actions) and builds the right native bar
/// on demand, which `PlatformScaffold` wires into the correct slot per platform.
///
/// It is normally passed to `PlatformScaffold(appBar: ...)` rather than used
/// directly, but the [build] helpers are public so it can be embedded manually.
class PlatformAppBar {
  const PlatformAppBar({
    this.title,
    this.leading,
    this.actions = const [],
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.centerTitle,
    this.windowControls = false,
  });

  /// The primary title, usually a [Text].
  final Widget? title;

  /// A widget shown before the title (e.g. a back button). When null and
  /// [automaticallyImplyLeading] is true each platform supplies its own.
  final Widget? leading;

  /// Trailing action widgets shown after the title.
  final List<Widget> actions;

  /// Whether to imply a leading widget (back button) when [leading] is null.
  final bool automaticallyImplyLeading;

  /// Background color of the bar. Defaults to the platform theme surface.
  final Color? backgroundColor;

  /// Whether to center the title. When null each platform uses its native
  /// default (centered on iOS, leading-aligned on the desktop platforms).
  final bool? centerTitle;

  /// Windows only: when true the Fluent title bar becomes draggable and shows
  /// native minimize / maximize / close caption buttons (via `window_manager`).
  ///
  /// Enable this only when the OS title bar is hidden (e.g. via
  /// `windowManager.setTitleBarStyle(TitleBarStyle.hidden)` at startup),
  /// otherwise the window will show two title bars.
  final bool windowControls;

  /// Resolves the bar to the native widget for [platform], typed as a generic
  /// [Widget]. Callers that need the concrete slot type should use the
  /// dedicated [buildMaterial] / [buildCupertino] / [buildMacosToolBar] /
  /// [buildFluentHeader] helpers instead.
  Widget resolve(BuildContext context, AppPlatform platform) {
    return switch (platform) {
      AppPlatform.ios => buildCupertino(context),
      AppPlatform.macos => buildMacosToolBar(context),
      AppPlatform.windows => buildFluentHeader(context),
      AppPlatform.linux => buildLinux(context),
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => buildMaterial(context),
    };
  }

  /// Material / Linux `AppBar`.
  PreferredSizeWidget buildMaterial(BuildContext context) {
    final theme = context.platformTheme;
    return material.AppBar(
      title: title,
      leading: leading,
      actions: actions.isEmpty ? null : actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor ?? theme.surface,
      foregroundColor: theme.onSurface,
      titleTextStyle: theme.textTheme.titleLarge,
    );
  }

  /// Cupertino `CupertinoNavigationBar`.
  cupertino.ObstructingPreferredSizeWidget buildCupertino(
    BuildContext context,
  ) {
    final theme = context.platformTheme;
    return cupertino.CupertinoNavigationBar(
      middle: title,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? theme.surface,
      trailing: actions.isEmpty
          ? null
          : Row(mainAxisSize: MainAxisSize.min, children: actions),
    );
  }

  /// macOS `ToolBar` (consumed by `MacosScaffold.toolBar`).
  ///
  /// macOS gets its window-management "for free": the toolbar sits in the
  /// native title-bar region (draggable) and the OS renders the traffic-light
  /// close / minimize / zoom buttons, so [windowControls] adds nothing here.
  macos.ToolBar buildMacosToolBar(BuildContext context) {
    final theme = context.platformTheme;
    return macos.ToolBar(
      title: title,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle ?? false,
      // A translucent tint lets the native macOS toolbar vibrancy read through
      // as a faint glass pane rather than a flat fill.
      decoration: BoxDecoration(
        color: (backgroundColor ?? theme.surface).withValues(alpha: 0.6),
      ),
      actions: actions.isEmpty
          ? null
          : [
              for (final action in actions)
                macos.CustomToolbarItem(inToolbarBuilder: (_) => action),
            ],
    );
  }

  /// Fluent title bar (consumed by `NavigationView.titleBar`).
  ///
  /// The leading + title region is wrapped in a [DragToMoveArea] so the bar can
  /// move the window, while action buttons and (when [windowControls] is set)
  /// the Fluent-styled minimize / maximize / close buttons stay interactive on
  /// the right.
  Widget buildFluentHeader(BuildContext context) {
    final theme = context.platformTheme;
    return SizedBox(
      height: 48,
      child: GlassSurface(
        tint: backgroundColor ?? theme.surface,
        border: false,
        child: Row(
          children: [
            Expanded(child: DragToMoveArea(child: _draggableTitle(theme))),
            for (final action in actions) ...[action, const SizedBox(width: 4)],
            if (windowControls)
              _WindowCaptionButtons(brightness: theme.brightness),
          ],
        ),
      ),
    );
  }

  /// Linux / Yaru title bar.
  ///
  /// Without [windowControls] this is the standard themed [buildMaterial] bar.
  /// With it, the bar becomes a [DragToMoveArea] title bar carrying native
  /// Yaru-styled (GTK) minimize / maximize / close window controls.
  PreferredSizeWidget buildLinux(BuildContext context) {
    if (!windowControls) return buildMaterial(context);
    final theme = context.platformTheme;
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: SizedBox(
        height: 48,
        child: GlassSurface(
          tint: backgroundColor ?? theme.surface,
          border: false,
          child: Row(
            children: [
              Expanded(child: DragToMoveArea(child: _draggableTitle(theme))),
              for (final action in actions) ...[
                action,
                const SizedBox(width: 4),
              ],
              const _YaruWindowControls(),
            ],
          ),
        ),
      ),
    );
  }

  /// The leading + title content used as the draggable region of the desktop
  /// (Windows / Linux) title bars.
  Widget _draggableTitle(PlatformThemeData theme) {
    final resolvedLeading = leading;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (resolvedLeading != null) ...[
            resolvedLeading,
            const SizedBox(width: 8),
          ],
          if (title != null)
            DefaultTextStyle.merge(
              style: theme.textTheme.titleMedium,
              child: title!,
            ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// Tracks the window's maximized state via [WindowListener] so a control row can
/// toggle its maximize/restore affordance. Shared by the Windows and Linux
/// window-control widgets.
mixin _MaximizeAware<T extends StatefulWidget> on State<T>, WindowListener {
  bool maximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _syncMaximized();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _syncMaximized() async {
    final value = await windowManager.isMaximized();
    if (mounted) setState(() => maximized = value);
  }

  @override
  void onWindowMaximize() => setState(() => maximized = true);

  @override
  void onWindowUnmaximize() => setState(() => maximized = false);
}

/// Native Windows (Fluent) minimize / maximize / close caption buttons.
class _WindowCaptionButtons extends StatefulWidget {
  const _WindowCaptionButtons({required this.brightness});

  final Brightness brightness;

  @override
  State<_WindowCaptionButtons> createState() => _WindowCaptionButtonsState();
}

class _WindowCaptionButtonsState extends State<_WindowCaptionButtons>
    with WindowListener, _MaximizeAware {
  @override
  Widget build(BuildContext context) {
    final brightness = widget.brightness;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WindowCaptionButton.minimize(
          brightness: brightness,
          onPressed: () => windowManager.minimize(),
        ),
        maximized
            ? WindowCaptionButton.unmaximize(
                brightness: brightness,
                onPressed: () => windowManager.unmaximize(),
              )
            : WindowCaptionButton.maximize(
                brightness: brightness,
                onPressed: () => windowManager.maximize(),
              ),
        WindowCaptionButton.close(
          brightness: brightness,
          onPressed: () => windowManager.close(),
        ),
      ],
    );
  }
}

/// Native Linux (Yaru / GTK) minimize / maximize / close window controls.
class _YaruWindowControls extends StatefulWidget {
  const _YaruWindowControls();

  @override
  State<_YaruWindowControls> createState() => _YaruWindowControlsState();
}

class _YaruWindowControlsState extends State<_YaruWindowControls>
    with WindowListener, _MaximizeAware {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        yaru.YaruWindowControl(
          type: yaru.YaruWindowControlType.minimize,
          onTap: () => windowManager.minimize(),
        ),
        yaru.YaruWindowControl(
          type: maximized
              ? yaru.YaruWindowControlType.restore
              : yaru.YaruWindowControlType.maximize,
          onTap: () =>
              maximized ? windowManager.unmaximize() : windowManager.maximize(),
        ),
        yaru.YaruWindowControl(
          type: yaru.YaruWindowControlType.close,
          onTap: () => windowManager.close(),
        ),
      ],
    );
  }
}
