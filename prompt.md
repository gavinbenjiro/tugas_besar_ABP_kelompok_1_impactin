..
# lets integrate our api based on these project information i gave u 

# C:\Users\veiro\Documents\research\tugas_besar_ABP_kelompok_1_impactin\mobile_user\lib\app\core\api

## api_client.dart
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

import '../storage/storage_keys.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.60.242:8080/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = GetStorage().read(
            StorageKeys.token,
          );

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          handler.next(options);
        },
      ),
    );
}


## api_endpoints.dart

class ApiEndpoints {
  static const register = "/user/register";
  static const login = "/user/login";
  static const getProfile = "/user/profile";

  static const getAllEvents = "/user/events";

  static String getEventDetail(int eventId) => "$getAllEvents/$eventId";

  static String getEventsByCategory(String category) =>
      "/user/events?category=$category";

  static const getRecommendationEvents = "/user/events/recommendation";

  static String getJoinedEvents(String status) =>
      "/user/events/joined?status=$status";

  static String getCreatedEvents(String status) =>
      "/user/events/your?status=$status";
  static const createEvent = "/user/events/";
  static String getCreatedEventDetail(int eventId) =>
      "/user/events/your/$eventId";

  static String cancelEvent(int eventId) => "/user/events/cancel/$eventId";

  static String closeEvent(int eventId) => "/user/events/close/$eventId";

  static String openEvent(int eventId) => "/user/events/open/$eventId";

  static String approveApplicant(int userId) =>
      "/user/events/applicants/$userId";
  static String removeParticipant(int userId) =>
      "/user/events/participants/$userId";
}


## event_api.dart
import 'package:dio/dio.dart';

import 'api_client.dart';
import 'api_endpoints.dart';
import '../../data/models/event_model.dart';
import '../../data/models/manage_event_model.dart';

class EventApi {
  static Future<Response> getAllEvents() {
    return ApiClient.dio.get(
      ApiEndpoints.getAllEvents,
    );
  }

  static Future<EventModel> getEventDetail(int eventId) async {
    try {
      final response = await ApiClient.dio.get(
        ApiEndpoints.getEventDetail(eventId),
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return EventModel.fromJson(data);
      }

      throw Exception('Invalid event detail response');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to load event detail',
      );
    } catch (e) {
      throw Exception('Failed to load event detail');
    }
  }

  static Future<Response> getEventsByCategory(
    String category,
  ) {
    return ApiClient.dio.get(
      ApiEndpoints.getEventsByCategory(category),
    );
  }

  static Future<Response> getRecommendationEvents() {
    return ApiClient.dio.get(
      ApiEndpoints.getRecommendationEvents,
    );
  }

  static Future<Response> getJoinedEvents(
    String status,
  ) {
    return ApiClient.dio.get(
      ApiEndpoints.getJoinedEvents(status),
    );
  }

  static Future<Response> getCreatedEvents(
    String status,
  ) {
    return ApiClient.dio.get(
      ApiEndpoints.getCreatedEvents(status),
    );
  }

  static Future<Response> createEvent({
    required Map<String, dynamic> body,
  }) {
    return ApiClient.dio.post(
      ApiEndpoints.createEvent,
      data: body,
    );
  }

  static Future<ManageEventModel> getCreatedEventDetail(
    int eventId,
  ) async {
    try {
      final response = await ApiClient.dio.get(
        ApiEndpoints.getCreatedEventDetail(
          eventId,
        ),
      );

      return ManageEventModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to load event',
      );
    }
  }

  static Future<Response> cancelEvent(
    int eventId,
  ) {
    return ApiClient.dio.patch(
      ApiEndpoints.cancelEvent(eventId),
    );
  }

  static Future<Response> closeEvent(
    int eventId,
  ) {
    return ApiClient.dio.patch(
      ApiEndpoints.closeEvent(eventId),
    );
  }

  static Future<Response> openEvent(
    int eventId,
  ) {
    return ApiClient.dio.patch(
      ApiEndpoints.openEvent(eventId),
    );
  }

  static Future<Response> updateApplicant({
    required int applicantId,
    required int userId,
    required String action,
  }) {
    return ApiClient.dio.patch(
      ApiEndpoints.approveApplicant(applicantId),
      data: {
        "user_id": userId,
        "action": action,
      },
    );
  }

  static Future<Response> removeParticipant({
    required int participantId,
    required int userId,
  }) {
    return ApiClient.dio.delete(
      ApiEndpoints.removeParticipant(participantId),
      data: {
        "user_id": userId,
      },
    );
  }
}

# C:\Users\veiro\Documents\research\tugas_besar_ABP_kelompok_1_impactin\mobile_user\lib\app\data\models

// create model if needed

# C:\Users\veiro\Documents\research\tugas_besar_ABP_kelompok_1_impactin\mobile_user\lib\app\modules\search_event

## search_event_controller

import 'package:get/get.dart';

class SearchEventController extends GetxController {
  //TODO: Implement SearchEventController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}


## search_event_view

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/dummies/event_dummy.dart';
import '../../../widgets/custom_bottom_navbar.dart';
import '../../../widgets/event_card.dart';

class SearchEventView extends StatefulWidget {
  const SearchEventView({super.key});

