import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:rabbit_flutter/src/data/api/ApiConfig.dart';
import 'package:rabbit_flutter/src/domain/models/AdminLineaCreateDriver.dart';
import 'package:rabbit_flutter/src/domain/models/AdminLineaDriver.dart';
import 'package:rabbit_flutter/src/domain/models/AdminLineaProfile.dart';
import 'package:rabbit_flutter/src/domain/utils/ListToString.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

class AdminLineaService {
  Future<String> token;

  AdminLineaService(this.token);

  Future<Map<String, String>> _headers() async {
    final rawToken = (await token).trim();
    final authToken = rawToken.toLowerCase().startsWith('bearer ')
        ? rawToken
        : 'Bearer $rawToken';
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

  Future<Resource<List<AdminLineaDriver>>> getDrivers({bool? isActive}) async {
    try {
      final queryParams = isActive == null
          ? <String, String>{}
          : <String, String>{'is_active': isActive.toString()};
      final uri = Uri.http(
        ApiConfig.API_RABBIT,
        '/admin-linea/drivers',
        queryParams,
      );
      final response = await http.get(uri, headers: await _headers());
      final data = _safeDecode(response);
      debugPrint('[AdminLineaService] GET $uri -> ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is! List) return Success(const <AdminLineaDriver>[]);
        final drivers = data
            .whereType<Map>()
            .map((e) => AdminLineaDriver.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        debugPrint('[AdminLineaService] drivers_count=${drivers.length}');
        return Success(drivers);
      }
      return ErrorData('HTTP ${response.statusCode}: ${_errorMessage(data)}');
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<AdminLineaDriver>> createDriver(
      AdminLineaCreateDriver createDriver) async {
    try {
      final uri = Uri.http(ApiConfig.API_RABBIT, '/admin-linea/drivers');
      final response = await http.post(
        uri,
        headers: await _headers(),
        body: json.encode(createDriver.toJson()),
      );
      final data = _safeDecode(response);
      debugPrint('[AdminLineaService] POST $uri -> ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is! Map<String, dynamic>) {
          return ErrorData('Respuesta inválida del servidor');
        }
        return Success(AdminLineaDriver.fromJson(data));
      }
      return ErrorData('HTTP ${response.statusCode}: ${_errorMessage(data)}');
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<bool>> deactivateDriver(int idDriver) async {
    try {
      final uri = Uri.http(ApiConfig.API_RABBIT, '/admin-linea/drivers/$idDriver/deactivate');
      final response = await http.patch(
        uri,
        headers: await _headers(),
        body: json.encode({}),
      );
      final data = _safeDecode(response);
      debugPrint('[AdminLineaService] PATCH $uri -> ${response.statusCode}');
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return Success(true);
      }
      return ErrorData('HTTP ${response.statusCode}: ${_errorMessage(data)}');
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<bool>> deleteDriver(int idDriver) async {
    try {
      final uri =
          Uri.http(ApiConfig.API_RABBIT, '/admin-linea/drivers/$idDriver');
      final response = await http.delete(uri, headers: await _headers());
      final data = _safeDecode(response);
      debugPrint('[AdminLineaService] DELETE $uri -> ${response.statusCode}');
      if (response.statusCode == 200 ||
          response.statusCode == 202 ||
          response.statusCode == 204) {
        return Success(true);
      }
      return ErrorData('HTTP ${response.statusCode}: ${_errorMessage(data)}');
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<bool>> updateProfile(AdminLineaProfile profile) async {
    try {
      final uri = Uri.http(ApiConfig.API_RABBIT, '/admin-linea/profile');
      final response = await http.patch(
        uri,
        headers: await _headers(),
        body: json.encode(profile.toJson()),
      );
      final data = _safeDecode(response);
      debugPrint('[AdminLineaService] PATCH $uri -> ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(true);
      }
      return ErrorData('HTTP ${response.statusCode}: ${_errorMessage(data)}');
    } catch (e) {
      return ErrorData(e.toString());
    }
  }
}

