import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/create_event_controller.dart';
import 'package:mobile_user/app/modules/create_event/views/map_picker_view.dart';
import 'package:latlong2/latlong.dart';

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
              onPressed:
                  controller.isLoading.value ? null : controller.createEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF114B3A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
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
              padding: EdgeInsets.only(
                bottom: size.height * .12,
              ),
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
                    margin: EdgeInsets.symmetric(
                      horizontal: size.width * .04,
                    ),
                    padding: EdgeInsets.all(
                      size.width * .04,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
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
                        SizedBox(
                          height: size.height * .025,
                        ),
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
                        Obx(
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
                            child: Text(
                              controller.latitude.value == null
                                  ? "Select Location"
                                  : "Location Selected ✓",
                            ),
                          ),
                        ),
                        _buildField(
                          "Address Link",
                          controller.addressLinkController,
                          "Enter address URL",
                        ),
                        _buildDateRow(
                          context,
                          controller,
                        ),
                        _buildTimeRow(
                          context,
                          controller,
                        ),
                        _buildField(
                          "Maximum Participant",
                          controller.maxParticipantController,
                          "Set participant limit",
                          keyboard: TextInputType.number,
                        ),
                        _buildField(
                          "Cover Image URL",
                          controller.coverImageController,
                          "https://...",
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
                          children: [
                            Expanded(
                              child: _buildField(
                                "Minimum Age",
                                controller.minAgeController,
                                "0",
                                keyboard: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                "Maximum Age",
                                controller.maxAgeController,
                                "0",
                                keyboard: TextInputType.number,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String title,
    TextEditingController controller,
    String hint, {
    TextInputType? keyboard,
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
          TextField(
            controller: controller,
            keyboardType: keyboard,
            decoration: InputDecoration(
              hintText: hint,
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
          TextField(
            controller: controller,
            maxLines: 5,
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

  Widget _buildDateRow(
    BuildContext context,
    CreateEventController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.startDateController,
            readOnly: true,
            onTap: () => controller.pickDate(
              context: context,
              controller: controller.startDateController,
            ),
            decoration: const InputDecoration(
              labelText: "Start Date",
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: controller.endDateController,
            readOnly: true,
            onTap: () => controller.pickDate(
              context: context,
              controller: controller.endDateController,
            ),
            decoration: const InputDecoration(
              labelText: "End Date",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(
    CreateEventController controller,
  ) {
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
              decoration: const InputDecoration(
                hintText: "Select a category",
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

  Widget _buildTimeRow(
    BuildContext context,
    CreateEventController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.startTimeController,
              readOnly: true,
              onTap: () => controller.pickTime(
                context: context,
                controller: controller.startTimeController,
              ),
              decoration: const InputDecoration(
                labelText: "Start Time",
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller.endTimeController,
              readOnly: true,
              onTap: () => controller.pickTime(
                context: context,
                controller: controller.endTimeController,
              ),
              decoration: const InputDecoration(
                labelText: "End Time",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
