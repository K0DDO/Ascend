import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/ascend_animations.dart';
import '../../../core/theme/ascend_theme.dart';
import '../../../core/widgets/ascend_liquid_glass.dart';

class AscendHotbarItem {
  const AscendHotbarItem({
    required this.path,
    required this.icon,
    required this.label,
  });

  final String path;
  final IconData icon;
  final String label;
}

const _items = [
  AscendHotbarItem(path: '/home', icon: Icons.space_dashboard_rounded, label: 'Home'),
  AscendHotbarItem(path: '/learn', icon: Icons.school_rounded, label: 'Learn'),
  AscendHotbarItem(path: '/knowledge', icon: Icons.menu_book_rounded, label: 'Knowledge'),
  AscendHotbarItem(path: '/progress', icon: Icons.insights_rounded, label: 'Progress'),
  AscendHotbarItem(path: '/profile', icon: Icons.tune_rounded, label: 'Profile'),
];

class AscendHotbar extends StatelessWidget {
  const AscendHotbar({super.key});

  int _selectedIndex(String location) {
    final index = _items.indexWhere((item) => location.startsWith(item.path));
    return index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final location = GoRouterState.of(context).uri.toString();
    final selected = _selectedIndex(location);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: SizedBox(
          height: 72,
          child: AscendLiquidGlass(
            radius: theme.radius.pill,
            strong: true,
            padding: EdgeInsets.zero,
            child: _HotbarContents(selected: selected, items: _items),
          ),
        ),
      ),
    );
  }
}

class _HotbarContents extends StatelessWidget {
  const _HotbarContents({required this.selected, required this.items});

  final int selected;
  final List<AscendHotbarItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final colors = theme.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / items.length;
        return ClipRRect(
          borderRadius: BorderRadius.circular(theme.radius.pill),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              AnimatedPositioned(
                left: selected * itemWidth + 4,
                top: 4,
                bottom: 4,
                width: itemWidth - 8,
                duration: const Duration(milliseconds: 320),
                curve: AscendAnimations.standardPreset.standard,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: colors.accentGradient,
                    borderRadius: BorderRadius.circular(theme.radius.pill),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.22),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  return Expanded(
                    child: _HotbarButton(
                      item: item,
                      selected: index == selected,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.go(item.path);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HotbarButton extends StatelessWidget {
  const _HotbarButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AscendHotbarItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final color = selected ? Colors.white : theme.colors.muted;

    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.radius.pill),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.08 : 1,
              duration: const Duration(milliseconds: 240),
              curve: AscendAnimations.standardPreset.standard,
              child: Icon(item.icon, color: color, size: 23),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.textTheme.labelSmall?.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
