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
        theme: ThemeData(
          primaryColor: const Color(0xFFFA7315),
          scaffoldBackgroundColor: const Color(0xFF1A1A1A),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF000000),
            foregroundColor: Colors.white,
            elevation: 1,
          ),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFFFA7315),
            secondary: const Color(0xFFFA7315),
            error: const Color(0xFFDC3545),
            brightness: Brightness.light,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFA7315),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFCD34D),
            ),
            bodyMedium: TextStyle(fontSize: 16, color: Colors.white),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
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
