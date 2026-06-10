import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/manage_event_controller.dart';

class ManageEventView extends GetView<ManageEventController> {
  const ManageEventView({super.key});

  @override
  Widget build(BuildContext context) {
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
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
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
                        padding: const EdgeInsets.all(
                          22,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(
                                  0xFF114B3A,
                                ),
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
                                    onPressed: () {
                                      if (event.canOpen) {
                                        controller.openEvent();
                                      } else if (event.canClose) {
                                        controller.closeEvent();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: event.canOpen
                                          ? Colors.green
                                          : const Color(0xFFE6B325),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      minimumSize: const Size(
                                        0,
                                        52,
                                      ),
                                    ),
                                    child: Text(
                                      event.canOpen
                                          ? "Open Event"
                                          : "Close Event",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
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
                      // TABS
                      // ==========================================
                      const TabBar(
                        labelColor: Color(0xFF114B3A),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Color(0xFF114B3A),
                        tabs: [
                          Tab(
                            text: "Applicant",
                          ),
                          Tab(
                            text: "Participant",
                          ),
                        ],
                      ),

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
                                    padding: const EdgeInsets.all(
                                      16,
                                    ),
                                    itemCount: event.applicants.length,
                                    itemBuilder: (
                                      context,
                                      index,
                                    ) {
                                      final user = event.applicants[index];

                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(
                                          14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFD7ECE4,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                const CircleAvatar(
                                                  backgroundColor: Color(
                                                    0xFF114B3A,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 12,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    user.name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {},
                                                  child: const Text(
                                                    "details",
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      controller
                                                          .approveApplicant(
                                                        user.userId,
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                    child: const Text(
                                                      "Approve",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 8,
                                                ),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      controller
                                                          .rejectApplicant(
                                                        user.userId,
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                    child: const Text(
                                                      "Reject",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
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
                                    padding: const EdgeInsets.all(
                                      16,
                                    ),
                                    itemCount: event.participants.length,
                                    itemBuilder: (
                                      context,
                                      index,
                                    ) {
                                      final user = event.participants[index];

                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(
                                          14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFD7ECE4,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const CircleAvatar(
                                              backgroundColor: Color(
                                                0xFF114B3A,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Expanded(
                                              child: Text(
                                                user.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Get.defaultDialog(
                                                  title: "Remove Participant",
                                                  middleText:
                                                      "Are you sure you want to remove ${user.name}?",
                                                  textCancel: "No",
                                                  textConfirm: "Yes",
                                                  confirmTextColor:
                                                      Colors.white,
                                                  onConfirm: () {
                                                    Get.back();

                                                    controller
                                                        .removeParticipant(
                                                      user.userId,
                                                    );
                                                  },
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: const Text(
                                                "Remove",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
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
}

Widget actionButton({
  required String text,
  required Color color,
  required bool enabled,
  required VoidCallback onPressed,
}) {
  return Expanded(
    child: ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color : Colors.grey.shade300,
        disabledBackgroundColor: Colors.grey.shade300,
        foregroundColor: enabled ? Colors.white : Colors.grey,
        disabledForegroundColor: Colors.grey,
        elevation: enabled ? 3 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: enabled
              ? BorderSide.none
              : BorderSide(
                  color: Colors.red.shade300,
                  width: 1.5,
                ),
        ),
        minimumSize: const Size(
          0,
          52,
        ),
      ),
      child: Text(text),
    ),
  );
}
