import 'package:flutter/material.dart';

class ChargeCountDialog extends StatefulWidget {
  final int maxCount;
  final String attendeeName;

  const ChargeCountDialog({
    super.key,
    required this.maxCount,
    required this.attendeeName,
  });

  @override
  State<ChargeCountDialog> createState() => _ChargeCountDialogState();
}

class _ChargeCountDialogState extends State<ChargeCountDialog> {
  int _chosenCount = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF252A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFA7315),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              'Charge Count',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'How many charges for ${widget.attendeeName}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 12),
                // Visual representation of max charges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.maxCount, (index) {
                    final filled = index < _chosenCount;
                    return Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: filled
                            ? const Color(0xFFFA7315)
                            : Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                // Increment/Decrement buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _chosenCount > 1
                          ? () => setState(() => _chosenCount--)
                          : null,
                      icon: const Icon(Icons.remove, color: Colors.white),
                    ),
                    Text(
                      '$_chosenCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      onPressed: _chosenCount < widget.maxCount
                          ? () => setState(() => _chosenCount++)
                          : null,
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // OK button
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(_chosenCount),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFA7315),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
