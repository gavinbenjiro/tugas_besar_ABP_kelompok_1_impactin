import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/event_detail_controller.dart';

class EventDetailView extends GetView<EventDetailController> {
  const EventDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final event = controller.event;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // COVER IMAGE
                SizedBox(
                  height: width * 0.95,
                  width: double.infinity,
                  child: Image.asset(
                    event.coverImage,
                    fit: BoxFit.cover,
                  ),
                ),

                // BACK BUTTON
                Positioned(
                  top: 56,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                // AGE CHIP
                Positioned(
                  left: 20,
                  bottom: -20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F5C53),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${event.minAge}-${event.maxAge}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // MAIN CONTENT
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(34),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE + REPORT
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A4F46),
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            Icon(
                              Icons.report_gmailerrorred,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Report',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // DATE
                    _infoTile(
                      Icons.calendar_today_outlined,
                      "${event.startDate} - ${event.endDate}",
                    ),

                    const SizedBox(height: 10),

                    // TIME
                    _infoTile(
                      Icons.access_time,
                      "${event.startTime} - ${event.endTime} WIB",
                    ),

                    const SizedBox(height: 10),

                    // LOCATION
                    _infoTile(
                      Icons.location_on_outlined,
                      event.location,
                    ),

                    const SizedBox(height: 18),

                    // PARTICIPANTS
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 34,
                          child: Stack(
                            children: [
                              _avatar(0),
                              _avatar(24),
                              _avatar(48),
                              _avatar(72),
                              Positioned(
                                left: 96,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF5E756F,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '+99',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "105 participants",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // TABS
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: _tabItem(
                              title: 'About',
                              index: 0,
                            ),
                          ),
                          Expanded(
                            child: _tabItem(
                              title: 'Location',
                              index: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // TAB CONTENT
                    Obx(
                      () => controller.selectedTab.value == 0
                          ? _aboutSection(event)
                          : _locationSection(event),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // BUTTON
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            10,
            24,
            24,
          ),
          child: SizedBox(
            height: 58,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D43),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              onPressed: () {},
              child: const Text(
                'Join Event',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatar(double left) {
    return Positioned(
      left: left,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          image: const DecorationImage(
            image: AssetImage(
              'assets/images/ev_dum2.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _tabItem({
    required String title,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: controller.selectedTab.value == index
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: controller.selectedTab.value == index
                  ? Colors.black
                  : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 2,
            color: controller.selectedTab.value == index
                ? const Color(0xFF0A4F46)
                : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _aboutSection(event) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A4F46),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            event.description,
            style: TextStyle(
              color: Colors.grey.shade800,
              height: 1.7,
              fontSize: 15,
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 18),
          const Text(
            'Terms',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A4F46),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            event.terms,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationSection(event) {
    return Column(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Center(
            child: Icon(
              Icons.location_on,
              size: 54,
              color: Colors.teal.shade300,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.specificAddress,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Color(0xFF0A4F46),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                event.location,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
