import 'package:flutter/material.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(event.title),
        subtitle: Text(
          '${event.startDate} ${event.startTime} • ${event.address}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${event.attendeeCount} attendees'),
            Text('${event.checkedInCount} checked-in'),
          ],
        ),
      ),
    );
  }
}
