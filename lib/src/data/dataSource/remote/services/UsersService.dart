import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:rabbit_flutter/src/data/api/ApiConfig.dart';
import 'package:rabbit_flutter/src/domain/models/user.dart';
import 'package:rabbit_flutter/src/domain/utils/ListToString.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

class UsersService {

  Future<String> token;

  UsersService(this.token);

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

  Future<Resource<User>> update(int id, User user) async {
    try {
      Uri url = Uri.http(ApiConfig.API_RABBIT, '/users/$id');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      String body = json.encode({
        'name': user.name,
        'lastname': user.lastname,
        'phone': user.phone,
      });
      final response = await http.put(url, headers: headers, body: body);
      final data = _safeDecode(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is! Map<String, dynamic>) {
          return ErrorData('Respuesta inválida del servidor');
        }
        User userResponse = User.fromJson(data);
        return Success(userResponse);
      }
      else {
        return ErrorData(_errorMessage(data));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<User>> updateNotificationToken(int id, String notificationToken) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': await token,
      };
      final body = json.encode({
        'notification_token': notificationToken,
        'id_user': id,
      });
      final candidatePaths = [
        '/users/notification_token/$id',
        '/users/notification-token/$id',
        '/users/notification_token',
        '/users/notification-token',
      ];
      dynamic lastData;
      int? lastStatus;

      for (final path in candidatePaths) {
        final url = Uri.http(ApiConfig.API_RABBIT, path);
        final response = await http.put(url, headers: headers, body: body);
        final data = _safeDecode(response);
        lastData = data;
        lastStatus = response.statusCode;

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (data is! Map<String, dynamic>) {
            return ErrorData('Respuesta inválida del servidor');
          }
          final userResponse = User.fromJson(data);
          return Success(userResponse);
        }

        // Si la ruta no existe, intenta la siguiente variante.
        if (response.statusCode == 404) continue;

        return ErrorData(_errorMessage(data));
      }

      return ErrorData(
        'No se pudo actualizar notification_token (status ${lastStatus ?? 'N/A'}): '
        '${_errorMessage(lastData)}',
      );
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<User>> updateImage(int id, User user, File file) async { 
    try {
      Uri url = Uri.http(ApiConfig.API_RABBIT, '/users/upload/$id');
      final request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = await token;
      request.files.add(http.MultipartFile(
        'file',
        http.ByteStream(file.openRead().cast()),
        await file.length(),
        filename: basename(file.path),
        contentType: MediaType('image', 'jpg')
      ));
      request.fields['name'] = user.name;
      request.fields['lastname'] = user.lastname;
      request.fields['phone'] = user.phone;
      final response = await request.send();
      final data = json.decode(await response.stream.transform(utf8.decoder).first);
      if (response.statusCode == 200 || response.statusCode == 201) {
        User userResponse = User.fromJson(data);
        return Success(userResponse);
      }
      else {
         return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

}