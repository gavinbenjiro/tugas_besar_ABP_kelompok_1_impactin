// =========================================================
// PROFILE VIEW
// SLICING STYLE RESPONSIVE UI
// =========================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/custom_bottom_navbar.dart';
import '../controllers/profile_controller.dart';

import '../../../routes/app_pages.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
              // =================================================
              // HEADER
              // =================================================
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
                        SizedBox(
                          height: size.height * 0.02,
                        ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // =====================================
                            // PROFILE IMAGE
                            // =====================================
                            CircleAvatar(
                              radius: size.width * 0.11,
                              backgroundImage: const AssetImage(
                                "assets/images/pp_dum1.jpg",
                              ),
                            ),

                            SizedBox(
                              width: size.width * 0.04,
                            ),

                            // =====================================
                            // INFO
                            // =====================================
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: size.height * 0.01,
                                  ),
                                  Text(
                                    "Veiron Vaya Yarief",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.width * 0.06,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.012,
                                  ),
                                  _infoRow(
                                    context,
                                    Icons.work_outline,
                                    "Mahasiswa",
                                  ),
                                  SizedBox(
                                    height: size.height * 0.006,
                                  ),
                                  _infoRow(
                                    context,
                                    Icons.cake_outlined,
                                    "21 Tahun",
                                  ),
                                  SizedBox(
                                    height: size.height * 0.006,
                                  ),
                                  _infoRow(
                                    context,
                                    Icons.location_on_outlined,
                                    "Bandung, Jawa Barat",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: size.height * 0.025,
                        ),

                        // =========================================
                        // EDIT PROFILE BUTTON
                        // =========================================
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.05,
                              vertical: size.height * 0.012,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(
                                30,
                              ),
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
                                SizedBox(
                                  width: size.width * 0.03,
                                ),
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
                        color: Colors.white.withOpacity(
                          0.05,
                        ),
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
                        color: Colors.white.withOpacity(
                          0.04,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.018),

              // =================================================
              // DESCRIPTION
              // =================================================
              _sectionCard(
                context,
                title: "Description",
                child: Text(
                  "Aktif dalam kegiatan alam, volunteer dan peduli terhadap keberlanjutan ekosistem. Passionate about technology and environmental conservation.",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: size.width * 0.034,
                    height: 1.5,
                  ),
                ),
              ),

              // =================================================
              // SKILLS
              // =================================================
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
                      SizedBox(
                        width: size.width * 0.01,
                      ),
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
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _skillChip(
                      "Public Speaking",
                      Colors.pink.shade50,
                      Colors.pink,
                    ),
                    _skillChip(
                      "Environmental Conservation",
                      Colors.green.shade50,
                      Colors.green.shade800,
                    ),
                    _skillChip(
                      "Sustainability Practices",
                      Colors.indigo.shade50,
                      Colors.indigo,
                    ),
                    _skillChip(
                      "Event Planning",
                      Colors.red.shade50,
                      Colors.red,
                    ),
                    _skillChip(
                      "Community Leadership",
                      Colors.blue.shade50,
                      Colors.blue,
                    ),
                    _skillChip(
                      "Volunteer Management",
                      Colors.orange.shade50,
                      Colors.orange,
                    ),
                  ],
                ),
              ),

              // =================================================
              // EXPERIENCE
              // =================================================
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
                child: _experienceCard(context),
              ),

              // =================================================
// LOGOUT BUTTON
// =================================================
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

      // =====================================================
      // BOTTOM NAVBAR
      // =====================================================
      bottomNavigationBar: const CustomBottomNavbar(
        currentIndex: 3,
      ),
    );
  }

  // =========================================================
  // INFO ROW
  // =========================================================

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
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.036,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // SECTION CARD
  // =========================================================

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

  // =========================================================
  // SKILL CHIP
  // =========================================================

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

  // =========================================================
  // EXPERIENCE CARD
  // =========================================================

  Widget _experienceCard(BuildContext context) {
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
            child: Image.asset(
              "assets/images/ev_dum1.jpg",
              height: size.height * 0.18,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Environmental Volunteer",
                  style: TextStyle(
                    fontSize: size.width * 0.055,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF114B3A),
                  ),
                ),
                SizedBox(height: size.height * 0.005),
                Text(
                  "Green Earth Organization",
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
                    Text(
                      "28 January 2025",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: size.width * 0.033,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.015),
                Text(
                  "Leading environmental conservation initiatives and organizing community cleanup events across Bandung area.",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: size.width * 0.034,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.red.shade200,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              30,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.016,
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Delete",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.green.shade200,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              30,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.016,
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Edit",
                          style: TextStyle(
                            color: Colors.green,
                          ),
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
  }
}
