import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rabbit_flutter/src/data/api/ApiConfig.dart';
import 'package:rabbit_flutter/src/domain/models/DriverBikeInfo.dart';
import 'package:rabbit_flutter/src/domain/utils/ListToString.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

class DriverBikeInfoService {
  Future<String> token;
  DriverBikeInfoService(this.token);

  Future<Resource<bool>> create(DriverBikeInfo driverBikeInfo) async {
    try {
      Uri url = Uri.http(ApiConfig.API_RABBIT, '/driver-bike-info');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      String body = json.encode(driverBikeInfo);
      final response = await http.post(url, headers: headers, body: body);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(true);
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<DriverBikeInfo>> getDriverBikeInfo(int idDriver) async {
    try {
      Uri url = Uri.http(ApiConfig.API_RABBIT, '/driver-bike-info/$idDriver');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      final response = await http.get(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200  || response.statusCode == 201) {
        DriverBikeInfo driverBikeInfo = DriverBikeInfo.fromJson(data);
        return Success(driverBikeInfo);
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }
}