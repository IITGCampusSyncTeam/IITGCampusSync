import 'dart:convert';
import 'package:frontend/constants/endpoints.dart';
import 'package:frontend/models/tag_model.dart';
import 'package:http/http.dart' as http;
//import 'package:flutter/material.dart';

class TagAPI {
  Future<List<Tag>> getAllTags() async {
    final url = ClubTag.getAvailableTags;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => Tag.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
