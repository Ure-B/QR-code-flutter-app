import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'screens/login_screen.dart';
import 'screens/events_screen.dart';
import 'screens/scanner_screen.dart';

void main() {
  runApp(const EventPupApp());
}

class EventPupApp extends StatelessWidget {
  const EventPupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: MaterialApp(
        title: 'EventPup Scanner',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const RootDecider(),
        routes: {
          EventsScreen.routeName: (_) => const EventsScreen(),
          ScannerScreen.routeName: (_) => const ScannerScreen(),
        },
      ),
    );
  }
}

/// Root widget decides whether to show login or events
class RootDecider extends StatelessWidget {
  const RootDecider({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return FutureBuilder<bool>(
      future: auth.tryRestoreSession(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (auth.isAuthenticated) {
          return const EventsScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
