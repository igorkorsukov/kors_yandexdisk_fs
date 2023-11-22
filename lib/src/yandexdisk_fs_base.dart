import 'package:http/http.dart' as http;
import 'dart:convert';

class YandexDiskFS {
  static const String _disk = '/v1/disk';
  static const String _resources = '$_disk/resources';

  final Uri _baseUrl;
  final Map<String, String> _authHeader;

  YandexDiskFS(final String baseUrl, final String accessToken)
      : _baseUrl = Uri.parse(baseUrl),
        _authHeader = {'Authorization': 'OAuth $accessToken'};

  /// Check exists dir or file
  /// See: https://yandex.ru/dev/disk/api/reference/meta.html
  Future<bool> exists(final String path) async {
    final Uri uri = Uri.https(_baseUrl.host, _resources, {'path': path});
    final response = await http.get(uri, headers: _authHeader);
    switch (response.statusCode) {
      case 200:
        return true;
      case 404:
        return false;
      default:
        throw Exception(response.reasonPhrase);
    }
  }

  /// Remove dir or file
  /// See: https://yandex.ru/dev/disk/api/reference/delete.html
  Future<void> remove(final String path) async {
    final Uri uri = Uri.https(_baseUrl.host, _resources, {'path': path});
    final response = await http.delete(uri, headers: _authHeader);
    switch (response.statusCode) {
      case 200:
        return; // good (not happening)
      case 202:
        return; // good (async)
      case 204:
        return; // good (removed)
      case 404:
        return; // good (not exists)
      default:
        throw Exception(response.reasonPhrase);
    }
  }

  /// Upload the file.
  /// See: https://yandex.ru/dev/disk/api/reference/upload.html
  Future<void> writeFile(final String path, final Object data) async {
    final Uri uri = Uri.https(_baseUrl.host, '$_resources/upload', {'path': path});
    var response = await http.get(uri, headers: _authHeader);
    if (response.statusCode != 200) {
      throw Exception(response.reasonPhrase);
    }

    var link = jsonDecode(response.body);
    var uploadUri = Uri.parse(link['href'].toString());
    response = await http.put(uploadUri, body: data);
    switch (response.statusCode) {
      case 201:
        return; // good (created)
      case 202:
        return; // good (accepted)
      default:
        throw Exception(response.reasonPhrase);
    }
  }

  /// Download the file.
  /// See: https://yandex.ru/dev/disk/api/reference/content.html
  Future<List<int> /*bytes*/ > readFile(final String path) async {
    final Uri uri = Uri.https(_baseUrl.host, '$_resources/download', {'path': path});
    var response = await http.get(uri, headers: _authHeader);
    if (response.statusCode != 200) {
      throw Exception(response.reasonPhrase);
    }

    var link = jsonDecode(response.body);
    var downloadUri = Uri.parse(link['href'].toString());
    response = await http.get(downloadUri, headers: _authHeader);
    if (response.statusCode != 200) {
      throw Exception(response.reasonPhrase);
    }

    return response.bodyBytes;
  }

  /// Create the folder.
  /// See: https://yandex.ru/dev/disk/api/reference/create-folder.html
  Future<void> makeDir(final String path) async {
    final Uri uri = Uri.https(_baseUrl.host, _resources, {'path': path});
    final response = await http.put(uri, headers: _authHeader);
    switch (response.statusCode) {
      case 201:
        return; // good (created)
      case 409:
        return; // good (already created)
      default:
        throw Exception(response.reasonPhrase);
    }
  }

  /// Get list of files
  /// See: https://yandex.ru/dev/disk/api/reference/meta.html
  Future<List<String /*names*/ >> scanFiles(final String path) async {
    final Uri uri = Uri.https(_baseUrl.host, _resources, {'path': path});
    final response = await http.get(uri, headers: _authHeader);
    if (response.statusCode != 200) {
      throw Exception(response.reasonPhrase);
    }

    List<String> files = [];
    var meta = jsonDecode(response.body);
    var items = meta["_embedded"]["items"];
    for (var item in items) {
      if (item["type"] == "file") {
        files.add(item["name"].toString());
      }
    }
    return files;
  }
}
