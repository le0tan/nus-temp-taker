import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'exception.dart';

class HTTPClient {
  Dio dio;
  CookieManager cm;

  HTTPClient() {
    dio = Dio();
    dio.interceptors.add(CookieManager(CookieJar()));
    cm = new CookieManager(CookieJar());
  }

  static void _catchHttpExceptions(Response resp, String place) {
    switch (resp.statusCode) {
      case 400:
        throw BadRequestException(place);
      case 403:
        throw ForbiddenException(place);
      case 404:
        throw NotFoundException(place);
      case 500:
        throw InternalServerErrorException(place);
      default:
        return;
    }
  }

  int _receiveTimeOut = 10000;
  int _sendTimeOut = 5000;

  Future<Response> get(String url, {Map<String, String> headers}) async {
    Response resp;
    try {
      resp = await dio.get(url,
          options: Options(
              receiveTimeout: _receiveTimeOut,
              sendTimeout: _sendTimeOut,
              headers: headers,
              followRedirects: false,
              validateStatus: (status) {
                // 500 would be caught later,
                // this is for the sake of exception consistency.
                return status <= 500;
              }));
    } catch (e) {
      if (e.toString().startsWith(
          "DioError [DioErrorType.DEFAULT]: NoSuchMethodError: The method 'startsWith' was called on null.")) {
        throw WrongCredentialsException();
      } else {
        rethrow;
      }
    }

    _catchHttpExceptions(resp, 'HTTPClient.get');
    return resp;
  }

  Future<Response> post(String url, dynamic payload, {Map<String, String> headers}) async {
    Response resp = await dio.post(url,
        data: payload,
        options: Options(
            receiveTimeout: _receiveTimeOut,
            sendTimeout: _sendTimeOut,
            contentType: 'application/x-www-form-urlencoded',
            headers: headers,
            followRedirects: false,
            validateStatus: (status) {
              return status < 500;
            }));
    _catchHttpExceptions(resp, 'HTTPClient.post');
    return resp;
  }
}
