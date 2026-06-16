import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:rabbit_flutter/src/data/api/ApiConfig.dart';
import 'package:http/http.dart' as http;
import 'package:rabbit_flutter/src/domain/models/AuthResponse.dart';
import 'package:rabbit_flutter/src/domain/models/user.dart';
import 'package:rabbit_flutter/src/domain/utils/ListToString.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
class AuthService {
  static const _timeout = Duration(seconds: 20);

  String _connectionError(Object error) {
    if (error is TimeoutException ||
        error.toString().contains('Connection timed out')) {
      return 'No se pudo conectar al servidor. Si usas USB ejecuta: '
          'adb reverse tcp:3000 tcp:3000. Si usas WiFi, abre el puerto 3000 '
          'en el firewall y usa la IP de tu PC en ApiConfig.';
    }
    if (error is SocketException ||
        error is http.ClientException ||
        error.toString().contains('SocketException')) {
      return 'Sin conexión al backend (${ApiConfig.API_RABBIT}). '
          'Verifica que Daphne esté activo.';
    }
    return 'Error al procesar login: $error';
  }

  Future<Resource<AuthResponse>> login(String email, String password) async {
  try {
    Uri url = Uri.http(ApiConfig.API_RABBIT, '/auth/login');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String body = json.encode({
      'email': email,
      'password': password
    });
    final response = await http
        .post(url, headers: headers, body: body)
        .timeout(_timeout);
    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final data = json.decode(response.body);
        return ErrorData(listToString(data['message']));
      } catch (_) {
        return ErrorData('Error de login (${response.statusCode})');
      }
    }
    final data = json.decode(response.body);
    if (data is! Map<String, dynamic>) {
      return ErrorData('Respuesta de login inválida');
    }
    AuthResponse authResponse = AuthResponse.fromJson(data);
    print('Data Remote: ${authResponse.toJson()}');
    print('Token: ${authResponse.token}');
    return Success(authResponse);
  } catch (e) {
    print('Error login: $e');
    return ErrorData(_connectionError(e));
  }
}


Future<Resource<AuthResponse>> register(User user) async {
  try {
    Uri url = Uri.http(ApiConfig.API_RABBIT, '/auth/register');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String body = json.encode(user.toJson());
    final response = await http
        .post(url, headers: headers, body: body)
        .timeout(_timeout);
    final data = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201 ) {
      AuthResponse authResponse = AuthResponse.fromJson(data);
      print('Data Remote: ${authResponse.toJson()}');
      print('Token: ${authResponse.token}');
      return Success(authResponse);
    }
    else {
      return ErrorData(listToString(data['message']));
    }
  } catch (e) {
    print('Error register: $e');
    return ErrorData(_connectionError(e));
  }
}

}
