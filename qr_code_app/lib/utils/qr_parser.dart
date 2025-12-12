/// Parse the QR code URL to extract eventId and token.
/// Returns null if parsing fails.
class ParsedQr {
  final int eventId;
  final String token;
  ParsedQr({required this.eventId, required this.token});
}

ParsedQr? parseQrUrl(String url) {
  try {
    final uri = Uri.parse(url);
    // Expect path segments like: ["events","123","attendees","456","scan","abc123token"]
    final segs = uri.pathSegments;
    // robust: find 'events' then read next segment as event id; then find 'scan' then next as token
    final eventsIndex = segs.indexOf('events');
    if (eventsIndex == -1 || eventsIndex + 1 >= segs.length) return null;
    final eventIdStr = segs[eventsIndex + 1];
    final scanIndex = segs.indexOf('scan');
    if (scanIndex == -1 || scanIndex + 1 >= segs.length) return null;
    final token = segs[scanIndex + 1];
    final eventId = int.tryParse(eventIdStr);
    if (eventId == null) return null;
    return ParsedQr(eventId: eventId, token: token);
  } catch (_) {
    return null;
  }
}
