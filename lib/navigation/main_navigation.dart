import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../screens/dashboard_screen.dart';
import '../screens/documents_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/support_screen.dart';
import '../screens/profile_screen.dart';
import '../utils/theme.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  static const List<Widget> _screens = [
    DashboardScreen(),
    DocumentsScreen(),
    ProgressScreen(),
    SupportScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (ctx, provider, _) {
        return Scaffold(
          body: IndexedStack(
            index: provider.currentTabIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: const Border(top: BorderSide(color: AppTheme.border, width: 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      index: 0,
                      currentIndex: provider.currentTabIndex,
                      onTap: () => provider.setTabIndex(0),
                    ),
                    _NavItem(
                      icon: Icons.folder_outlined,
                      activeIcon: Icons.folder_rounded,
                      label: 'Documents',
                      index: 1,
                      currentIndex: provider.currentTabIndex,
                      onTap: () => provider.setTabIndex(1),
                      badge: provider.uploadedDocumentsCount < provider.totalDocumentsCount
                          ? '${provider.totalDocumentsCount - provider.uploadedDocumentsCount}'
                          : null,
                    ),
                    _NavItem(
                      icon: Icons.timeline_outlined,
                      activeIcon: Icons.timeline_rounded,
                      label: 'Progress',
                      index: 2,
                      currentIndex: provider.currentTabIndex,
                      onTap: () => provider.setTabIndex(2),
                    ),
                    _NavItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      activeIcon: Icons.chat_bubble_rounded,
                      label: 'Support',
                      index: 3,
                      currentIndex: provider.currentTabIndex,
                      onTap: () => provider.setTabIndex(3),
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      index: 4,
                      currentIndex: provider.currentTabIndex,
                      onTap: () => provider.setTabIndex(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;
  final String? badge;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.badge,
  });

  bool get isSelected => currentIndex == index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey(isSelected),
                    size: 24,
                    color: isSelected ? AppTheme.primary : AppTheme.textLight,
                  ),
                ),
                if (badge != null)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppTheme.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
