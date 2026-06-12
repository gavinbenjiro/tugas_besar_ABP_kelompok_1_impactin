import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_user/app/widgets/custom_bottom_navbar.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/custom_category_chip.dart';
import '../../../widgets/event_card.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Explore the world!',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: width * 0.09,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      await Get.toNamed(
                        Routes.NOTIFICATION,
                      );

                      controller.getBellStatus();
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.notifications_none,
                              size: 26,
                            ),
                          ),
                          Obx(
                            () => controller.hasUnreadNotification.value
                                ? Positioned(
                                    top: 12,
                                    right: 14,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // BANNER
              Obx(() {
                if (controller.recommendedEvents.isEmpty) {
                  return Container(
                    width: double.infinity,
                    height: width * 0.55,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return SizedBox(
                  height: width * 0.55,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: PageView.builder(
                          controller: controller.bannerPageController,
                          onPageChanged: (index) {
                            controller.currentBannerIndex.value = index;
                          },
                          itemCount: controller.recommendedEvents.length,
                          itemBuilder: (context, index) {
                            final bannerEvent =
                                controller.recommendedEvents[index];

                            return GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  Routes.EVENT_DETAIL,
                                  arguments: bannerEvent["event_id"],
                                );
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    bannerEvent["cover_image"] ?? "",
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    color: Colors.black.withOpacity(
                                      0.25,
                                    ),
                                  ),
                                  Positioned(
                                    left: 20,
                                    right: 20,
                                    bottom: 30,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.25),
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                          child: Text(
                                            bannerEvent["title"] ?? "",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: width * 0.08,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                bannerEvent["location"] ?? "",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.recommendedEvents.length,
                            (index) {
                              final active =
                                  controller.currentBannerIndex.value == index;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: active ? 28 : 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 30),

              // CATEGORY HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: width * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'See all',
                    style: TextStyle(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // CATEGORY LIST
              Obx(
                () => SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      CustomCategoryChip(
                        title: 'All',
                        isSelected: controller.selectedCategory.value == 'All',
                        onTap: () => controller.changeCategory('All'),
                      ),
                      CustomCategoryChip(
                        title: 'Environment',
                        isSelected:
                            controller.selectedCategory.value == 'Environment',
                        onTap: () => controller.changeCategory(
                          'Environment',
                        ),
                      ),
                      CustomCategoryChip(
                        title: 'Education',
                        isSelected:
                            controller.selectedCategory.value == 'Education',
                        onTap: () => controller.changeCategory(
                          'Education',
                        ),
                      ),
                      CustomCategoryChip(
                        title: 'Health',
                        isSelected:
                            controller.selectedCategory.value == 'Health',
                        onTap: () => controller.changeCategory('Health'),
                      ),
                      CustomCategoryChip(
                        title: 'Community',
                        isSelected:
                            controller.selectedCategory.value == 'Community',
                        onTap: () => controller.changeCategory(
                          'Community',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // EVENTS
              Obx(
                () => ListView.builder(
                  itemCount: controller.events.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final event = controller.events[index];

                    return EventCard(
                      event: event,
                    );
                  },
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // NAVBAR
      bottomNavigationBar: const CustomBottomNavbar(
        currentIndex: 0,
      ),
    );
  }
}
