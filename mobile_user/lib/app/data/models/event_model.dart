class EventModel {
  final String id;
  final String title;

  final String location;
  final String specificAddress;
  final String addressLink;

  final String startDate;
  final String endDate;

  final String startTime;
  final String endTime;

  final String coverImage;

  final String description;
  final String terms;

  final int minAge;
  final int maxAge;

  final String? groupLink;

  final String hostName;

  final bool isHost;
  final bool isApplicant;
  final bool isParticipant;

  final String status;
  final String subStatus;

  EventModel({
    required this.id,
    required this.title,
    required this.location,
    required this.specificAddress,
    required this.addressLink,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.coverImage,
    required this.description,
    required this.terms,
    required this.minAge,
    required this.maxAge,
    this.groupLink,
    required this.hostName,
    required this.isHost,
    required this.isApplicant,
    required this.isParticipant,
    required this.status,
    required this.subStatus,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['event_id'].toString(),
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      specificAddress: json['specific_address'] ?? '',
      addressLink: json['address_link'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      coverImage: json['cover_image'] ?? '',
      description: json['description'] ?? '',
      terms: json['terms'] ?? '',
      minAge: json['min_age'] ?? 0,
      maxAge: json['max_age'] ?? 0,
      groupLink: json['group_link'],
      hostName: json['host_name'] ?? '',
      isHost: json['is_host'] ?? false,
      isApplicant: json['is_applicant'] ?? false,
      isParticipant: json['is_participant'] ?? false,
      status: json['status'] ?? '',
      subStatus: json['sub_status'] ?? '',
    );
  }
}
