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

    // enforce cooldown (e.g., 1 second)
    if (_lastScanTime != null &&
        DateTime.now().difference(_lastScanTime!) <
            const Duration(seconds: 1)) {
      return;
    }

    // prevent double-scanning the same code
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
            return; // user cancelled
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
      appBar: AppBar(
        title: Text(selected?.title ?? 'Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          final barcodes = capture.barcodes;
          if (barcodes.isEmpty) return;
          final raw = barcodes.first.rawValue ?? '';
          if (raw.isEmpty) return;
          handleRawQr(raw);
        },
      ),
    );
  }
}
