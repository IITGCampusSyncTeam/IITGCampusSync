import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/endpoints.dart';
import '../protected.dart';

class ClubMemberAPI {
  static Future<bool> addOrEditMember(String clubId, String email, String responsibility) async {
    final url = ClubMembers.addOrEditMember(clubId, email);
    String token = await getAccessToken();
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },

      body: jsonEncode({'responsibility': responsibility}),
    );

    return response.statusCode == 200;
  }

  static Future<bool> removeMember(String clubId, String email) async {
    final url = ClubMembers.removeMember(clubId, email);
    String token = await getAccessToken();
    final response = await http.delete(Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
    }
    );
    return response.statusCode == 200;
  }
}