// =========================================================
// IMPROVED YOUR EVENT VIEW
// CLEAN UI LIKE SLICING
// =========================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/dummies/event_dummy.dart';
import '../../../widgets/custom_bottom_navbar.dart';
import '../../../widgets/your_event_card.dart';
import '../controllers/your_event_controller.dart';

class YourEventView extends GetView<YourEventController> {
  const YourEventView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const String currentHost = "pei";

    final joinedEvents = dummyEvents.where((event) {
      return event.joinStatus.isNotEmpty;
    }).toList();

    final createdEvents = dummyEvents.where((event) {
      return event.host == currentHost && event.creatStatus.isNotEmpty;
    }).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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

                  // =============================================
                  // GREEN WAVES
                  // =============================================
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

                  // =============================================
                  // TITLE
                  // =============================================
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
                    // =============================================
                    // TAB BAR
                    // =============================================
                    Expanded(
                      child: Container(
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

                    // =============================================
                    // FILTER UI
                    // =============================================
                    Container(
                      height: size.height * 0.05,
                      width: size.width * 0.28,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "All",
                            style: TextStyle(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                            size: size.width * 0.06,
                          ),
                        ],
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
                    // =============================================
                    // JOINED EVENTS
                    // =============================================
                    ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: size.height * 0.005,
                        bottom: size.height * 0.13,
                      ),
                      itemCount: joinedEvents.length,
                      itemBuilder: (context, index) {
                        return YourEventCard(
                          event: joinedEvents[index],
                        );
                      },
                    ),

                    // =============================================
                    // CREATED EVENTS
                    // =============================================
                    ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: size.height * 0.005,
                        bottom: size.height * 0.13,
                      ),
                      itemCount: createdEvents.length,
                      itemBuilder: (context, index) {
                        return YourEventCard(
                          event: createdEvents[index],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // =====================================================
        // BOTTOM NAVBAR
        // =====================================================
        bottomNavigationBar: const CustomBottomNavbar(
          currentIndex: 2,
        ),
      ),
    );
  }
}