  @override
  State<SearchEventView> createState() => _SearchEventViewState();
}

class _SearchEventViewState extends State<SearchEventView> {
  final TextEditingController searchController = TextEditingController();

  String selectedCategory = 'All';

  final List<String> selectedAges = [];

  List filteredEvents = dummyEvents;

  final categories = [
    'All',
    'Environment',
    'Education',
    'Health',
    'Community',
  ];

  final ageRanges = [
    '< 16 Tahun',
    '16 - 20 Tahun',
    '21 - 30 Tahun',
    '31 - 40 Tahun',
    '40 - 45 Tahun',
    '> 45 Tahun',
  ];

  @override
  void initState() {
    super.initState();

    applyFilter();
  }

  void applyFilter() {
    final keyword = searchController.text.toLowerCase();

    setState(() {
      filteredEvents = dummyEvents.where((event) {
        final matchSearch = event.title.toLowerCase().contains(keyword) ||
            event.location.toLowerCase().contains(keyword);

        final matchCategory = selectedCategory == 'All'
            ? true
            : event.category == selectedCategory;

        bool matchAge = true;

        if (selectedAges.isNotEmpty) {
          matchAge = selectedAges.any((range) {
            if (range == '< 16 Tahun') {
              return event.minAge < 16;
            }

            if (range == '16 - 20 Tahun') {
              return event.minAge >= 16 && event.maxAge <= 20;
            }

            if (range == '21 - 30 Tahun') {
              return event.minAge >= 21 && event.maxAge <= 30;
            }

            if (range == '31 - 40 Tahun') {
              return event.minAge >= 31 && event.maxAge <= 40;
            }

            if (range == '40 - 45 Tahun') {
              return event.minAge >= 40 && event.maxAge <= 45;
            }

            if (range == '> 45 Tahun') {
              return event.maxAge > 45;
            }

            return true;
          });
        }

        return matchSearch && matchCategory && matchAge;
      }).toList();
    });
  }

  void showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          expand: false,
          builder: (
            context,
            scrollController,
          ) {
            return StatefulBuilder(
              builder: (
                context,
                modalSetState,
              ) {
                return Container(
                  padding: const EdgeInsets.all(
                    24,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(
                        32,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DRAG HANDLE
                      Center(
                        child: Container(
                          width: 60,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(
                              100,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            // TITLE
                            const Text(
                              'Filter',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(
                                  0xFF0B5D51,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 26,
                            ),

                            // CATEGORY
                            const Text(
                              'Event Category',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(
                                  0xFF0B5D51,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            ...categories
                                .where(
                                  (e) => e != 'All',
                                )
                                .map(
                                  (category) => RadioListTile<String>(
                                    value: category,
                                    groupValue: selectedCategory,
                                    activeColor: const Color(
                                      0xFF0B5D51,
                                    ),
                                    title: Text(
                                      category,
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    onChanged: (
                                      value,
                                    ) {
                                      modalSetState(
                                        () {
                                          selectedCategory = value!;
                                        },
                                      );
                                    },
                                  ),
                                ),

                            const SizedBox(
                              height: 20,
                            ),

                            // AGE
                            const Text(
                              'Age Range',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(
                                  0xFF0B5D51,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            ...ageRanges.map(
                              (age) => CheckboxListTile(
                                value: selectedAges.contains(
                                  age,
                                ),
                                title: Text(
                                  age,
                                ),
                                activeColor: const Color(
                                  0xFF0B5D51,
                                ),
                                contentPadding: EdgeInsets.zero,
                                onChanged: (
                                  value,
                                ) {
                                  modalSetState(
                                    () {
                                      if (value == true) {
                                        selectedAges.add(
                                          age,
                                        );
                                      } else {
                                        selectedAges.remove(
                                          age,
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ),

                            const SizedBox(
                              height: 30,
                            ),

                            // APPLY BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xFF004D43,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      18,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  applyFilter();

                                  Navigator.pop(
                                    context,
                                  );
                                },
                                child: const Text(
                                  'Apply Filter',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  20,
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF5E6F68),
                      Color(0xFF0B5D51),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          16,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: (value) {
                                applyFilter();
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search Event',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // FILTER BAR
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: showFilterBottomSheet,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF0B5D51,
                          ),
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: const Icon(
                          Icons.tune,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // CATEGORY
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            isExpanded: true,
                            items: categories.map(
                              (e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                  ),
                                );
                              },
                            ).toList(),
                            onChanged: (
                              value,
                            ) {
                              setState(
                                () {
                                  selectedCategory = value!;
                                },
                              );

                              applyFilter();
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // AGE
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text(
                              'Age',
                            ),
                            value: selectedAges.isNotEmpty &&
                                    ageRanges.contains(
                                      selectedAges.first,
                                    )
                                ? selectedAges.first
                                : null,
                            items: ageRanges.map(
                              (e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                  ),
                                );
                              },
                            ).toList(),
                            onChanged: (
                              value,
                            ) {
                              setState(
                                () {
                                  selectedAges.clear();

                                  if (value != null) {
                                    selectedAges.add(
                                      value,
                                    );
                                  }
                                },
                              );

                              applyFilter();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // EVENTS
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  return EventCard(
                    event: filteredEvents[index],
                  );
                },
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavbar(
        currentIndex: 1,
      ),
    );
  }
}

