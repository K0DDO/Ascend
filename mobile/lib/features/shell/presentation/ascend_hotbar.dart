import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/ascend_theme.dart';
import '../../../core/widgets/ascend_glass_surface.dart';

class AscendHotbarItem {
  const AscendHotbarItem({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const _items = [
  AscendHotbarItem(
    path: '/home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'Home',
  ),
  AscendHotbarItem(
    path: '/learn',
    icon: Icons.school_outlined,
    selectedIcon: Icons.school_rounded,
    label: 'Learn',
  ),
  AscendHotbarItem(
    path: '/knowledge',
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book_rounded,
    label: 'Knowledge',
  ),
  AscendHotbarItem(
    path: '/progress',
    icon: Icons.insights_outlined,
    selectedIcon: Icons.insights_rounded,
    label: 'Progress',
  ),
  AscendHotbarItem(
    path: '/profile',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
    label: 'Profile',
  ),
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

    return Padding(
      padding: EdgeInsets.fromLTRB(
        theme.spacing.md,
        0,
        theme.spacing.md,
        MediaQuery.paddingOf(context).bottom + theme.spacing.xs,
      ),
      child: AscendGlassSurface(
        radius: theme.radius.pill,
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          height: 72,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / _items.length;
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  AnimatedPositioned(
                    duration: theme.animations.slow,
                    curve: theme.animations.standard,
                    left: itemWidth * selected + 4,
                    width: itemWidth - 8,
                    top: 4,
                    bottom: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(theme.radius.pill),
                        gradient: LinearGradient(
                          colors: [
                            theme.colors.primary.withValues(alpha: 0.28),
                            theme.colors.primary.withValues(alpha: 0.14),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colors.glow.withValues(alpha: 0.22),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(_items.length, (index) {
                      final item = _items[index];
                      final isSelected = index == selected;
                      return Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(theme.radius.pill),
                          onTap: () => context.go(item.path),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedScale(
                                scale: isSelected ? 1.08 : 1,
                                duration: theme.animations.normal,
                                curve: theme.animations.standard,
                                child: Icon(
                                  isSelected ? item.selectedIcon : item.icon,
                                  size: 23,
                                  color: isSelected
                                      ? theme.colors.foreground
                                      : theme.colors.muted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.label,
                                style: theme.typography.textTheme.labelSmall?.copyWith(
                                  color: isSelected
                                      ? theme.colors.foreground
                                      : theme.colors.muted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
