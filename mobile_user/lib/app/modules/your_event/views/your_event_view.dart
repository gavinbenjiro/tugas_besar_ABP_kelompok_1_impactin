import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
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
                      // =================================================
                      // TITLE & SUBTITLE
                      // =================================================
                      Positioned(
                        left: size.width * 0.05,
                        bottom:
                            size.height * 0.025, // Sedikit dinaikkan agar pas
                        width: size.width *
                            0.9, // Membatasi lebar agar text bisa wrap
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Your Events",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.075,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Track the events you've joined and the impact you've made.",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: size.width * 0.033,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.018),

                  // =================================================
                  // CUSTOM TABS (JOINED & CREATED) + FILTER BUTTON
                  // =================================================
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 11,
                          child: AnimatedBuilder(
                            animation: tabController,
                            builder: (context, _) {
                              final isJoinedTab = tabController.index == 0;
                              final isCreatedTab = tabController.index == 1;

                              return Row(
                                children: [
                                  // Tombol Joined
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        minimumSize: Size(double.infinity,
                                            size.height * 0.05),
                                        backgroundColor: isJoinedTab
                                            ? const Color(0xFFE7F3EF)
                                            : Colors.white,
                                        side: BorderSide(
                                          color: isJoinedTab
                                              ? const Color(0xFF0B5D51)
                                              : Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      onPressed: () {
                                        tabController.animateTo(0);
                                        controller.changeJoinedStatus('all');
                                      },
                                      child: Text(
                                        "Joined",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: isJoinedTab
                                              ? const Color(0xFF0B5D51)
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Tombol Created
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        minimumSize: Size(double.infinity,
                                            size.height * 0.05),
                                        backgroundColor: isCreatedTab
                                            ? const Color(0xFFE7F3EF)
                                            : Colors.white,
                                        side: BorderSide(
                                          color: isCreatedTab
                                              ? const Color(0xFF0B5D51)
                                              : Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      onPressed: () {
                                        tabController.animateTo(1);
                                        controller.changeCreatedStatus('all');
                                      },
                                      child: Text(
                                        "Created",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: isCreatedTab
                                              ? const Color(0xFF0B5D51)
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        SizedBox(width: size.width * 0.02),

                        // CUSTOM OUTLINED FILTER BUTTON
                        Expanded(
                          flex: 7,
                          child: AnimatedBuilder(
                            animation: tabController,
                            builder: (_, __) {
                              final isJoinedTab = tabController.index == 0;

                              return Obx(() {
                                final selectedStatus = isJoinedTab
                                    ? controller.selectedJoinedStatus.value
                                    : controller.selectedCreatedStatus.value;
                                final isFiltered = selectedStatus != 'all';

                                return OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    minimumSize: Size(
                                        double.infinity, size.height * 0.05),
                                    backgroundColor: isFiltered
                                        ? const Color(0xFFE7F3EF)
                                        : Colors.white,
                                    side: BorderSide(
                                      color: isFiltered
                                          ? const Color(0xFF0B5D51)
                                          : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.filter_list,
                                    size: 16,
                                    color: isFiltered
                                        ? const Color(0xFF0B5D51)
                                        : Colors.grey.shade600,
                                  ),
                                  label: Text(
                                    isFiltered
                                        ? _capitalize(selectedStatus)
                                        : 'Status',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isFiltered
                                          ? const Color(0xFF0B5D51)
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  onPressed: () {
                                    _showStatusFilter(
                                        context, controller, isJoinedTab);
                                  },
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.01),

                  // =================================================
                  // ACTIVE FILTERS (CHIPS)
                  // =================================================
                  AnimatedBuilder(
                    animation: tabController,
                    builder: (_, __) {
                      final isJoinedTab = tabController.index == 0;

                      return Obx(() {
                        final selectedStatus = isJoinedTab
                            ? controller.selectedJoinedStatus.value
                            : controller.selectedCreatedStatus.value;

                        if (selectedStatus == 'all') {
                          return const SizedBox();
                        }

                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.04,
                            vertical: 4,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Chip(
                                  label: Text(
                                    _capitalize(selectedStatus),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0B5D51),
                                    ),
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () {
                                    if (isJoinedTab) {
                                      controller.changeJoinedStatus('all');
                                    } else {
                                      controller.changeCreatedStatus('all');
                                    }
                                  },
                                ),
                                ActionChip(
                                  backgroundColor: Colors.red.shade50,
                                  label: const Text(
                                    "Clear All",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () {
                                    if (isJoinedTab) {
                                      controller.changeJoinedStatus('all');
                                    } else {
                                      controller.changeCreatedStatus('all');
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
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
                              final event = controller.createdEvents[index];
                              return YourEventCard(
                                event: event,
                                showManageButton: event.status == "approved" &&
                                    event.subStatus != "cancelled" &&
                                    event.subStatus != "completed",
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

  // =================================================
  // BOTTOM SHEET SELECTOR (FIXED OVERFLOW & GETX ERROR)
  // =================================================
  void _showStatusFilter(
    BuildContext context,
    YourEventController controller,
    bool isJoinedTab,
  ) {
    final List<String> statuses = isJoinedTab
        ? ['all', 'ongoing', 'upcoming', 'completed', 'cancelled']
        : ['all', 'pending', 'approved', 'declined', 'completed', 'cancelled'];

    String tempSelected = isJoinedTab
        ? controller.selectedJoinedStatus.value
        : controller.selectedCreatedStatus.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const Text(
                        "Select Status",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B5D51),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.8,
                        ),
                        itemCount: statuses.length,
                        itemBuilder: (context, index) {
                          final status = statuses[index];
                          final isSelected = tempSelected == status;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                tempSelected = status;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF0F7F4)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF0B5D51)
                                      : Colors.grey.shade200,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                _capitalize(status),
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF0B5D51)
                                      : Colors.grey.shade700,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 54),
                                backgroundColor: const Color(0xFFF0F7F4),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  tempSelected = 'all';
                                });
                              },
                              child: const Text(
                                "Clear",
                                style: TextStyle(
                                  color: Color(0xFF0B5D51),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 54),
                                backgroundColor: const Color(0xFF0B5D51),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                if (isJoinedTab) {
                                  controller.changeJoinedStatus(tempSelected);
                                } else {
                                  controller.changeCreatedStatus(tempSelected);
                                }
                                Get.back();
                              },
                              child: const Text(
                                "Apply",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
