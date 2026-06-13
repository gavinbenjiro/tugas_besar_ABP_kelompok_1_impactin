import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/create_event_controller.dart';
import 'package:mobile_user/app/modules/create_event/views/map_picker_view.dart';

class CreateEventView extends GetView<CreateEventController> {
  const CreateEventView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF58C8BA),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.all(size.width * 0.04),
        child: SizedBox(
          height: 55,
          child: Obx(
                () => ElevatedButton(
              onPressed: controller.isLoading.value ? null : () {
                // Validate form first, then call controller
                if (controller.formKey.currentState!.validate()) {
                  controller.createEvent();
                } else {
                  Get.snackbar(
                    "Validation Failed",
                    "Please check all required fields.",
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF114B3A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "Create Event",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // HEADER
            Container(
              height: size.height * 0.28,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF114B3A),
                    Color(0xFF2A7765),
                  ],
                ),
              ),
            ),

            Positioned(
              top: -40,
              left: -20,
              child: Container(
                width: size.width * .9,
                height: size.height * .18,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.05),
                  borderRadius: BorderRadius.circular(120),
                ),
              ),
            ),

            Positioned(
              right: -50,
              top: 20,
              child: Container(
                width: size.width * .8,
                height: size.height * .15,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.04),
                  borderRadius: BorderRadius.circular(120),
                ),
              ),
            ),

            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: size.height * .12),
              child: Column(
                children: [
                  SizedBox(height: size.height * .05),
                  Text(
                    "Create Your\nImpactIn Event",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * .09,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Start an event. Spark a movement",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: size.width * .04,
                    ),
                  ),
                  SizedBox(height: size.height * .04),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: size.width * .04),
                    padding: EdgeInsets.all(size.width * .04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    // ==============================
                    // FORM WRAPPER ADDED HERE
                    // ==============================
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Set up your event details",
                            style: TextStyle(
                              fontSize: size.width * .07,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF114B3A),
                            ),
                          ),
                          SizedBox(height: size.height * .025),

                          // COVER IMAGE PICKER
                          const Text(
                            "Cover Image",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => GestureDetector(
                            onTap: () => controller.pickCoverImage(),
                            child: Container(
                              height: 180,
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 18),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: controller.coverImagePath.value.isEmpty
                                      ? Colors.grey.shade300
                                      : const Color(0xFF114B3A),
                                  width: 2,
                                ),
                              ),
                              child: controller.coverImagePath.value.isEmpty
                                  ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      size: 40, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text("Tap to upload cover image",
                                      style: TextStyle(color: Colors.grey.shade600)),
                                ],
                              )
                                  : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(controller.coverImagePath.value),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )),

                          _buildField(
                            "Event Title",
                            controller.titleController,
                            "Create event title",
                          ),
                          _buildCategoryDropdown(controller),
                          _buildField(
                            "Location",
                            controller.locationController,
                            "Enter location (City, Country)",
                          ),
                          _buildField(
                            "Specific Address",
                            controller.specificAddressController,
                            "Enter specific address",
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Obx(
                                  () => ElevatedButton(
                                onPressed: () async {
                                  final result = await Get.to<LatLng>(
                                        () => const MapPickerView(),
                                  );

                                  if (result != null) {
                                    controller.latitude.value = result.latitude;
                                    controller.longitude.value = result.longitude;
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: controller.latitude.value == null
                                      ? Colors.grey.shade200
                                      : const Color(0xFF114B3A).withOpacity(0.1),
                                  foregroundColor: controller.latitude.value == null
                                      ? Colors.black87
                                      : const Color(0xFF114B3A),
                                  elevation: 0,
                                ),
                                child: Text(
                                  controller.latitude.value == null
                                      ? "Select Location on Map"
                                      : "Location Selected ✓",
                                ),
                              ),
                            ),
                          ),
                          _buildField(
                            "Address Link",
                            controller.addressLinkController,
                            "Enter address URL",
                          ),
                          _buildDateRow(context, controller),
                          _buildTimeRow(context, controller),
                          _buildField(
                            "Maximum Participant",
                            controller.maxParticipantController,
                            "Set participant limit",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                          _buildMultiLine(
                            "Description",
                            controller.descriptionController,
                            "Describe your event",
                          ),
                          _buildMultiLine(
                            "Terms & Conditions",
                            controller.termsController,
                            "Add participation requirements",
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildField(
                                  "Minimum Age",
                                  controller.minAgeController,
                                  "0",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  "Maximum Age",
                                  controller.maxAgeController,
                                  "0",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  // Custom Validator: Max Age >= Min Age
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) return 'Required';

                                    int minAge = int.tryParse(controller.minAgeController.text) ?? 0;
                                    int maxAge = int.tryParse(value) ?? 0;

                                    if (maxAge < minAge) {
                                      return 'Cannot be < Min Age';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          _buildField(
                            "Group Link",
                            controller.groupLinkController,
                            "Enter your chat group URL",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Refactored to TextFormField with validation
  Widget _buildField(
      String title,
      TextEditingController controller,
      String hint, {
        TextInputType? keyboardType,
        List<TextInputFormatter>? inputFormatters,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator ?? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$title is required';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiLine(
      String title,
      TextEditingController controller,
      String hint,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: 5,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '$title is required';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(BuildContext context, CreateEventController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: controller.startDateController,
              readOnly: true,
              onTap: () => controller.pickDate(
                context: context,
                controller: controller.startDateController,
              ),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              decoration: InputDecoration(
                labelText: "Start Date",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller.endDateController,
              readOnly: true,
              onTap: () => controller.pickDate(
                context: context,
                controller: controller.endDateController,
              ),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              decoration: InputDecoration(
                labelText: "End Date",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(CreateEventController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Event Category",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
                () => DropdownButtonFormField<String>(
              value: controller.selectedCategory.value.isEmpty
                  ? null
                  : controller.selectedCategory.value,
              validator: (value) => value == null || value.isEmpty ? 'Category is required' : null,
              decoration: InputDecoration(
                hintText: "Select a category",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: controller.categories
                  .map(
                    (category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ),
              )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedCategory.value = value;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(BuildContext context, CreateEventController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: controller.startTimeController,
              readOnly: true,
              onTap: () => controller.pickTime(
                context: context,
                controller: controller.startTimeController,
              ),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              decoration: InputDecoration(
                labelText: "Start Time",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller.endTimeController,
              readOnly: true,
              onTap: () => controller.pickTime(
                context: context,
                controller: controller.endTimeController,
              ),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              decoration: InputDecoration(
                labelText: "End Time",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}