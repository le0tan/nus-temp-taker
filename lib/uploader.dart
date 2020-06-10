import 'dart:io';
import 'package:intl/intl.dart';
import 'package:nus_temp_declarer/http_client.dart';
import 'exception.dart';

class TempDeclarer {
  HTTPClient client;
  String _username;
  String _password;
  String _cookie;

  TempDeclarer(this._username, this._password) : client = new HTTPClient();

  Future<String> _getCookie() async {
    if (_cookie == null) {
      var query = {
        'response_type': 'code',
        'client_id': '97F0D1CACA7D41DE87538F9362924CCB-184318',
        'resource': 'sg_edu_nus_oauth',
        'redirect_uri': 'https://myaces.nus.edu.sg:443/htd/htd',
      };
      var body = {
        'UserName': 'nusstu\\' + this._username,
        'Password': this._password,
        'AuthMethod': 'FormsAuthentication'
      };
      var uri = Uri(
          scheme: 'https',
          host: 'vafs.nus.edu.sg',
          path: '/adfs/oauth2/authorize',
          queryParameters: query);
      var t1 = await client.post(uri.toString(), body);
      var loc1 = t1.headers.value('location');
      var t2 = await client.get(loc1);
      var t3 = await client.get(t2.headers.value('location'));
      try {
        var cookie = Cookie.fromSetCookieValue(t3.headers.value('set-cookie'));
        _cookie = cookie.value;
      } catch (e) {
        throw new AuthorizationException(
            'No set-cookie found in request to temp declaration page.');
      }
    }
    return _cookie;
  }

  Future<bool> _submitTemp(double temp, String date, String freq, bool symptom, bool familySymptom,
      String cookie) async {
    var uri = Uri(scheme: 'https', host: 'myaces.nus.edu.sg', path: '/htd/htd');
    var data = {
      "actionName": "dlytemperature",
      "tempDeclOn": date,
      "declFrequency": freq,
      "temperature": temp,
      "symptomsFlag": symptom ? 'Y' : 'N',
      "familySymptomsFlag" : familySymptom ? 'Y' : 'N'
    };
    var response = await client
        .post(uri.toString(), data, headers: {'Cookie': "JSESSIONID=$cookie;"});
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> submitTemp(double temp,
      {String date, String freq, bool symptom, bool familySymptom}) async {
    try {
      if (date == null) {
        var formatter = DateFormat('dd/MM/yyyy');
        date = formatter.format(DateTime.now());
      }
      if (freq == null) {
        freq = DateTime.now().hour < 12 ? 'A' : 'P';
      }
      if (symptom == null) {
        symptom = false;
      }
      if (familySymptom == null) {
        familySymptom = false;
      }
      if (await _submitTemp(temp, date, freq, symptom, familySymptom, await _getCookie())) {
        return {
          'tempDeclOn': date,
          'declFrequency': freq,
          'temperature': temp,
          'symptomsFlag': symptom,
          "familySymptomsFlag": familySymptom
        };
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String> getRecords() async {
    var params = {'loadPage': 'viewtemperature', 'actionToDo': 'NUS'};
    var uri = Uri(
        scheme: 'https',
        host: 'myaces.nus.edu.sg',
        path: '/htd/htd',
        queryParameters: params);
    var response = await client
        .get(uri.toString(), headers: {'cookie': await _getCookie()});
    return response.data;
  }
}
