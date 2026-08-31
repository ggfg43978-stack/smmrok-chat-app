import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://app.smmrok.com/api/';

  static Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final res = await http.post(
      Uri.parse(baseUrl + 'auth/register.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login(
      String identifier, String password) async {
    final res = await http.post(
      Uri.parse(baseUrl + 'auth/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': identifier,
        'password': password,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> listRooms() async {
    final res = await http.get(Uri.parse(baseUrl + 'rooms/list.php'));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createRoom(
      String token, String name, String description) async {
    final res = await http.post(
      Uri.parse(baseUrl + 'rooms/create.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'name': name,
        'description': description,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> joinRoom(
      String token, int roomId) async {
    final res = await http.post(
      Uri.parse(baseUrl + 'rooms/join.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'room_id': roomId,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> sendMessage(
      String token, int roomId, String message) async {
    final res = await http.post(
      Uri.parse(baseUrl + 'messages/send.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'room_id': roomId,
        'message': message,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getMessages(int roomId) async {
    final res = await http
        .get(Uri.parse(baseUrl + 'messages/get.php?room_id=$roomId'));
    return jsonDecode(res.body);
  }
}
