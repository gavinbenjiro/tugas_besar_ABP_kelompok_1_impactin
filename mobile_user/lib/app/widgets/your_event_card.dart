// =========================================================
// YOUR EVENT CARD
// =========================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/your_event_model.dart';
import '../routes/app_pages.dart';

class YourEventCard extends StatelessWidget {
  final YourEventModel event;
  final bool showManageButton;

  const YourEventCard({
    super.key,
    required this.event,
    this.showManageButton = false,
  });

  String getStatus() {
    if (event.subStatus.isNotEmpty) {
      return event.subStatus;
    }

    return event.status;
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
      case 'opened':
        return const Color(0xFF00A86B);

      case 'upcoming':
        return const Color(0xFF46A7C9);

      case 'completed':
        return Colors.grey;

      case 'pending':
        return const Color(0xFFE0B000);

      case 'cancelled':
        return Colors.red;

      case 'declined':
      case 'closed':
        return const Color(0xFF9B0000);

      default:
        return Colors.grey;
    }
  }

  String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);

      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final status = getStatus();

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          Routes.EVENT_DETAIL,
          arguments: event.eventId,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: size.width * 0.03,
          vertical: size.height * 0.008,
        ),
        padding: EdgeInsets.all(size.width * 0.035),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 3),
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: size.width * 0.045,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.008,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: size.width * 0.04,
                          ),
                          SizedBox(
                            width: size.width * 0.01,
                          ),
                          Expanded(
                            child: Text(
                              event.location.split(',').first,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: size.width * 0.035,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.008,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.grey,
                            size: size.width * 0.04,
                          ),
                          SizedBox(
                            width: size.width * 0.01,
                          ),
                          Text(
                            formatDate(
                              event.startDate,
                            ),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.008,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: Colors.grey,
                            size: size.width * 0.04,
                          ),
                          SizedBox(
                            width: size.width * 0.01,
                          ),
                          Expanded(
                            child: Text(
                              event.hostName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: size.width * 0.035,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.03,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.006,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(status),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: size.width * 0.034,
                    ),
                  ),
                ),
              ],
            ),
            if (showManageButton) ...[
              SizedBox(
                height: size.height * 0.015,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.toNamed(
                        Routes.MANAGE_EVENT,
                        arguments: event.eventId,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF114B3A),
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Manage Event",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
