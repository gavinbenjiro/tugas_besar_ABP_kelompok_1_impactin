// =========================================================
// IMPROVED YOUR EVENT VIEW
// CLEAN UI LIKE SLICING
// =========================================================

import 'package:flutter/material.dart';
import '../../../routes/app_pages.dart';
import 'package:get/get.dart';

import '../../../widgets/custom_bottom_navbar.dart';
import '../../../widgets/your_event_card.dart';
import '../controllers/your_event_controller.dart';

class YourEventView extends GetView<YourEventController> {
  const YourEventView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context)!;

          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: SafeArea(
              child: Column(
                children: [
                  // =================================================
                  // HEADER
                  // =================================================
                  Stack(
                    children: [
                      Container(
                        height: size.height * 0.16,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF114B3A),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -40,
                        left: -20,
                        child: Container(
                          width: size.width * 0.9,
                          height: size.height * 0.16,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -20,
                        right: -40,
                        child: Container(
                          width: size.width * 0.8,
                          height: size.height * 0.13,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -20,
                        left: size.width * 0.15,
                        child: Container(
                          width: size.width * 0.7,
                          height: size.height * 0.09,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                      Positioned(
                        left: size.width * 0.05,
                        bottom: size.height * 0.03,
                        child: Text(
                          "Your Events",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.075,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.018),

                  // =================================================
                  // TABS + FILTER
                  // =================================================
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.025,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: size.height * 0.05,
                            child: TabBar(
                              dividerColor: Colors.transparent,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                color: const Color(0xFF114B3A),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.grey,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: size.width * 0.038,
                              ),
                              tabs: const [
                                Tab(text: "Joined"),
                                Tab(text: "Created"),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: size.width * 0.025),

                        // =================================================
                        // FILTER
                        // =================================================
                        Container(
                          height: size.height * 0.05,
                          width: size.width * 0.34,
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.03,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AnimatedBuilder(
                            animation: tabController,
                            builder: (_, __) {
                              final isJoinedTab = tabController.index == 0;

                              return Obx(
                                () => DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: isJoinedTab
                                        ? controller.selectedJoinedStatus.value
                                        : controller
                                            .selectedCreatedStatus.value,
                                    items: isJoinedTab
                                        ? const [
                                            DropdownMenuItem(
                                              value: 'all',
                                              child: Text('All'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'ongoing',
                                              child: Text('Ongoing'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'upcoming',
                                              child: Text('Upcoming'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'completed',
                                              child: Text('Completed'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'cancelled',
                                              child: Text('Cancelled'),
                                            ),
                                          ]
                                        : const [
                                            DropdownMenuItem(
                                              value: 'all',
                                              child: Text('All'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'pending',
                                              child: Text('Pending'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'approved',
                                              child: Text('Approved'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'declined',
                                              child: Text('Declined'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'completed',
                                              child: Text('Completed'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'cancelled',
                                              child: Text('Cancelled'),
                                            ),
                                          ],
                                    onChanged: (value) {
                                      if (value == null) return;

                                      if (isJoinedTab) {
                                        controller.changeJoinedStatus(value);
                                      } else {
                                        controller.changeCreatedStatus(value);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.01),

                  // =================================================
                  // EVENT LIST
                  // =================================================
                  Expanded(
                    child: TabBarView(
                      children: [
                        // JOINED
                        Obx(() {
                          if (controller.isLoadingJoined.value) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.only(
                              top: size.height * 0.005,
                              bottom: size.height * 0.13,
                            ),
                            itemCount: controller.joinedEvents.length,
                            itemBuilder: (context, index) {
                              return YourEventCard(
                                event: controller.joinedEvents[index],
                              );
                            },
                          );
                        }),

                        // CREATED
                        Obx(() {
                          if (controller.isLoadingCreated.value) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.only(
                              top: size.height * 0.005,
                              bottom: size.height * 0.13,
                            ),
                            itemCount: controller.createdEvents.length,
                            itemBuilder: (context, index) {
                              return YourEventCard(
                                event: controller.createdEvents[index],
                                showManageButton: controller
                                            .createdEvents[index].status ==
                                        "approved" &&
                                    controller.createdEvents[index].subStatus !=
                                        "cancelled",
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: SizedBox(
              width: 56,
              height: 56,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF114B3A),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onPressed: () {
                  Get.toNamed(Routes.CREATE_EVENT);
                },
                child: const Icon(
                  Icons.add,
                  size: 34,
                  color: Colors.white,
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: const CustomBottomNavbar(
              currentIndex: 2,
            ),
          );
        },
      ),
    );
  }
}
