class ManageEventModel {
  final int eventId;
  final String title;
  final String location;
  final String startDate;
  final int currentParticipant;
  final int maxParticipant;
  final String status;
  final String subStatus;
  final bool canOpen;
  final bool canClose;
  final String coverImage;

  final List<EventUser> applicants;
  final List<EventUser> participants;

  ManageEventModel({
    required this.eventId,
    required this.title,
    required this.location,
    required this.startDate,
    required this.currentParticipant,
    required this.maxParticipant,
    required this.status,
    required this.subStatus,
    required this.canOpen,
    required this.canClose,
    required this.applicants,
    required this.participants,
    required this.coverImage,
  });

  factory ManageEventModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ManageEventModel(
      eventId: json['event_id'],
      title: json['title'],
      location: json['location'],
      startDate: json['start_date'],
      currentParticipant: json['current_participant'],
      maxParticipant: json['max_participant'],
      status: json['status'],
      subStatus: json['sub_status'],
      canOpen: json['can_open'],
      canClose: json['can_close'],
      coverImage: json['cover_image'],
      applicants: List<EventUser>.from(
        (json['applicants'] ?? []).map(
          (e) => EventUser.fromJson(e),
        ),
      ),
      participants: List<EventUser>.from(
        (json['participants'] ?? []).map(
          (e) => EventUser.fromJson(e),
        ),
      ),
    );
  }
}

class EventUser {
  final int userId;
  final String name;

  EventUser({
    required this.userId,
    required this.name,
  });

  factory EventUser.fromJson(
    Map<String, dynamic> json,
  ) {
    return EventUser(
      userId: json['user_id'],
      name: json['name'],
    );
  }
}
