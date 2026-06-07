import 'dart:convert';

import 'package:rabbit_flutter/src/data/api/ApiConfig.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequest.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/domain/models/StatusTrip.dart';
import 'package:rabbit_flutter/src/domain/models/TimeAndDistanceValues.dart';
import 'package:rabbit_flutter/src/domain/utils/ListToString.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:http/http.dart' as http;

class ClientRequestsService {
  Future<String> token;
  ClientRequestsService(this.token);

  Future<Map<String, String>> _authHeaders() async {
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
    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.toLowerCase().contains('application/json')) {
      return {
        'message': body.length > 300 ? body.substring(0, 300) : body,
      };
    }
    try {
      return json.decode(body);
    } catch (_) {
      return {
        'message': body.length > 300 ? body.substring(0, 300) : body,
      };
    }
  }

  String _errorMessage(dynamic data, {String fallback = 'Error inesperado'}) {
    if (data is Map && data['message'] != null) {
      return listToString(data['message']);
    }
    if (data is String && data.isNotEmpty) return data;
    return fallback;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final nested =
          data['data'] ?? data['results'] ?? data['items'] ?? data['requests'];
      if (nested is List) return nested;
    }
    return const [];
  }

  /// Backend devuelve `[id]`; algunas versiones usan `{"id_client_request": id}`.
  int? _parseCreatedClientRequestId(dynamic data) {
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      return first is int ? first : int.tryParse(first.toString());
    }
    if (data is Map && data['id_client_request'] != null) {
      final id = data['id_client_request'];
      return id is int ? id : int.tryParse(id.toString());
    }
    return null;
  }

  Future<Resource<int>> create(ClientRequest clientRequest) async {
    try {
      Uri url = Uri.http(ApiConfig.API_RABBIT, '/client-requests');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      String body = json.encode(clientRequest);
      final response = await http.post(url, headers: headers, body: body);
      final data = _safeDecode(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final id = _parseCreatedClientRequestId(data);
        if (id == null) {
          return ErrorData('Respuesta inválida del servidor');
        }
        return Success(id);
      } else {
        return ErrorData(_errorMessage(data));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<bool>> updateStatus(
      int idClientRequest, StatusTrip statusTrip) async {
    try {
      Uri url =
          Uri.http(ApiConfig.API_RABBIT, '/client-requests/update_status');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      String body = json.encode({
        'id_client_request': idClientRequest,
        'status': statusTrip.name,
      });
      final response = await http.put(url, headers: headers, body: body);
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

  Future<Resource<bool>> updateDriverRating(
      int idClientRequest, double rating) async {
    try {
      Uri url = Uri.http(
          ApiConfig.API_RABBIT, '/client-requests/update_driver_rating');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      String body = json.encode({
        'id_client_request': idClientRequest,
        'driver_rating': rating,
      });
      final response = await http.put(url, headers: headers, body: body);
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

  Future<Resource<bool>> updateClientRating(
      int idClientRequest, double rating) async {
    try {
      Uri url = Uri.http(
          ApiConfig.API_RABBIT, '/client-requests/update_client_rating');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      String body = json.encode({
        'id_client_request': idClientRequest,
        'client_rating': rating,
      });
      final response = await http.put(url, headers: headers, body: body);
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

  Future<Resource<bool>> updateDriverAssigned(
      int idClientRequest, int idDriver, double fareAssigned) async {
    try {
      Uri url = Uri.http(
          ApiConfig.API_RABBIT, '/client-requests/updateDriverAssigned');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      String body = json.encode({
        'id': idClientRequest,
        'id_driver_assigned': idDriver,
        'fare_assigned': fareAssigned
      });
      final response = await http.put(url, headers: headers, body: body);
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

  Future<Resource<TimeAndDistanceValues>> getTimeAndDistanceClientRequets(
      double originLat,
      double originLng,
      double destinationLat,
      double destinationLng) async {
    try {
      Uri url = Uri.http(ApiConfig.API_RABBIT,
          '/client-requests/${originLat}/${originLng}/${destinationLat}/${destinationLng}');
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
        TimeAndDistanceValues timeAndDistanceValues =
            TimeAndDistanceValues.fromJson(data);
        return Success(timeAndDistanceValues);
      } else {
        return ErrorData(_errorMessage(data));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<List<ClientRequestResponse>>> getNearbyTripRequest(
      double driverLat, double driverLng) async {
    try {
      Uri url = Uri.http(
          ApiConfig.API_RABBIT, '/client-requests/${driverLat}/${driverLng}');
      Map<String, String> headers = await _authHeaders();
      print('GET nearby trip requests URL: $url');
      final response = await http.get(url, headers: headers);
      final data = _safeDecode(response);
      print('GET nearby trip requests status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final list = _extractList(data);
        List<ClientRequestResponse> clientRequests =
            ClientRequestResponse.fromJsonList(list);
        print('GET nearby trip requests list size: ${clientRequests.length}');
        return Success(clientRequests);
      } else if (response.statusCode == 401) {
        return ErrorData('Sesion expirada (401). Inicia sesion nuevamente.');
      } else {
        return ErrorData(_errorMessage(data));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<List<ClientRequestResponse>>> getByDriverAssigned(
      int idDriver) async {
    try {
      Uri url = Uri.http(
          ApiConfig.API_RABBIT, '/client-requests/driver/assigned/$idDriver');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      final response = await http.get(url, headers: headers);
      final data = _safeDecode(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is! List) {
          return ErrorData('Respuesta inválida del servidor');
        }
        List<ClientRequestResponse> clientRequests =
            ClientRequestResponse.fromJsonList(data);
        return Success(clientRequests);
      } else {
        return ErrorData(_errorMessage(data));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<List<ClientRequestResponse>>> getByClientAssigned(
      int idClient) async {
    try {
      Uri url = Uri.http(
          ApiConfig.API_RABBIT, '/client-requests/client/assigned/$idClient');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      final response = await http.get(url, headers: headers);
      final data = _safeDecode(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is! List) {
          return ErrorData('Respuesta inválida del servidor');
        }
        List<ClientRequestResponse> clientRequests =
            ClientRequestResponse.fromJsonList(data);
        return Success(clientRequests);
      } else {
        return ErrorData(_errorMessage(data));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<ClientRequestResponse>> getByClientRequest(
      int idClientRequest) async {
    try {
      Uri url =
          Uri.http(ApiConfig.API_RABBIT, '/client-requests/${idClientRequest}');
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
        ClientRequestResponse clientRequests =
            ClientRequestResponse.fromJson(data);
        return Success(clientRequests);
      } else {
        return ErrorData(_errorMessage(data));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }
}
