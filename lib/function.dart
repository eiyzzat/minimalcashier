import 'package:http/http.dart' as http;
import 'dart:convert';

import 'api.dart';

List<dynamic> staff = [];

class APIFunctions {
  static Future getStaff() async {
    var headers = {
      'token': token,
    };

    var request =
        http.Request('GET', Uri.parse('https://staff.tunai.io/loyalty/staff'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      final body = json.decode(responsebody);
      //message untuk save data dalam
      Map<String, dynamic> minimal = body;

      staff = minimal['staffs'];
      return staff;
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future getDiscount() async {
    List<dynamic> discount = [];
    var headers = {
      'token': token,
    };

    var request = http.Request(
        'GET', Uri.parse('https://menu.tunai.io/loyalty/type/4/sku?active=1'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      final body = json.decode(responsebody);
      //message untuk save data dalam
      Map<String, dynamic> minimal = body;

      discount = minimal['skus'];
      return discount;
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future fetchPending() async {
    var headers = {
      'token': token,
    };

    var request = http.Request(
      'GET',
      Uri.parse('https://order.tunai.io/loyalty/order?active=1'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      final body = json.decode(responsebody);
      List<dynamic> pending = body['orders'];
      return pending;
    } else {
      print(response.reasonPhrase);
      return [];
    }
  }

  static Future<void> fetchServices() async {
    List<dynamic> services = [];
    List<dynamic> sections = [];
    var headers = {'token': token};
    var request = http.Request(
        'GET', Uri.parse('https://menu.tunai.io/loyalty/type/1/sku?active=1'));
    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final jsonData = await response.stream.bytesToString();
      final decodedData = json.decode(jsonData);

      services = decodedData['skus'];
      sections = decodedData['sections'];
    } else {
      print(response.reasonPhrase);
    }
  }
  
}
