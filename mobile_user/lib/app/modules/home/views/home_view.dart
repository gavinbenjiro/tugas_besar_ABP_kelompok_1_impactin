import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_user/app/widgets/custom_bottom_navbar.dart';

import '../../../data/dummies/event_dummy.dart';
import '../../../widgets/custom_category_chip.dart';
import '../../../widgets/event_card.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final bannerEvent = dummyEvents.first;
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
                  Container(
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
                        Positioned(
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // BANNER
              Container(
                width: double.infinity,
                height: width * 0.55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset(
                          bannerEvent.coverImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // DARK OVERLAY
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: Colors.black.withOpacity(0.25),
                        ),
                      ),
                    ),

                    // CONTENT
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bannerEvent.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.08,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  bannerEvent.location,
                                  overflow: TextOverflow.ellipsis,
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

                    Positioned(
                      left: 14,
                      top: width * 0.22,
                      child: _circleButton(
                        Icons.arrow_back_ios_new,
                      ),
                    ),

                    Positioned(
                      right: 14,
                      top: width * 0.22,
                      child: _circleButton(
                        Icons.arrow_forward_ios,
                      ),
                    ),
                  ],
                ),
              ),

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
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    CustomCategoryChip(
                      title: 'All',
                      isSelected: true,
                    ),
                    CustomCategoryChip(
                      title: 'Environtmen',
                    ),
                    CustomCategoryChip(
                      title: 'Education',
                    ),
                    CustomCategoryChip(
                      title: 'Health',
                    ),
                    CustomCategoryChip(
                      title: 'Community',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // EVENTS
              ListView.builder(
                itemCount: dummyEvents.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final event = dummyEvents[index];

                  return EventCard(event: event);
                },
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

  Widget _circleButton(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: Color(0xFF0B5D51),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}
