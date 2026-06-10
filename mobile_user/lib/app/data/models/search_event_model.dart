class SearchEventModel {
  final int eventId;
  final String title;
  final String category;
  final String coverImage;
  final String startDate;
  final String location;
  final String hostName;

  SearchEventModel({
    required this.eventId,
    required this.title,
    required this.category,
    required this.coverImage,
    required this.startDate,
    required this.location,
    required this.hostName,
  });

  factory SearchEventModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SearchEventModel(
      eventId: json['event_id'],
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      coverImage: json['cover_image'] ?? '',
      startDate: json['start_date'] ?? '',
      location: json['location'] ?? '',
      hostName: json['host_name'] ?? '',
    );
  }
}
