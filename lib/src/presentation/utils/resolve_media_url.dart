import 'package:rabbit_flutter/src/data/api/ApiConfig.dart';

String? resolveMediaUrl(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final value = raw.trim();
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  if (value.startsWith('/')) {
    return 'http://${ApiConfig.API_RABBIT}$value';
  }
  return 'http://${ApiConfig.API_RABBIT}/$value';
}
