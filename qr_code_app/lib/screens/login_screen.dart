import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'events_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(EventsScreen.routeName);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('EventPup - Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign in'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // For quick testing with test credentials in spec:
                _emailCtrl.text = 'ed@preterra.com';
                _passCtrl.text = 'passwd99';
              },
              child: const Text('Fill test credentials'),
            ),
          ],
        ),
      ),
    );
  }
}
