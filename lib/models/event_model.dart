class Event {
  final String title;
  final String dateTime;
  final String location;
  final String cost;
  final String targetGroup;

  Event({
    required this.title,
    required this.dateTime,
    required this.location,
    required this.cost,
    required this.targetGroup,
  });

  // Factory constructor to convert JSON into an Event
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'] ?? '',
      dateTime: json['date_time'] ?? '',
      location: json['location'] ?? '',
      cost: json['cost'] ?? '',
      targetGroup: json['target_group'] ?? '',
    );
  }
}
