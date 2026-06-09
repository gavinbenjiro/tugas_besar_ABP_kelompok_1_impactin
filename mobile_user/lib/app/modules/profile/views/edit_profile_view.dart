import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller jika belum ada di routes
    Get.put(EditProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A5336), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- FOTO PROFIL ---
            Center(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Obx(() => CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    // Jika imageUrl dari API berisi data, tampilkan NetworkImage
                    backgroundImage: controller.imageUrl.value.isNotEmpty &&
                        controller.imageUrl.value.startsWith('http')
                        ? NetworkImage(controller.imageUrl.value)
                        : const AssetImage('assets/images/pp_dum1.jpg') as ImageProvider,
                  )),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A5336),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- FORM FIELDS ---
            _buildLabel('Full Name'),
            _buildTextField(controller: controller.nameController),

            _buildLabel('Date of Birth'),
            _buildTextField(
              controller: controller.dobController,
              suffixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20),
              readOnly: true,
              onTap: () => controller.selectDate(context),
            ),

            _buildLabel('Status'),
            _buildTextField(controller: controller.statusController),

            _buildLabel('Location'),
            _buildTextField(controller: controller.locationController),

            _buildLabel('Bio'),
            _buildTextField(
              controller: controller.bioController,
              maxLines: 4,
            ),

            // --- SKILLS SECTION ---
            _buildLabel('Skills'),
            Obx(() => Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: controller.skills.map((skill) {
                    return InputChip(
                      label: Text(skill, style: const TextStyle(color: Color(0xFF1A5336), fontSize: 12)),
                      backgroundColor: const Color(0xFFF0F5F2),
                      deleteIcon: const Icon(Icons.close, size: 16, color: Color(0xFF1A5336)),
                      onDeleted: () => controller.removeSkill(skill),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.transparent),
                      ),
                    );
                  }).toList(),
                )),
            const SizedBox(height: 12),
            
            // Input tambah skill
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.skillController,
                      decoration: const InputDecoration(
                        hintText: 'Add your skill here',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: controller.addSkill,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF265A4B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Add', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- SAVE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () => controller.saveProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5336),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  )),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    int maxLines = 1,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A5336)),
        ),
      ),
    );
  }
}