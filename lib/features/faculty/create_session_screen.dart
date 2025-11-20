import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/session_firestore_service.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _durationController =
      TextEditingController(text: "120");

  final SessionFirestoreService _sessionService = SessionFirestoreService();

  String? _sessionId;
  String? _pin;
  bool _loading = false;

  // Show snackbar message
  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _createSession() async {
    final subject = _subjectController.text.trim();
    final duration = int.tryParse(_durationController.text.trim()) ?? 120;

    if (subject.isEmpty) {
      _msg("Please enter subject ID");
      return;
    }

    if (duration < 20) {
      _msg("Duration must be at least 20 seconds");
      return;
    }

    setState(() => _loading = true);

    // Create session
    final sid = await _sessionService.createSession(
      subjectId: subject,
      durationSeconds: duration,
    );

    if (sid == null) {
      _msg("Error: user not logged in OR Firebase issue");
      setState(() => _loading = false);
      return;
    }

    // Fetch PIN from Firestore
    final snap = await FirebaseFirestore.instance
        .collection('sessions')
        .doc(sid)
        .get();

    final data = snap.data();
    final pin = data?['pin']?.toString();

    setState(() {
      _sessionId = sid;
      _pin = pin;
      _loading = false;
    });

    _msg("Session created successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Session"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: "Subject ID",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Duration (seconds)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _createSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Create Session",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              // Display QR + PIN after session creation
              if (_sessionId != null && _pin != null) ...[
                Text(
                  "Session Created",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 10),

                SelectableText(
                  "Session ID: $_sessionId",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10),

                Text(
                  "PIN: $_pin",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                // QR: Contains only sessionId|pin
                QrImageView(
                  data: "$_sessionId|$_pin",
                  size: 230,
                  backgroundColor: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
