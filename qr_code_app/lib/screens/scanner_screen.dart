import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../services/api_service.dart';
import '../utils/qr_parser.dart';
import '../models/scan_response.dart';
import '../widgets/charge_count_dialog.dart';
import '../utils/error_mapper.dart';

class ScannerScreen extends StatefulWidget {
  static const routeName = '/scanner';
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _processing = false;
  final MobileScannerController cameraController = MobileScannerController();
  String? _lastScanned;
  DateTime? _lastScanTime;

  Future<void> handleRawQr(String raw) async {
    if (_processing) return;

    if (_lastScanTime != null &&
        DateTime.now().difference(_lastScanTime!) <
            const Duration(seconds: 1)) {
      return; // cooldown
    }

    if (raw == _lastScanned) return;

    _lastScanned = raw;
    _lastScanTime = DateTime.now();
    _processing = true;
    HapticFeedback.vibrate();

    final parsed = parseQrUrl(raw);
    final eventProv = Provider.of<EventProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final selectedEvent = eventProv.selectedEvent;

    String? resultMessage;
    bool isSuccess = false;

    if (parsed == null) {
      resultMessage = 'Unable to parse QR code';
    } else if (selectedEvent == null) {
      resultMessage = 'No event selected';
    } else if (parsed.eventId != selectedEvent.id) {
      resultMessage = 'QR code is for a different event';
    } else {
      try {
        final api = ApiService(token: auth.token);
        final ScanResponse scanResp = await api.scanQr(
          parsed.eventId,
          parsed.token,
        );

        if (scanResp.action == 'charge_count_needed') {
          final chosen = await showDialog<int>(
            context: context,
            builder: (_) => ChargeCountDialog(
              maxCount:
                  scanResp.chargeCountNeeded ??
                  (scanResp.chargeStatus.remaining ?? 1),
              attendeeName: scanResp.attendee.name,
            ),
          );
          if (chosen == null) {
            _processing = false;
            return;
          }
          await api.checkin(
            parsed.eventId,
            scanResp.attendee.id,
            parsed.token,
            chargeCount: chosen,
          );
          resultMessage =
              '${scanResp.attendee.name} — checked in ($chosen used).';
          isSuccess = true;
        } else {
          final checkinData = await api.checkin(
            parsed.eventId,
            scanResp.attendee.id,
            parsed.token,
          );
          final remaining = checkinData['remaining_charges'];
          resultMessage = '${scanResp.attendee.name} checked in';
          if (remaining != null) resultMessage += ' — $remaining remaining';
          isSuccess = true;
        }
      } on ApiException catch (e) {
        resultMessage = mapApiErrorCodeToMessage(
          e.body?['code'] as String?,
          e.message,
        );
      } catch (e) {
        resultMessage = 'Scan failed: $e';
      }
    }

    _processing = false;

    if (mounted) {
      Navigator.of(
        context,
      ).pop({'success': isSuccess, 'message': resultMessage});
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventProv = Provider.of<EventProvider>(context);
    final selected = eventProv.selectedEvent;

    return Scaffold(
      backgroundColor: const Color(0xFF1E2124),
      appBar: AppBar(
        title: Text(
          selected?.title ?? 'Scanner',
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF252A2E),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;
              final raw = barcodes.first.rawValue ?? '';
              if (raw.isEmpty) return;
              handleRawQr(raw);
            },
          ),
          // Overlay box for QR alignment
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFA7315), width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      // Floating buttons bottom right
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'torch',
            onPressed: () => cameraController.toggleTorch(),
            backgroundColor: const Color(0xFFFA7315),
            child: const Icon(Icons.flash_on),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'switchCam',
            onPressed: () => cameraController.switchCamera(),
            backgroundColor: const Color(0xFFFA7315),
            child: const Icon(Icons.cameraswitch),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
