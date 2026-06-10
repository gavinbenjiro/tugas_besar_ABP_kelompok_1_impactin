class YourEventModel {
  final int eventId;
  final String title;
  final String startDate;
  final String location;
  final String status;
  final String subStatus;
  final String hostName;

  YourEventModel({
    required this.eventId,
    required this.title,
    required this.startDate,
    required this.location,
    required this.status,
    required this.subStatus,
    required this.hostName,
  });

  factory YourEventModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return YourEventModel(
      eventId: json["event_id"] ?? 0,
      title: json["title"] ?? "",
      startDate: json["start_date"] ?? "",
      location: json["location"] ?? "",
      status: json["status"] ?? "",
      subStatus: json["sub_status"] ?? "",
      hostName: json["host_name"] ?? "",
    );
  }
}
