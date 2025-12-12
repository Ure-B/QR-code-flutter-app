import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../widgets/event_card.dart';
import 'scanner_screen.dart';

class EventsScreen extends StatefulWidget {
  static const routeName = '/events';
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool _init = true;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) {
      _init = false;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final events = Provider.of<EventProvider>(context, listen: false);
    try {
      await events.loadEvents(auth.token!);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load events: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsProv = Provider.of<EventProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : eventsProv.events.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(child: Text('No live events with QR enabled')),
                ],
              )
            : ListView.builder(
                itemCount: eventsProv.events.length,
                itemBuilder: (context, i) {
                  final ev = eventsProv.events[i];
                  return EventCard(
                    event: ev,
                    onTap: () async {
                      eventsProv.selectEvent(ev);
                      final result = await Navigator.of(
                        context,
                      ).pushNamed(ScannerScreen.routeName);

                      if (result != null && result is Map<String, dynamic>) {
                        final isSuccess = result['success'] as bool;
                        final message = result['message'] as String?;
                        if (message != null) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(isSuccess ? 'Success' : 'Error'),
                              content: Text(message),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}
