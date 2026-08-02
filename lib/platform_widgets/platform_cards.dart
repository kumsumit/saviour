import 'package:flutter/material.dart' show Divider, Icons;
import 'package:flutter/widgets.dart';
import 'package:saviour/platform_widgets/platform_button.dart';
import 'package:saviour/platform_widgets/platform_list.dart';
import 'package:saviour/platform_widgets/platform_surface.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';

/// A tappable card row: icon + title/subtitle + optional trailing widget.
///
/// Covers: coupon, gift, address-bar, payment-bar, and any similar navigation
/// affordance. Composes [PlatformCard] + [PlatformListTile] so each platform
/// gets native list-row behavior inside the shared card surface.
class PlatformActionCard extends StatelessWidget {
  const PlatformActionCard({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.margin,
  });

  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;

  /// Custom trailing widget. Defaults to a chevron when [onTap] is provided.
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    final effectiveTrailing =
        trailing ??
        (onTap != null
            ? Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: theme.onSurfaceVariant,
              )
            : null);
    return PlatformCard(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 6),
      child: PlatformListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor ?? theme.primary),
        title: Text(
          title,
          style: theme.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: theme.text.bodySmall?.copyWith(
                  color: theme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: effectiveTrailing,
      ),
    );
  }
}

/// A compact address bar showing an address type, full line, and an optional
/// "Change" link — e.g. the delivery address row in the cart screen.
class PlatformAddressBar extends StatelessWidget {
  const PlatformAddressBar({
    super.key,
    required this.label,
    required this.address,
    this.icon = Icons.home_filled,
    this.iconColor,
    this.onChangeTap,
    this.changeLabel = 'Change',
    this.margin,
  });

  final String label;
  final String address;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onChangeTap;
  final String changeLabel;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return PlatformCard(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: PlatformListTile(
        leading: Icon(icon, color: iconColor ?? theme.primary),
        title: Text(
          label,
          style: theme.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          address,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.text.bodySmall?.copyWith(color: theme.onSurfaceVariant),
        ),
        trailing: onChangeTap != null
            ? GestureDetector(
                onTap: onChangeTap,
                child: Text(
                  changeLabel,
                  style: theme.text.bodySmall?.copyWith(color: theme.primary),
                ),
              )
            : null,
      ),
    );
  }
}

/// A saved-address card with optional Edit / Delete actions.
class PlatformAddressCard extends StatelessWidget {
  const PlatformAddressCard({
    super.key,
    required this.type,
    required this.address,
    this.icon = Icons.home,
    this.iconColor,
    this.onEdit,
    this.onDelete,
    this.margin,
  });

  final String type;
  final String address;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return PlatformCard(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          PlatformListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.surfaceContainer,
                borderRadius: BorderRadius.circular(theme.controlRadius),
              ),
              child: Icon(icon, color: iconColor ?? theme.primary),
            ),
            title: Text(
              type,
              style: theme.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.text.bodySmall?.copyWith(
                color: theme.onSurfaceVariant,
              ),
            ),
          ),
          if (onEdit != null || onDelete != null) ...[
            Divider(color: theme.outline.withValues(alpha: 0.4)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (onEdit != null)
                  PlatformButton(
                    kind: PlatformButtonKind.text,
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    child: const Text('Edit'),
                  ),
                if (onEdit != null && onDelete != null)
                  Container(width: 1, height: 20, color: theme.outline),
                if (onDelete != null)
                  PlatformButton(
                    kind: PlatformButtonKind.text,
                    onPressed: onDelete,
                    accentColor: theme.destructive,
                    padding: EdgeInsets.zero,
                    child: const Text('Delete'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A simple "Add new address" card with a leading + icon.
class PlatformAddAddressCard extends StatelessWidget {
  const PlatformAddAddressCard({
    super.key,
    required this.onTap,
    this.label = 'Add new address',
    this.margin,
  });

  final VoidCallback onTap;
  final String label;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return GestureDetector(
      onTap: onTap,
      child: PlatformCard(
        margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.add, color: theme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A static info card — title headline above a body paragraph.
/// Covers: cancellation policy, order notes, and similar read-only blocks.
class PlatformInfoCard extends StatelessWidget {
  const PlatformInfoCard({
    super.key,
    required this.title,
    required this.body,
    this.margin,
  });

  final String title;
  final String body;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return PlatformCard(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: theme.text.bodySmall?.copyWith(
              color: theme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// A bottom-anchored sticky bar: a label on the left, a primary [PlatformButton]
/// on the right. Use inside a `Stack` or `Align(bottomCenter)`.
class PlatformStickyBar extends StatelessWidget {
  const PlatformStickyBar({
    super.key,
    required this.label,
    required this.actionLabel,
    required this.onAction,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  final String label;
  final String actionLabel;
  final VoidCallback onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return PlatformCard(
      margin: EdgeInsets.zero,
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          PlatformButton(
            onPressed: onAction,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
