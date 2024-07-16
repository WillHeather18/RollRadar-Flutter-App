import 'package:http/http.dart' as http;
import 'package:bungie_api/helpers/http.dart';
import 'package:god_roll_app/config/api_config.dart';

class Client implements HttpClient {
  static Future<String> getApiKey() async {
    return await ApiConfig.getLocalApiKey() ?? 'no-api-key';
  }

  @override
  Future<HttpResponse> request(HttpClientConfig config,
      {String? accessToken}) async {
    final apiKey = await getApiKey();
    final headers = {'X-API-Key': apiKey};

    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final Uri uri =
        Uri.parse(config.url).replace(queryParameters: config.params);
    http.Response response;

    print("Headers: $headers");
    print("URL: ${uri.toString()}");

    if (config.method == 'GET') {
      response = await http.get(uri, headers: headers);
    } else {
      response = await http.post(uri, headers: headers, body: config.body);
    }

    return HttpResponse(response.body, response.statusCode);
  }
}
