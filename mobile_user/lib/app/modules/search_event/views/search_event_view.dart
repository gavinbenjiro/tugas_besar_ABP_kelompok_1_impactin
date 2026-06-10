import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_user/app/routes/app_pages.dart';

import '../../../widgets/custom_bottom_navbar.dart';
import '../controllers/search_event_controller.dart';

class SearchEventView extends GetView<SearchEventController> {
  const SearchEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      bottomNavigationBar: const CustomBottomNavbar(
        currentIndex: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                28,
              ),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4F6F68),
                    Color(0xFF0B5D51),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Find Events",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Discover volunteer opportunities",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: "Search event, location, host...",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(
                        Icons.search,
                      ),
                      suffixIcon: Obx(
                        () => controller.searchText.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  controller.searchController.clear();
                                  controller.searchText.value = '';
                                  controller.fetchEvents();
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          18,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) {
                      controller.fetchEvents();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // FILTERS
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(
                            double.infinity,
                            56,
                          ),
                          backgroundColor:
                              controller.selectedCategory.value != 'All'
                                  ? const Color(0xFFE7F3EF)
                                  : Colors.white,
                          side: BorderSide(
                            color: controller.selectedCategory.value != 'All'
                                ? const Color(0xFF0B5D51)
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: Icon(
                          Icons.category_outlined,
                          color: controller.selectedCategory.value != 'All'
                              ? const Color(0xFF0B5D51)
                              : Colors.grey.shade700,
                        ),
                        label: Text(
                          controller.selectedCategory.value == 'All'
                              ? 'Category'
                              : controller.selectedCategory.value,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: controller.selectedCategory.value != 'All'
                                ? const Color(0xFF0B5D51)
                                : Colors.black87,
                          ),
                        ),
                        onPressed: () {
                          showCategoryFilter(
                            context,
                            controller,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(
                            double.infinity,
                            56,
                          ),
                          backgroundColor: controller.selectedAges.isNotEmpty
                              ? const Color(0xFFE7F3EF)
                              : Colors.white,
                          side: BorderSide(
                            color: controller.selectedAges.isNotEmpty
                                ? const Color(0xFF0B5D51)
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: Icon(
                          Icons.people_alt_outlined,
                          color: controller.selectedAges.isNotEmpty
                              ? const Color(0xFF0B5D51)
                              : Colors.grey.shade700,
                        ),
                        label: Text(
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: controller.selectedAges.isNotEmpty
                                ? const Color(0xFF0B5D51)
                                : Colors.black87,
                          ),
                          controller.selectedAges.isEmpty
                              ? 'Age Filter'
                              : '${controller.selectedAges.length} Selected',
                        ),
                        onPressed: () {
                          showAgeFilter(
                            context,
                            controller,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ACTIVE FILTERS
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Obx(
                () {
                  final hasFilters =
                      controller.selectedCategory.value != 'All' ||
                          controller.selectedAges.isNotEmpty;

                  if (!hasFilters) {
                    return const SizedBox();
                  }

                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (controller.selectedCategory.value != 'All')
                          Chip(
                            label: Text(
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: controller.selectedAges.isNotEmpty
                                    ? const Color(0xFF0B5D51)
                                    : Colors.black87,
                              ),
                              controller.selectedCategory.value,
                            ),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () {
                              controller.selectedCategory.value = 'All';
                              controller.fetchEvents();
                            },
                          ),
                        ...controller.selectedAges.map(
                          (age) => Chip(
                            label: Text(
                              age,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: controller.selectedAges.isNotEmpty
                                    ? const Color(0xFF0B5D51)
                                    : Colors.black87,
                              ),
                            ),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () {
                              controller.selectedAges.remove(age);
                              controller.fetchEvents();
                            },
                          ),
                        ),
                        ActionChip(
                          backgroundColor: Colors.red.shade50,
                          label: const Text(
                            "Clear All",
                          ),
                          onPressed: controller.clearFilters,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // EVENT COUNT
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Obx(
                () => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${controller.events.length} Events Found",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // EVENTS
            Expanded(
              child: Obx(
                () {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.events.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 70,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "No events found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.fetchEvents,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.events.length,
                      itemBuilder: (_, index) {
                        final event = controller.events[index];

                        return GestureDetector(
                          onTap: () {
                            Get.toNamed(
                              Routes.EVENT_DETAIL,
                              arguments: event.eventId,
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 16,
                            ),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                28,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    0.06,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(
                                    0,
                                    4,
                                  ),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        20,
                                      ),
                                      child: Image.network(
                                        event.coverImage,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 120,
                                          height: 120,
                                          color: Colors.grey.shade300,
                                          child: const Icon(
                                            Icons.image,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Color(
                                            0xFF0B5D51,
                                          ),
                                          borderRadius: BorderRadius.vertical(
                                            bottom: Radius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          event.category,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 18,
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 120,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            height: 1.15,
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 20,
                                              color: Colors.grey.shade500,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                event.location.split(',').first,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_outlined,
                                              size: 18,
                                              color: Colors.grey.shade500,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                event.startDate
                                                    .split('T')
                                                    .first,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person_outline,
                                              size: 20,
                                              color: Colors.grey.shade500,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                event.hostName,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCategoryFilter(
    BuildContext context,
    SearchEventController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFFF7FAF8),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Select Category',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B5D51),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.8,
              children: controller.categories
                  .where((e) => e != 'All')
                  .map((category) {
                return Obx(() {
                  final selected =
                      controller.selectedCategory.value == category;

                  return GestureDetector(
                    onTap: () {
                      controller.selectedCategory.value = category;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 200,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(
                                0xFF0B5D51,
                              )
                            : const Color(
                                0xFFF3F7F5,
                              ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? const Color(
                                  0xFF0B5D51,
                                )
                              : const Color(
                                  0xFFD7E7E1,
                                ),
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(
                                  0xFF0B5D51,
                                ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFE7F3EF),
                      foregroundColor: const Color(0xFF0B5D51),
                      minimumSize: const Size(
                        double.infinity,
                        54,
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      controller.selectedCategory.value = 'All';
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B5D51),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(
                        double.infinity,
                        54,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      controller.fetchEvents();
                      Get.back();
                    },
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showAgeFilter(
    BuildContext context,
    SearchEventController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Select Age Range',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B5D51),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose one or more age groups',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: controller.ageRanges.map((age) {
                  final selected = controller.selectedAges.contains(age);

                  return GestureDetector(
                    onTap: () {
                      if (selected) {
                        controller.selectedAges.remove(age);
                      } else {
                        controller.selectedAges.add(age);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 200,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF0B5D51)
                            : const Color(0xFFF3F7F5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF0B5D51)
                              : const Color(0xFFD7E7E1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            size: 18,
                            color: selected ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            age,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF0B5D51),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        54,
                      ),
                      foregroundColor: const Color(0xFF0B5D51),
                      side: const BorderSide(
                        color: Color(0xFF0B5D51),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      controller.selectedAges.clear();
                    },
                    child: const Text(
                      'Clear',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B5D51),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(
                        double.infinity,
                        54,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      controller.fetchEvents();
                      Get.back();
                    },
                    child: const Text(
                      'Apply',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
