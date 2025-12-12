import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/event.dart';
import '../models/scan_response.dart';

class ApiService {
  // Update baseUrl for production
  static const String baseUrl = 'https://beta.eventpup.com/api';

  final String? token;
  ApiService({this.token});

  Map<String, String> get _defaultHeaders {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<String> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/login');
    final resp = await http.post(
      uri,
      headers: _defaultHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200 &&
        (body['success'] == true || body['token'] != null)) {
      // Accept both shapes
      final token =
          body['token'] as String? ?? body['data']?['token'] as String?;
      if (token == null) throw Exception('Token missing');
      return token;
    } else {
      final message = body['message'] ?? body['error'] ?? 'Login failed';
      throw ApiException(message.toString(), resp.statusCode, body);
    }
  }

  Future<void> logout() async {
    final uri = Uri.parse('$baseUrl/logout');
    final resp = await http.post(uri, headers: _defaultHeaders);
    if (resp.statusCode != 200) {
      // Still proceed to clear token on client
      final body = jsonDecode(resp.body);
      throw ApiException(
        body['error'] ?? 'Logout failed',
        resp.statusCode,
        body,
      );
    }
  }

  Future<User> getCurrentUser() async {
    final uri = Uri.parse('$baseUrl/user');
    final resp = await http.get(uri, headers: _defaultHeaders);
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200) {
      return User.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw ApiException(
      body['error'] ?? 'Failed to fetch user',
      resp.statusCode,
      body,
    );
  }

  Future<List<EventModel>> listEvents() async {
    final uri = Uri.parse('$baseUrl/events');
    final resp = await http.get(uri, headers: _defaultHeaders);
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200 && body['success'] == true) {
      final data = body['data'] as List;
      return data
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(
      body['error'] ?? 'Failed to fetch events',
      resp.statusCode,
      body,
    );
  }

  Future<ScanResponse> scanQr(int eventId, String token) async {
    final uri = Uri.parse('$baseUrl/events/$eventId/scan');
    final resp = await http.post(
      uri,
      headers: _defaultHeaders,
      body: jsonEncode({'token': token}),
    );
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200 && body['success'] == true) {
      return ScanResponse.fromJson(body as Map<String, dynamic>);
    }
    throw ApiException(body['error'] ?? 'Scan failed', resp.statusCode, body);
  }

  Future<Map<String, dynamic>> checkin(
    int eventId,
    int attendeeId,
    String token, {
    int? chargeCount,
  }) async {
    final uri = Uri.parse('$baseUrl/events/$eventId/checkin');
    final bodyPayload = {'attendee_id': attendeeId, 'token': token};
    if (chargeCount != null) bodyPayload['charge_count'] = chargeCount;
    final resp = await http.post(
      uri,
      headers: _defaultHeaders,
      body: jsonEncode(bodyPayload),
    );
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200 && body['success'] == true) {
      return body['data'] as Map<String, dynamic>;
    }
    throw ApiException(
      body['error'] ?? 'Check-in failed',
      resp.statusCode,
      body,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic body;
  ApiException(this.message, this.statusCode, this.body);

  @override
  String toString() {
    return 'ApiException($statusCode): $message';
  }
}
