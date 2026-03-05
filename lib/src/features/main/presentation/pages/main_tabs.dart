import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../activity/presentation/pages/activity_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../provider/main_nav_provider.dart';

class MainTabs extends ConsumerStatefulWidget {
  const MainTabs({super.key});

  @override
  ConsumerState<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends ConsumerState<MainTabs> {
  late final CupertinoTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CupertinoTabController(
      initialIndex: ref.read(mainNavProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider changes to update controller
    ref.listen<int>(mainNavProvider, (previous, next) {
      if (_controller.index != next) {
        _controller.index = next;
      }
    });

    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoTabScaffold(
      controller: _controller,
      tabBar: CupertinoTabBar(
        onTap: (index) {
          ref.read(mainNavProvider.notifier).state = index;
        },
        backgroundColor: AppColors.getCardColor(context),
        activeColor: isDark ? AppColors.primaryGold : const Color(0xFF137FEC),
        inactiveColor: CupertinoColors.systemGrey,
        border: Border(
          top: BorderSide(
            color: AppColors.getSeparatorColor(context),
            width: 0.5,
          ),
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_bullet),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return const HomePage();
              case 1:
                return const ActivityPage();
              case 2:
                return const SettingsPage();
              default:
                return const HomePage();
            }
          },
        );
      },
    );
  }
}
