import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/endpoints.dart';
<<<<<<< HEAD
=======
import '../protected.dart';
>>>>>>> 17a011c173a2b49e786808ab48e6c0ee057677a0

class ClubMemberAPI {
  static Future<bool> addOrEditMember(String clubId, String email, String responsibility) async {
    final url = ClubMembers.addOrEditMember(clubId, email);
<<<<<<< HEAD
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
=======
    String token = await getAccessToken();
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },

>>>>>>> 17a011c173a2b49e786808ab48e6c0ee057677a0
      body: jsonEncode({'responsibility': responsibility}),
    );

    return response.statusCode == 200;
  }

  static Future<bool> removeMember(String clubId, String email) async {
    final url = ClubMembers.removeMember(clubId, email);
<<<<<<< HEAD
    final response = await http.delete(Uri.parse(url));
    return response.statusCode == 200;
  }
}
=======
    String token = await getAccessToken();
    final response = await http.delete(Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
    }
    );
    return response.statusCode == 200;
  }
}
>>>>>>> 17a011c173a2b49e786808ab48e6c0ee057677a0
