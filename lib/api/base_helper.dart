import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:qme/utilities/logger.dart';

import 'app_exceptions.dart';
import 'kAPI.dart';

String getPrettyJSONString(jsonObject) {
  var encoder = new JsonEncoder.withIndent("     ");
  return encoder.convert(jsonObject);
}

String bearerToken(String accessToken) => 'Bearer $accessToken';

class ApiBaseHelper {
  Future<dynamic> get(String url) async {
    var responseJson;
    try {
      final response = await http.get(baseURL + url);
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(String url,
      {Map req, Map<String, String> headers, String authToken}) async {
    var responseJson;
    try {
      if (req != null) {
        headers = headers == null ? {} : headers;
        headers['Accept'] = 'application/json';
        headers['Content-type'] = 'application/json';
        if (authToken != null) {
          headers[HttpHeaders.authorizationHeader] = bearerToken(authToken);
        }
      }
      logger.d('Posting to ${baseURL + url}\nRequest:$req\nHeader:$headers');
      final response = await http.post(
        baseURL + url,
        headers: headers,
        body: jsonEncode(req),
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } finally {
      // logger.d('Response' + getPrettyJSONString(responseJson));
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
//        logger.d('Response:$responseJson');
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}

enum Status { LOADING, COMPLETED, ERROR }

class ApiResponse<T> {
  Status status;
  T data;
  String message;

  ApiResponse.loading(this.message) : status = Status.LOADING;
  ApiResponse.completed(this.data) : status = Status.COMPLETED;
  ApiResponse.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}
