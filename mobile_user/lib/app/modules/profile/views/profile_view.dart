import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/custom_bottom_navbar.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Obx(
      () {
        if (controller.isLoading.value) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final data = controller.profile.value;
        final skills = (data?["skills"] as List<dynamic>? ?? []);
        final experiences = (data?["experiences"] as List<dynamic>? ?? []);
        final events = (data?["events"] as List<dynamic>? ?? []);
        final imageUrl = data?["image_url"]?.toString() ?? "";
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: size.height * 0.14,
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          left: size.width * 0.05,
                          right: size.width * 0.05,
                          top: size.height * 0.03,
                          bottom: size.height * 0.03,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF114B3A),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: size.height * 0.02),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: size.width * 0.11,
                                  backgroundColor: Colors.white24,
                                  backgroundImage: imageUrl.isNotEmpty
                                      ? NetworkImage(imageUrl)
                                      : null,
                                  child: imageUrl.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                SizedBox(width: size.width * 0.04),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: size.height * 0.01),
                                      Text(
                                        data?["name"] ?? "Unknown User",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: size.width * 0.06,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: size.height * 0.012),
                                      _infoRow(
                                        context,
                                        Icons.work_outline,
                                        data?["status"] ?? "-",
                                      ),
                                      SizedBox(height: size.height * 0.006),
                                      _infoRow(
                                        context,
                                        Icons.cake_outlined,
                                        "${data?["age"] ?? "-"} Tahun",
                                      ),
                                      SizedBox(height: size.height * 0.006),
                                      _infoRow(
                                        context,
                                        Icons.location_on_outlined,
                                        data?["city"] ?? "-",
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.025),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.05,
                                  vertical: size.height * 0.012,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Edit profile",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: size.width * 0.036,
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.03),
                                    Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white,
                                      size: size.width * 0.05,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                    ],
                  ),
                  SizedBox(height: size.height * 0.018),
                  _sectionCard(
                    context,
                    title: "Description",
                    child: Text(
                      data?["bio"] ?? "-",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: size.width * 0.034,
                        height: 1.5,
                      ),
                    ),
                  ),
                  _sectionCard(
                    context,
                    title: "Skills",
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF114B3A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.white,
                            size: size.width * 0.04,
                          ),
                          SizedBox(width: size.width * 0.01),
                          Text(
                            "Add Skills",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.03,
                            ),
                          ),
                        ],
                      ),
                    ),
                    child: skills.isEmpty
                        ? Text(
                            "No skills yet",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: size.width * 0.034,
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: skills.map<Widget>((skill) {
                              final skillName =
                                  skill["skills"]?.toString() ?? "-";
                              return _skillChip(
                                skillName,
                                Colors.green.shade50,
                                Colors.green.shade800,
                              );
                            }).toList(),
                          ),
                  ),
                  _sectionCard(
                    context,
                    title: "General Experience",
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF114B3A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Add Experience",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.03,
                        ),
                      ),
                    ),
                    child: experiences.isEmpty
                        ? Text(
                            "No experiences yet",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: size.width * 0.034,
                            ),
                          )
                        : Column(
                            children: experiences.map<Widget>((exp) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _experienceCard(
                                  context,
                                  title: exp["title"]?.toString() ?? "-",
                                  creator: exp["creator"]?.toString() ?? "-",
                                  date: exp["date"]?.toString() ?? "-",
                                  description:
                                      exp["description"]?.toString() ?? "-",
                                  coverImage:
                                      exp["cover_image"]?.toString() ?? "",
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  _sectionCard(
                    context,
                    title: "Events",
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF114B3A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "View All",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.03,
                        ),
                      ),
                    ),
                    child: events.isEmpty
                        ? Text(
                            "No events yet",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: size.width * 0.034,
                            ),
                          )
                        : Column(
                            children: events.map<Widget>((event) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _eventCard(
                                  context,
                                  title: event["title"]?.toString() ?? "-",
                                  creator: event["creator"]?.toString() ?? "-",
                                  date: event["start_date"]?.toString() ?? "-",
                                  description:
                                      event["description"]?.toString() ?? "-",
                                  coverImage:
                                      event["cover_image"]?.toString() ?? "",
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.025,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: size.height * 0.065,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          final box = GetStorage();
                          box.remove(StorageKeys.token);
                          box.remove(StorageKeys.userId);
                          box.remove(StorageKeys.username);
                          box.remove(StorageKeys.email);

                          Get.offAllNamed(Routes.LOGIN);
                        },
                        icon: Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: size.width * 0.05,
                        ),
                        label: Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.042,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const CustomBottomNavbar(
            currentIndex: 3,
          ),
        );
      },
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    final size = MediaQuery.of(context).size;

    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: size.width * 0.04,
        ),
        SizedBox(width: size.width * 0.02),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: size.width * 0.036,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    final size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(
        left: size.width * 0.025,
        right: size.width * 0.025,
        bottom: size.height * 0.02,
      ),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.shade100,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: const Color(0xFF114B3A),
                size: size.width * 0.05,
              ),
              SizedBox(width: size.width * 0.02),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF114B3A),
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: size.height * 0.02),
          child,
        ],
      ),
    );
  }

  Widget _skillChip(
    String text,
    Color bg,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _experienceCard(
    BuildContext context, {
    required String title,
    required String creator,
    required String date,
    required String description,
    required String coverImage,
  }) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.green.shade100,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: coverImage.isNotEmpty
                ? Image.network(
                    coverImage,
                    height: size.height * 0.18,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: size.height * 0.18,
                        width: double.infinity,
                        color: Colors.green.shade50,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                        ),
                      );
                    },
                  )
                : Container(
                    height: size.height * 0.18,
                    width: double.infinity,
                    color: Colors.green.shade50,
                    child: const Icon(Icons.image_not_supported),
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: size.width * 0.055,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF114B3A),
                  ),
                ),
                SizedBox(height: size.height * 0.005),
                Text(
                  creator,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: size.width * 0.034,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: size.width * 0.035,
                      color: Colors.grey,
                    ),
                    SizedBox(width: size.width * 0.02),
                    Expanded(
                      child: Text(
                        date,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: size.width * 0.033,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.015),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: size.width * 0.034,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventCard(
    BuildContext context, {
    required String title,
    required String creator,
    required String date,
    required String description,
    required String coverImage,
  }) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.green.shade100,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: coverImage.isNotEmpty
                ? Image.network(
                    coverImage,
                    height: size.height * 0.18,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: size.height * 0.18,
                    width: double.infinity,
                    color: Colors.green.shade50,
                    child: const Icon(Icons.image_not_supported),
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: size.width * 0.055,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF114B3A),
                  ),
                ),
                SizedBox(height: size.height * 0.005),
                Text(
                  creator,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: size.width * 0.034,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: size.width * 0.035,
                      color: Colors.grey,
                    ),
                    SizedBox(width: size.width * 0.02),
                    Expanded(
                      child: Text(
                        date,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: size.width * 0.033,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.015),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: size.width * 0.034,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
