class NearbyEventModel {
  final int eventId;
  final String title;
  final String category;
  final String coverImage;
  final String startDate;
  final String location;
  final double distanceKm;

  NearbyEventModel({
    required this.eventId,
    required this.title,
    required this.category,
    required this.coverImage,
    required this.startDate,
    required this.location,
    required this.distanceKm,
  });

  factory NearbyEventModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return NearbyEventModel(
      eventId: json["event_id"],
      title: json["title"] ?? "",
      category: json["category"] ?? "",
      coverImage: json["cover_image"] ?? "",
      startDate: json["start_date"] ?? "",
      location: json["location"] ?? "",
      distanceKm: (json["distance_km"] as num?)?.toDouble() ?? 0,
    );
  }
}
