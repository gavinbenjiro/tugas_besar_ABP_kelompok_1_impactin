import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavbar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(
                0.08,
              ),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(
              icon: Icons.home,
              index: 0,
              route: Routes.HOME,
            ),
            _navItem(
              icon: Icons.explore,
              index: 1,
              route: Routes.SEARCH_EVENT,
            ),
            _navItem(
              icon: Icons.calendar_today_outlined,
              index: 2,
              route: Routes.YOUR_EVENT,
            ),
            _navItem(
              icon: Icons.person_outline,
              index: 3,
              route: Routes.PROFILE,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required int index,
    required String route,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (!isActive) {
          Get.toNamed(route);
        }
      },
      child: Icon(
        icon,
        color: isActive ? Colors.teal.shade700 : Colors.grey.shade500,
        size: 28,
      ),
    );
  }
}
