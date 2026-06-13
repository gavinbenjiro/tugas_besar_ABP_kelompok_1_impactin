import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/manage_event_controller.dart';

class ManageEventView extends GetView<ManageEventController> {
  const ManageEventView({super.key});

  @override
  Widget build(BuildContext context) {
    final width_size = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final event = controller.event.value;

        if (event == null) {
          return const Center(
            child: Text("Event not found"),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // =====================================================
              // HERO IMAGE
              // =====================================================
              SizedBox(
                height: 260,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      event.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return Container(
                          color: const Color(0xFF114B3A),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (
                          context,
                          child,
                          progress,
                          ) {
                        if (progress == null) return child;

                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                    Positioned(
                      top: 50,
                      left: 16,
                      child: GestureDetector(
                        onTap: Get.back,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =====================================================
              // CONTENT CARD
              // =====================================================
              Expanded(
                child: Container(
                  width: double.infinity,
                  transform: Matrix4.translationValues(
                    0,
                    -24,
                    0,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(
                          width_size * 0.05,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: TextStyle(
                                fontSize: width_size * 0.08,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF114B3A),
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(
                              height: 18,
                            ),

                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  event.startDate
                                      .split(
                                    "T",
                                  )
                                      .first,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Text(
                                    event.location,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 18,
                            ),

                            Row(
                              children: [
                                const Icon(
                                  Icons.people,
                                  color: Color(
                                    0xFF114B3A,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "${event.currentParticipant}/${event.maxParticipant} participants",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(
                                      0xFF114B3A,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 24,
                            ),

                            // =====================================
                            // ACTION BUTTONS
                            // =====================================

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                    (!event.canOpen && !event.canClose)
                                        ? null
                                        : () {
                                      if (event.canOpen) {
                                        controller.openEvent();
                                      } else if (event.canClose) {
                                        controller.closeEvent();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      !event.canOpen && !event.canClose
                                          ? Colors.grey.shade400
                                          : event.canOpen
                                          ? Colors.green
                                          : const Color(0xFFE6B325),
                                      disabledBackgroundColor:
                                      Colors.grey.shade400,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      minimumSize: const Size(
                                        0,
                                        52,
                                      ),
                                    ),
                                    child: Text(
                                      !event.canOpen && !event.canClose
                                          ? "Event Ongoing"
                                          : event.canOpen
                                          ? "Open Event"
                                          : "Close Event",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: controller.cancelEvent,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      minimumSize: const Size(
                                        0,
                                        52,
                                      ),
                                    ),
                                    child: const Text(
                                      "Cancel Event",
                                      style: TextStyle(
                                        color: Colors.white,
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

                      // ==========================================
                      // CUSTOM TABS (Gaya Filter SearchEvent)
                      // ==========================================
                      Builder(
                        builder: (context) {
                          final tabController = DefaultTabController.of(context);
                          return AnimatedBuilder(
                            animation: tabController,
                            builder: (context, child) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: width_size * 0.05),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildTabButton(
                                        "Applicant",
                                        Icons.person_outline,
                                        0,
                                        tabController,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTabButton(
                                        "Participant",
                                        Icons.people_alt_outlined,
                                        1,
                                        tabController,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: TabBarView(
                          children: [
                            // =====================================
                            // APPLICANTS
                            // =====================================
                            event.applicants.isEmpty
                                ? const Center(
                              child: Text(
                                "No applicants yet",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            )
                                : ListView.builder(
                              padding: EdgeInsets.all(width_size * 0.04),
                              itemCount: event.applicants.length,
                              itemBuilder: (
                                  context,
                                  index,
                                  ) {
                                final user = event.applicants[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD7ECE4),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: width_size * 0.05,
                                            backgroundColor: const Color(0xFF114B3A),
                                            child: const Icon(Icons.person, color: Colors.white, size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              user.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: width_size * 0.038,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {},
                                            child: const Text("details"),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                controller.approveApplicant(user.userId);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                              child: const Text("Approve", style: TextStyle(color: Colors.white)),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                controller.rejectApplicant(user.userId);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                              child: const Text("Reject", style: TextStyle(color: Colors.white)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            // =====================================
                            // PARTICIPANTS
                            // =====================================
                            event.participants.isEmpty
                                ? const Center(
                              child: Text(
                                "No participants yet",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            )
                                : ListView.builder(
                              padding: EdgeInsets.all(width_size * 0.04),
                              itemCount: event.participants.length,
                              itemBuilder: (
                                  context,
                                  index,
                                  ) {
                                final user = event.participants[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD7ECE4),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: width_size * 0.05,
                                        backgroundColor: const Color(0xFF114B3A),
                                        child: const Icon(Icons.person, color: Colors.white, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          user.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: width_size * 0.038,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Get.defaultDialog(
                                            title: "Remove Participant",
                                            middleText: "Are you sure you want to remove ${user.name}?",
                                            textCancel: "No",
                                            textConfirm: "Yes",
                                            confirmTextColor: Colors.white,
                                            buttonColor: Colors.red,
                                            cancelTextColor: Colors.grey.shade700,
                                            onConfirm: () {
                                              Get.back();
                                              controller.removeParticipant(user.userId);
                                            },
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: const Text("Remove", style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // =====================================================
  // FUNGSI UNTUK MERENDER TOMBOL TAB (STYLE SEARCH EVENT)
  // =====================================================
  Widget _buildTabButton(
      String text,
      IconData icon,
      int index,
      TabController tabController,
      ) {
    final isSelected = tabController.index == index;

    return GestureDetector(
      onTap: () => tabController.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE7F3EF)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0B5D51)
                : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? const Color(0xFF0B5D51)
                  : Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF0B5D51)
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}