import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:rabbit_flutter/src/data/api/ApiConfig.dart';

// #region agent log
void agentDebugLog({
  required String location,
  required String message,
  Map<String, dynamic>? data,
  String? hypothesisId,
  String runId = 'pre-fix',
}) {
  final payload = <String, dynamic>{
    'sessionId': '48a930',
    'location': location,
    'message': message,
    'data': data ?? <String, dynamic>{},
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    if (hypothesisId != null) 'hypothesisId': hypothesisId,
    'runId': runId,
  };
  final line = jsonEncode(payload);
  // Logcat + flutter run console (USB)
  print('[AgentDebug] $line');

  // Best-effort local file on Windows dev machine
  if (Platform.isWindows) {
    try {
      File('debug-48a930.log').writeAsStringSync('$line\n', mode: FileMode.append);
    } catch (_) {}
  }

  final host = ApiConfig.API_RABBIT.split(':').first;
  for (final base in ['http://$host:7806', 'http://127.0.0.1:7806']) {
    http
        .post(
          Uri.parse('$base/ingest/cbc04595-888f-48a6-83da-09cb5e7d5175'),
          headers: {
            'Content-Type': 'application/json',
            'X-Debug-Session-Id': '48a930',
          },
          body: line,
        )
        .then((_) {}, onError: (_) {});
  }
}
// #endregion
