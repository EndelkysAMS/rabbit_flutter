import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rabbit_flutter/src/data/api/ApiConfig.dart';
import 'package:rabbit_flutter/src/data/dataSource/local/SharefPref.dart';
import 'package:rabbit_flutter/src/domain/models/AuthResponse.dart';
import 'package:rabbit_flutter/src/domain/models/DriverTripRequest.dart';
import 'package:rabbit_flutter/src/domain/utils/ListToString.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

class DriverTripRequestsService {
  Future<String> token;
  DriverTripRequestsService(this.token);
  final SharefPref _sharefPref = SharefPref();

  dynamic _safeDecode(http.Response response) {
    final body = response.body.trim();
    if (body.isEmpty) return null;
    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.toLowerCase().contains('application/json')) {
      return {'message': body.length > 300 ? body.substring(0, 300) : body};
    }
    try {
      return json.decode(body);
    } catch (_) {
      return {'message': body.length > 300 ? body.substring(0, 300) : body};
    }
  }

  String _errorMessage(dynamic data, {String fallback = 'Error inesperado'}) {
    if (data is Map && data['message'] != null) {
      return listToString(data['message']);
    }
    if (data is String && data.isNotEmpty) return data;
    return fallback;
  }

  Future<String> _resolveToken() async {
    final injectedToken = await token;
    if (injectedToken.trim().isNotEmpty) return injectedToken;
    final userSession = await _sharefPref.read('usuario');
    if (userSession != null) {
      final authResponse = AuthResponse.fromJson(userSession);
      return authResponse.token;
    }
    return '';
  }

  Future<Resource<bool>> create(DriverTripRequest driverTripRequest) async {
    try {
      Uri url = Uri.http(ApiConfig.API_RABBIT, '/driver-trip-offers');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await _resolveToken()
      };
      String body = json.encode(driverTripRequest);
      final response = await http.post(url, headers: headers, body: body);
      final data = _safeDecode(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(true);
      } else {
        return ErrorData(_errorMessage(data));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<List<DriverTripRequest>>> getDriverTripOffersByClientRequest(
      int idClientRequest) async {
    try {
      Uri url = Uri.http(ApiConfig.API_RABBIT,
          '/driver-trip-offers/findByClientRequest/${idClientRequest}');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await _resolveToken()
      };
      final response = await http.get(url, headers: headers);
      final data = _safeDecode(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is! List) {
          return ErrorData('Respuesta inválida del servidor');
        }
        List<DriverTripRequest> driverTripRequest =
            DriverTripRequest.fromJsonList(data);
        return Success(driverTripRequest);
      } else {
        return ErrorData(_errorMessage(data));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }
}
