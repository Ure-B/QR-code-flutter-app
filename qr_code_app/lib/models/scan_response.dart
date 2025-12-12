class ChargeStatus {
  final int? total;
  final int used;
  final int? remaining;
  final bool unlimited;

  ChargeStatus({
    required this.total,
    required this.used,
    required this.remaining,
    required this.unlimited,
  });

  factory ChargeStatus.fromJson(Map<String, dynamic> json) {
    return ChargeStatus(
      total: json['total'] as int?,
      used: json['used'] as int? ?? 0,
      remaining: json['remaining'] as int?,
      unlimited: json['unlimited'] as bool? ?? false,
    );
  }
}

class Attendee {
  final int id;
  final String name;

  Attendee({required this.id, required this.name});

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(id: json['id'] as int, name: json['name'] as String? ?? '');
  }
}

class ScanResponse {
  final Attendee attendee;
  final ChargeStatus chargeStatus;
  final String action; // check_in | charge_count_needed
  final int? chargeCountNeeded;
  final String tokenType;

  ScanResponse({
    required this.attendee,
    required this.chargeStatus,
    required this.action,
    required this.chargeCountNeeded,
    required this.tokenType,
  });

  factory ScanResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ScanResponse(
      attendee: Attendee.fromJson(data['attendee'] as Map<String, dynamic>),
      chargeStatus: ChargeStatus.fromJson(
        data['charge_status'] as Map<String, dynamic>,
      ),
      action: data['action'] as String? ?? 'check_in',
      chargeCountNeeded: data['charge_count_needed'] as int?,
      tokenType: data['token_type'] as String? ?? 'main',
    );
  }
}
