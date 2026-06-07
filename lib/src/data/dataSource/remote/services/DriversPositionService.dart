import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rabbit_flutter/src/data/api/ApiConfig.dart';
import 'package:rabbit_flutter/src/domain/models/DriverPosition.dart';
import 'package:rabbit_flutter/src/domain/utils/ListToString.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

class DriversPositionService {
  Future<String> token;
  DriversPositionService(this.token);

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

  Future<Resource<bool>> create(DriverPosition driverPosition) async {
    try {
      Uri url = Uri.http(ApiConfig.API_RABBIT, '/drivers-position');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      String body = json.encode(driverPosition);
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

  Future<Resource<DriverPosition>> getDriverPosition(int idDriver) async {
    try {
      Uri url =
          Uri.http(ApiConfig.API_RABBIT, '/drivers-position/${idDriver}');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      final response = await http.get(url, headers: headers);
      final data = _safeDecode(response);
      
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is! Map<String, dynamic>) {
          return ErrorData('Respuesta inválida del servidor');
        }
        DriverPosition driverPosition = DriverPosition.fromJson(data);
        return Success(driverPosition);
      } else {
        return ErrorData(_errorMessage(data));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<bool>> delete(int idDriver) async {
    try {
      Uri url =
          Uri.http(ApiConfig.API_RABBIT, '/drivers-position/${idDriver}');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      final response = await http.delete(url, headers: headers);
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
}