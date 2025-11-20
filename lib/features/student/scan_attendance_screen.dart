// lib/features/student/scan_attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/session_firestore_service.dart';

class ScanAttendanceScreen extends StatefulWidget {
  const ScanAttendanceScreen({super.key});

  @override
  State<ScanAttendanceScreen> createState() => _ScanAttendanceScreenState();
}

class _ScanAttendanceScreenState extends State<ScanAttendanceScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  final SessionFirestoreService _service = SessionFirestoreService();
  bool _processing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final raw = barcodes.first.rawValue ?? '';
    if (raw.isEmpty) return;

    _processing = true;
    try {
      // Expect QR payload as "sessionId|pin"
      final parts = raw.split('|');
      if (parts.length < 2) {
        _showMsg("Invalid QR format");
        _processing = false;
        return;
      }
      final sessionId = parts[0];
      final qrPin = parts[1];

      // Make sure session exists and is active
      final sessionDoc = await _service.getSessionDoc(sessionId);
      if (sessionDoc == null) {
        _showMsg("Session not found");
        _processing = false;
        return;
      }
      if (sessionDoc['qrActive'] != true) {
        _showMsg("This QR session is not active");
        _processing = false;
        return;
      }
      // Ask student to enter PIN (faculty will provide)
      final enteredPin = await _askForPin();
      if (enteredPin == null) {
        _processing = false;
        return;
      }
      if (enteredPin != qrPin) {
        _showMsg("PIN mismatch. Attendance not recorded.");
        _processing = false;
        return;
      }

      // Prevent duplicate marking
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final already = await _service.hasAttendance(sessionId, uid);
      if (already) {
        _showMsg("Attendance already recorded for this session");
        _processing = false;
        return;
      }

      // Mark attendance
      await _service.markAttendance(
        sessionId: sessionId,
        studentId: uid,
        status: 'present',
        subjectId: sessionDoc['subjectId'] ?? '',
      );
      _showMsg("Attendance recorded ✅");
    } catch (e) {
      _showMsg("Error: $e");
    } finally {
      // small delay to avoid immediate re-detect
      await Future.delayed(const Duration(milliseconds: 700));
      _processing = false;
    }
  }

  Future<String?> _askForPin() async {
    final controller = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enter PIN"),
        content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "4-digit PIN")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text("Verify")),
        ],
      ),
    );
    return result;
  }

  void _showMsg(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Attendance"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                return Icon(Icons.flash_on);
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(icon: const Icon(Icons.cameraswitch), onPressed: () => cameraController.switchCamera()),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: cameraController,
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "Point camera at the session QR. After scanning, enter the 4-digit PIN provided by faculty.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
