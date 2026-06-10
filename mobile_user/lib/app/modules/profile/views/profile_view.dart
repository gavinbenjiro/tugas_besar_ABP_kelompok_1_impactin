import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/storage/storage_keys.dart';
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
        // Obx mendengarkan perubahan status loading & data di controller
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF114B3A),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchProfileData,
            color: const Color(0xFF114B3A),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
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
                            SizedBox(height: size.height * 0.02),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // =====================================
                                // PROFILE IMAGE
                                // =====================================
                                CircleAvatar(
                                  radius: size.width * 0.11,
                                  backgroundColor: Colors.grey.shade300,
                                  backgroundImage: controller
                                          .imageUrl.value.isNotEmpty
                                      ? NetworkImage(controller.imageUrl.value)
                                      : const AssetImage(
                                              "assets/images/pp_dum1.jpg")
                                          as ImageProvider,
                                ),
                                SizedBox(width: size.width * 0.04),

                                // =====================================
                                // INFO
                                // =====================================
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: size.height * 0.01),
                                      Text(
                                        controller.name.value.isEmpty
                                            ? "No Name"
                                            : controller.name.value,
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
                                        controller.status.value.isEmpty
                                            ? "Status belum diisi"
                                            : controller.status.value,
                                      ),
                                      SizedBox(height: size.height * 0.006),
                                      _infoRow(
                                        context,
                                        Icons.cake_outlined,
                                        "${controller.age.value} Tahun",
                                      ),
                                      SizedBox(height: size.height * 0.006),
                                      _infoRow(
                                        context,
                                        Icons.location_on_outlined,
                                        controller.city.value.isEmpty
                                            ? "Lokasi belum diatur"
                                            : controller.city.value,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: size.height * 0.025),

                            // =========================================
                            // EDIT PROFILE BUTTON
                            // =========================================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Tombol Change Password
                                GestureDetector(
                                  onTap: () => _showChangePasswordDialog(context),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.012),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8), // Warna merah untuk aksi sensitif
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text("Change Password", style: TextStyle(color: Colors.white, fontSize: size.width * 0.032)),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.03),
                                // Tombol Edit Profile (yang sudah ada)
                                GestureDetector(
                                  onTap: () async {
                                    await Get.toNamed(Routes.EDIT_PROFILE);
                                    controller.fetchProfileData();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.012),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      children: [
                                        Text("Edit profile", style: TextStyle(color: Colors.white, fontSize: size.width * 0.036)),
                                        SizedBox(width: size.width * 0.03),
                                        Icon(Icons.edit_outlined, color: Colors.white, size: size.width * 0.05),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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

                  // =================================================
                  // DESCRIPTION
                  // =================================================
                  _sectionCard(
                    context,
                    title: "Description",
                    child: Text(
                      controller.bio.value.isEmpty
                          ? "Belum ada bio."
                          : controller.bio.value,
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
                    child: controller.skills.isEmpty
                        ? Text(
                            "Belum ada skill yang ditambahkan",
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: size.width * 0.034),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.skills.map((skillItem) {
                              // Extract skill text based on your JSON format
                              String skillText = "";
                              if (skillItem is Map &&
                                  skillItem['skills'] != null) {
                                skillText = skillItem['skills'].toString();
                              } else if (skillItem is String) {
                                skillText = skillItem;
                              }

                              return _skillChip(
                                skillText,
                                Colors.green.shade50,
                                Colors.green.shade800,
                              );
                            }).toList(),
                          ),
                  ),

                  // =================================================
                  // EXPERIENCE
                  // =================================================
                  _sectionCard(
                    context,
                    title: "General Experience",
                    trailing: GestureDetector(
                      onTap: () => _showExperienceDialog(
                          context), // ACTION BUKA POPUP ADD
                      child: Container(
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
                    ),
                    child: controller.experiences.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Belum ada pengalaman yang ditambahkan",
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: size.width * 0.034),
                            ),
                          )
                        : Column(
                            children: controller.experiences.map((exp) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _experienceCard(context, exp),
                              );
                            }).toList(),
                          ),
                  ),

                  // =================================================
                  // LOGOUT BUTTON
                  // =================================================
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.025),
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
          );
        }),
      ),
      bottomNavigationBar: const CustomBottomNavbar(
        currentIndex: 3,
      ),
    );
  }

  // =========================================================
  // INFO ROW
  // =========================================================
  Widget _infoRow(BuildContext context, IconData icon, String text) {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: size.width * 0.04),
        SizedBox(width: size.width * 0.02),
        Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: size.width * 0.036),
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
        border: Border.all(color: Colors.green.shade100),
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
              Icon(Icons.auto_awesome,
                  color: const Color(0xFF114B3A), size: size.width * 0.05),
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
  Widget _skillChip(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: TextStyle(
            color: textColor, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  // =========================================================
  // EXPERIENCE CARD (DYNAMIC)
  // =========================================================
  Widget _experienceCard(BuildContext context, dynamic exp) {
    final size = MediaQuery.of(context).size;

    // Parse fields safely from API JSON
    int expId = exp['experience_id'] ?? 0;
    String title = exp['title']?.toString() ?? "No Title";
    String creator = exp['creator']?.toString() ?? "Unknown";
    String description = exp['description']?.toString() ?? "";
    String dateStr = exp['date']?.toString() ?? "";
    String coverUrl = exp['cover_image']?.toString() ?? "";

    // Simple date parse to look cleaner
    if (dateStr.length >= 10) {
      dateStr = dateStr.substring(0, 10);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.shade100),
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
            child: coverUrl.isNotEmpty
                ? Image.network(
                    coverUrl,
                    height: size.height * 0.18,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _fallbackExperienceImage(size),
                  )
                : _fallbackExperienceImage(size),
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
                      color: Colors.green, fontSize: size.width * 0.034),
                ),
                SizedBox(height: size.height * 0.01),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: size.width * 0.035, color: Colors.grey),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      dateStr,
                      style: TextStyle(
                          color: Colors.grey, fontSize: size.width * 0.033),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.015),
                Text(
                  description,
                  style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: size.width * 0.034,
                      height: 1.5),
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade200),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.016),
                        ),
                        onPressed: () {
                          controller.showDeleteExperienceDialog(
                            exp['experience_id'],
                          );
                        },
                        child: const Text("Delete",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.green.shade200),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.016),
                        ),
                        onPressed: () {
                          // ACTION BUKA POPUP EDIT
                          _showExperienceDialog(context, experience: exp);
                        },
                        child: const Text("Edit",
                            style: TextStyle(color: Colors.green)),
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

  Widget _fallbackExperienceImage(Size size) {
    return Image.asset(
      "assets/images/ev_dum1.jpg",
      height: size.height * 0.18,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
  void _showChangePasswordDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Change Password",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF114B3A))),
                const SizedBox(height: 24),
                _buildDialogTextField(hint: "Current Password", textController: controller.oldPassController),
                _buildDialogTextField(hint: "New Password", textController: controller.newPassController),
                _buildDialogTextField(hint: "Confirm New Password", textController: controller.confirmPassController),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF114B3A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => controller.updatePassword(),
                    child: const Text("Save Password", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // =========================================================
  // SHOW EXPERIENCE DIALOG (POP-UP ADD / EDIT)
  // =========================================================
  void _showExperienceDialog(BuildContext context,
      {Map<String, dynamic>? experience}) {
    final isEdit = experience != null;

    // Inisialisasi formulir dengan data / kosongkan jika mode Add
    controller.openExperienceForm(exp: experience);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Dialog
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? "Edit Experience" : "Add Experience",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF114B3A),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Icon(Icons.close,
                            size: 16, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form Fields
                _buildDialogTextField(
                  hint: isEdit
                      ? "Experience Name"
                      : "Add your experience name...",
                  textController: controller.expTitleController,
                ),
                _buildDialogTextField(
                  hint:
                      isEdit ? "Host Name" : "Add your event category/host...",
                  textController: controller.expHostController,
                ),
                _buildDialogTextField(
                  hint: isEdit ? "Date" : "Select the date",
                  textController: controller.expDateController,
                  readOnly: true, // Tidak bisa diketik manual
                  onTap: () => controller.selectExpDate(context),
                  suffixIcon:
                      Icon(Icons.calendar_month, color: Colors.grey.shade400),
                ),

                // Add Image Button (Placeholder)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_file,
                            size: 18, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text("add image",
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 14)),
                      ],
                    ),
                  ),
                ),

                // Description Field
                _buildDialogTextField(
                  hint: isEdit
                      ? "Description"
                      : "Add your event description here",
                  textController: controller.expDescController,
                  maxLines: 4,
                ),

                const SizedBox(height: 8),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF114B3A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      int? expId = isEdit ? experience['experience_id'] : null;
                      controller.saveExperience(id: expId);
                    },
                    child: Text(
                      isEdit ? "Save Changes" : "Save",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Custom TextField untuk Dialog UI
  Widget _buildDialogTextField({
    required String hint,
    required TextEditingController textController,
    int maxLines = 1,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: textController,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          suffixIcon: suffixIcon,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF114B3A), width: 1.5),
          ),
        ),
      ),
    );
  }
}
