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
  int _value = 1;

  @override
  void initState() {
    super.initState();
    _value = 1;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.attendeeName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('How many charges to use? (1 - ${widget.maxCount})'),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: _value > 1 ? () => setState(() => _value--) : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$_value', style: const TextStyle(fontSize: 18)),
              IconButton(
                onPressed: _value < widget.maxCount
                    ? () => setState(() => _value++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_value),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
