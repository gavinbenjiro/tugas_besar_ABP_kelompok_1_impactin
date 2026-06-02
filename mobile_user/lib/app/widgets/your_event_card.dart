// =========================================================
// YOUR EVENT CARD
// =========================================================

import 'package:flutter/material.dart';

import '../data/models/event_model.dart';

class YourEventCard extends StatelessWidget {
  final EventModel event;

  const YourEventCard({
    super.key,
    required this.event,
  });

  String getStatus() {
    if (event.joinStatus.isNotEmpty) {
      return event.joinStatus;
    }

    return event.creatStatus;
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final status = getStatus();

    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =================================================
          // LEFT CONTENT
          // =================================================
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
                SizedBox(height: size.height * 0.008),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.grey,
                      size: size.width * 0.04,
                    ),
                    SizedBox(width: size.width * 0.01),
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
                SizedBox(height: size.height * 0.008),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.grey,
                      size: size.width * 0.04,
                    ),
                    SizedBox(width: size.width * 0.01),
                    Text(
                      event.startDate,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: size.width * 0.035,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.008),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: Colors.grey,
                      size: size.width * 0.04,
                    ),
                    SizedBox(width: size.width * 0.01),
                    Expanded(
                      child: Text(
                        "SeaCare Indonesia",
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

          SizedBox(width: size.width * 0.03),

          // =================================================
          // STATUS BADGE
          // =================================================
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
    );
  }
}
