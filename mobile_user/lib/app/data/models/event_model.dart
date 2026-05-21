class EventModel {
  final String id;
  final String title;
  final String category;
  final String location;
  final String specificAddress;
  final String addressLink;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final int maxParticipant;
  final String coverImage;
  final String description;
  final String terms;
  final int minAge;
  final int maxAge;
  final String groupLink;
  final String host;
  final String joinStatus;
  final String creatStatus;

  EventModel({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.specificAddress,
    required this.addressLink,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.maxParticipant,
    required this.coverImage,
    required this.description,
    required this.terms,
    required this.minAge,
    required this.maxAge,
    required this.groupLink,
    required this.host,
    this.joinStatus = "",
    this.creatStatus = "",
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'].toString(),
      title: json['title'],
      category: json['category'],
      location: json['location'],
      specificAddress: json['specific_address'],
      addressLink: json['address_link'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      maxParticipant: json['max_participant'],
      coverImage: json['cover_image'],
      description: json['description'],
      terms: json['terms'],
      minAge: json['min_age'],
      maxAge: json['max_age'],
      groupLink: json['group_link'],
      host: json['host'],
      joinStatus: json['join_status'] ?? "",
      creatStatus: json['creat_status'] ?? "",
    );
  }
}
