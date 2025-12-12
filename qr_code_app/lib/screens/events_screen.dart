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
        title: const Text(
          'Select Event',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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

                      // Make sure result is not null and has expected structure
                      if (result != null && result is Map<String, dynamic>) {
                        final bool isSuccess = result['success'] as bool;
                        final String message =
                            result['message'] as String? ?? '';

                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: const Color(
                              0xFF252A2E,
                            ), // dark background like login page
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: EdgeInsets.zero,
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Colored header
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSuccess
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    isSuccess ? 'Success' : 'Error',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                // Message body
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                // OK button
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}
