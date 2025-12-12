String mapApiErrorCodeToMessage(String? code, String? defaultMsg) {
  switch (code) {
    case 'UNAUTHENTICATED':
      return 'Session expired — please sign in again.';
    case 'UNAUTHORIZED':
      return 'You are not allowed to access this event.';
    case 'INVALID_TOKEN':
      return 'QR code not found or invalid.';
    case 'EVENT_INACTIVE':
      return 'QR codes are not active for this event.';
    case 'TOKEN_USED':
      return 'This QR code has already been used.';
    case 'CHARGE_EXHAUSTED':
      return 'No charges remaining for this attendee.';
    case 'VALIDATION_ERROR':
      return defaultMsg ?? 'There was a validation error.';
    default:
      return defaultMsg ?? 'An error occurred.';
  }
}
