// Optional widget if you want a custom attendee dialog before check-in.
// In the current flow we show charge dialog then call checkin automatically.
// This is left as a helper for when you want to show attendee details.
import 'package:flutter/material.dart';
import '../models/scan_response.dart';

class AttendeeInfoDialog extends StatelessWidget {
  final ScanResponse resp;
  final VoidCallback onConfirm;

  const AttendeeInfoDialog({
    super.key,
    required this.resp,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(resp.attendee.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Charges: ${resp.chargeStatus.remaining ?? 'unlimited'} remaining',
          ),
          const SizedBox(height: 8),
          Text('Token type: ${resp.tokenType}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: onConfirm, child: const Text('Check in')),
      ],
    );
  }
}
