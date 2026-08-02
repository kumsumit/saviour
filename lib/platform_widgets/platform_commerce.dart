import 'package:flutter/material.dart' show Icons, TextDecoration;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:saviour/platform_widgets/platform_button.dart';
import 'package:saviour/platform_widgets/platform_list.dart';
import 'package:saviour/platform_widgets/platform_surface.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';

/// Small outlined "Add" button — uses [PlatformButton.outlined] so it renders
/// natively on each platform.
class PlatformAddToCartButton extends ConsumerWidget {
  const PlatformAddToCartButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PlatformButton(
    kind: PlatformButtonKind.outlined,
    onPressed: onTap,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    child: const Text('Add'),
  );
}

/// Inline quantity stepper: [–] count [+]. Custom widget — no existing
/// platform equivalent.
class PlatformQuantityStepper extends StatelessWidget {
  const PlatformQuantityStepper({
    super.key,
    required this.count,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int count;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: theme.primary,
        borderRadius: BorderRadius.circular(theme.controlRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepIcon(icon: Icons.remove, onTap: onDecrement, color: theme.onPrimary),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$count',
              style: theme.text.labelLarge?.copyWith(color: theme.onPrimary),
            ),
          ),
          _StepIcon(icon: Icons.add, onTap: onIncrement, color: theme.onPrimary),
        ],
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.icon, required this.onTap, required this.color});

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Icon(icon, color: color, size: 14),
  );
}

/// Product card for grid or horizontal-list layout.
///
/// Set [compact] for the narrower horizontal-list variant. Uses [PlatformCard]
/// for the surface and [PlatformAddToCartButton] for the action.
class PlatformProductCard extends StatelessWidget {
  const PlatformProductCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.unit,
    required this.price,
    this.originalPrice,
    this.onTap,
    required this.onAddToCart,
    this.compact = false,
  });

  final String imagePath;
  final String name;
  final String unit;
  final String price;
  final String? originalPrice;
  final VoidCallback? onTap;
  final VoidCallback onAddToCart;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return GestureDetector(
      onTap: onTap,
      child: PlatformCard(
        padding: const EdgeInsets.all(8),
        margin: compact ? const EdgeInsets.symmetric(horizontal: 5) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImage(
              imagePath: imagePath,
              radius: theme.controlRadius,
              borderColor: theme.outline.withValues(alpha: 0.4),
              fixedWidth: compact ? 100 : null,
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              unit,
              maxLines: 1,
              style: theme.text.bodySmall?.copyWith(color: theme.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PriceLabel(price: price, originalPrice: originalPrice, theme: theme),
                PlatformAddToCartButton(onTap: onAddToCart),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imagePath,
    required this.radius,
    required this.borderColor,
    this.fixedWidth,
  });

  final String imagePath;
  final double radius;
  final Color borderColor;
  final double? fixedWidth;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: borderColor),
      borderRadius: BorderRadius.circular(radius),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(imagePath, width: fixedWidth, fit: BoxFit.cover),
    ),
  );
}

class _PriceLabel extends StatelessWidget {
  const _PriceLabel({
    required this.price,
    this.originalPrice,
    required this.theme,
  });

  final String price;
  final String? originalPrice;
  final PlatformThemeData theme;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        price,
        style: theme.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      if (originalPrice != null) ...[
        const SizedBox(width: 4),
        Text(
          originalPrice!,
          style: theme.text.bodySmall?.copyWith(
            decoration: TextDecoration.lineThrough,
            color: theme.onSurfaceVariant,
          ),
        ),
      ],
    ],
  );
}

/// A product row in the cart, with image, details, and a quantity stepper.
class PlatformCartItem extends StatelessWidget {
  const PlatformCartItem({
    super.key,
    required this.imagePath,
    required this.name,
    required this.unit,
    required this.price,
    required this.count,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String imagePath;
  final String name;
  final String unit;
  final String price;
  final int count;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    // Uses PlatformListTile for the leading/content layout, with the stepper
    // as the trailing widget.
    return PlatformListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      leading: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.outline.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(theme.controlRadius / 2),
        ),
        child: Image.asset(imagePath, height: 70),
      ),
      title: Text(
        name,
        style: theme.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            unit,
            style: theme.text.bodySmall?.copyWith(color: theme.onSurfaceVariant),
          ),
          Text(
            price,
            style: theme.text.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      trailing: PlatformQuantityStepper(
        count: count,
        onDecrement: onDecrement,
        onIncrement: onIncrement,
      ),
    );
  }
}

/// Category tile: image in a rounded container above a label.
class PlatformCategoryTile extends StatelessWidget {
  const PlatformCategoryTile({
    super.key,
    required this.imagePath,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.surfaceContainer,
              borderRadius: BorderRadius.circular(theme.controlRadius),
              border: selected ? Border.all(color: theme.primary, width: 2) : null,
            ),
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.text.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: selected ? theme.primary : theme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single charge label + value row for billing breakdowns.
class PlatformPriceRow extends StatelessWidget {
  const PlatformPriceRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    final style = bold
        ? theme.text.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
        : theme.text.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}

/// An order-history row — uses [PlatformListTile] for native layout.
class PlatformOrderItem extends StatelessWidget {
  const PlatformOrderItem({
    super.key,
    required this.imagePath,
    required this.name,
    required this.quantity,
    required this.total,
  });

  final String imagePath;
  final String name;
  final String quantity;
  final String total;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return PlatformListTile(
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: theme.outline.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(theme.controlRadius),
        ),
        child: Image.asset(imagePath, fit: BoxFit.fitHeight),
      ),
      title: Text(
        name,
        style: theme.text.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        quantity,
        style: theme.text.bodySmall?.copyWith(color: theme.onSurfaceVariant),
      ),
      trailing: Text(
        total,
        style: theme.text.bodyMedium?.copyWith(color: theme.onSurfaceVariant),
      ),
    );
  }
}
