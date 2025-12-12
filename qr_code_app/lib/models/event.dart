class EventModel {
  final int id;
  final String title;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final String timezone;
  final String address;
  final bool qrCode;
  final bool qrUnlimitedCharges;
  final String status;
  final int attendeeCount;
  final int checkedInCount;

  EventModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.timezone,
    required this.address,
    required this.qrCode,
    required this.qrUnlimitedCharges,
    required this.status,
    required this.attendeeCount,
    required this.checkedInCount,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    int safeInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    bool safeBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }

    return EventModel(
      id: safeInt(json['id']),
      title: json['title'] ?? '',
      startDate: json['start_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endDate: json['end_date'] ?? '',
      endTime: json['end_time'] ?? '',
      timezone: json['timezone'] ?? '',
      address: json['address'] ?? '',
      qrCode: safeBool(json['qr_code']),
      qrUnlimitedCharges: safeBool(json['qr_unlimited_charges']),
      status: json['status'] ?? '',
      attendeeCount: safeInt(json['attendee_count']),
      checkedInCount: safeInt(json['checked_in_count']),
    );
  }
}
