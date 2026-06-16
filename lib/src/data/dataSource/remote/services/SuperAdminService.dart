import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rabbit_flutter/src/data/api/ApiConfig.dart';
import 'package:rabbit_flutter/src/data/dataSource/local/SharefPref.dart';
import 'package:rabbit_flutter/src/domain/models/AuthResponse.dart';
import 'package:rabbit_flutter/src/domain/models/SuperLine.dart';
import 'package:rabbit_flutter/src/domain/models/SuperLineSubscription.dart';
import 'package:rabbit_flutter/src/domain/utils/ListToString.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

class SuperAdminService {
  final SharefPref _sharefPref;

  SuperAdminService(this._sharefPref);

  Future<Map<String, String>> _headers() async {
    String rawToken = '';
    final userSession = await _sharefPref.read('usuario');
    if (userSession is Map) {
      final authResponse = AuthResponse.fromJson(
        Map<String, dynamic>.from(userSession),
      );
      rawToken = authResponse.token;
    }
    final authToken = rawToken.trim().toLowerCase().startsWith('bearer ')
        ? rawToken.trim()
        : 'Bearer ${rawToken.trim()}';
    return {
      'Content-Type': 'application/json',
      'Authorization': authToken,
    };
  }

  dynamic _safeDecode(http.Response response) {
    final body = response.body.trim();
    if (body.isEmpty) return null;
    try {
      return json.decode(body);
    } catch (_) {
      return {'message': body};
    }
  }

  String _errorMessage(dynamic data,
      {String fallback = 'No fue posible completar la operación'}) {
    if (data is Map && data['message'] != null) {
      return listToString(data['message']);
    }
    if (data is String && data.isNotEmpty) return data;
    return fallback;
  }

  SuperLineSubscription _subscriptionFromResponse(dynamic data) {
    if (data is Map && data['subscription'] is Map) {
      return SuperLineSubscription.fromJson(
        Map<String, dynamic>.from(data['subscription']),
      );
    }
    return SuperLineSubscription(plan: 'piloto', status: 'activa');
  }

  Future<Resource<List<SuperLine>>> getLines() async {
    try {
      final uri = Uri.http(ApiConfig.API_RABBIT, '/admin/super/lines');
      final response = await http.get(uri, headers: await _headers());
      final data = _safeDecode(response);
      debugPrint('[SuperAdminService] GET $uri -> ${response.statusCode}');
      if (response.statusCode == 200) {
        if (data is! List) return Success(const <SuperLine>[]);
        final lines = data
            .whereType<Map>()
            .map((e) => SuperLine.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return Success(lines);
      }
      return ErrorData('HTTP ${response.statusCode}: ${_errorMessage(data)}');
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<SuperLineSubscription>> activateLine(int lineId) async {
    return _postSubscriptionAction(
      '/admin/super/lines/$lineId/subscription/activate',
    );
  }

  Future<Resource<SuperLineSubscription>> suspendLine(int lineId) async {
    return _postSubscriptionAction(
      '/admin/super/lines/$lineId/subscription/suspend',
    );
  }

  Future<Resource<bool>> deleteLine(int lineId) async {
    final attempts = <Map<String, dynamic>>[
      {
        'path': '/admin/super/delete-line',
        'body': {'line_id': lineId},
      },
      {
        'path': '/admin/super/lines/$lineId/delete',
        'body': {},
      },
      {
        'path': '/admin/super/lines/$lineId',
        'body': {},
      },
    ];

    Resource<bool>? lastError;
    for (final attempt in attempts) {
      final path = attempt['path'] as String;
      final body = attempt['body'] as Map<String, dynamic>;
      try {
        final uri = Uri.http(ApiConfig.API_RABBIT, path);
        final response = await http.post(
          uri,
          headers: await _headers(),
          body: json.encode(body),
        );
        final data = _safeDecode(response);
        debugPrint('[SuperAdminService] POST $uri -> ${response.statusCode}');
        if (response.statusCode == 200) {
          return Success(true);
        }
        final err = ErrorData<bool>(
          'HTTP ${response.statusCode}: ${_errorMessage(data)}',
        );
        if (response.statusCode != 404 && response.statusCode != 405) {
          return err;
        }
        lastError = err;
      } catch (e) {
        return ErrorData<bool>(e.toString());
      }
    }
    return lastError ?? ErrorData<bool>('No fue posible eliminar la línea');
  }

  Future<Resource<SuperLineSubscription>> recordPayment({
    required int lineId,
    String? plan,
    String? notes,
    String? lastPaymentAt,
  }) async {
    return _postSubscriptionAction(
      '/admin/super/lines/$lineId/subscription/record-payment',
      body: {
        if (plan != null && plan.isNotEmpty) 'plan': plan,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (lastPaymentAt != null && lastPaymentAt.isNotEmpty)
          'last_payment_at': lastPaymentAt,
      },
    );
  }

  Future<Resource<SuperLineSubscription>> patchSubscription({
    required int lineId,
    String? plan,
    String? status,
    String? notes,
    String? nextBillingAt,
    String? lastPaymentAt,
  }) async {
    try {
      final uri = Uri.http(
        ApiConfig.API_RABBIT,
        '/admin/super/lines/$lineId/subscription',
      );
      final response = await http.patch(
        uri,
        headers: await _headers(),
        body: json.encode({
          if (plan != null) 'plan': plan,
          if (status != null) 'status': status,
          if (notes != null) 'notes': notes,
          if (nextBillingAt != null) 'next_billing_at': nextBillingAt,
          if (lastPaymentAt != null) 'last_payment_at': lastPaymentAt,
        }),
      );
      final data = _safeDecode(response);
      debugPrint('[SuperAdminService] PATCH $uri -> ${response.statusCode}');
      if (response.statusCode == 200) {
        return Success(_subscriptionFromResponse(data));
      }
      return ErrorData('HTTP ${response.statusCode}: ${_errorMessage(data)}');
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<SuperLineSubscription>> _postSubscriptionAction(
    String path, {
    Map<String, dynamic> body = const {},
  }) async {
    try {
      final uri = Uri.http(ApiConfig.API_RABBIT, path);
      final response = await http.post(
        uri,
        headers: await _headers(),
        body: json.encode(body),
      );
      final data = _safeDecode(response);
      debugPrint('[SuperAdminService] POST $uri -> ${response.statusCode}');
      if (response.statusCode == 200) {
        return Success(_subscriptionFromResponse(data));
      }
      return ErrorData('HTTP ${response.statusCode}: ${_errorMessage(data)}');
    } catch (e) {
      return ErrorData(e.toString());
    }
  }
}
