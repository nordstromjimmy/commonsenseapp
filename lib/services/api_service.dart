import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fact.dart';
import '../models/category.dart';

class ApiService {
  static const String baseUrl = 'http://217.154.222.105/api';

  Future<List<Fact>> getFacts({
    int limit = 20,
    int offset = 0,
    int? categoryId,
  }) async {
    String url = '$baseUrl/facts?limit=$limit&offset=$offset';
    if (categoryId != null) url += '&category_id=$categoryId';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Fact.fromJson(e)).toList();
    }
    throw Exception('Failed to load facts');
  }

  Future<List<Fact>> getRandomFacts({int count = 10, int? categoryId}) async {
    String url = '$baseUrl/facts/random?count=$count';
    if (categoryId != null) url += '&category_id=$categoryId';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Fact.fromJson(e)).toList();
    }
    throw Exception('Failed to load random facts');
  }

  Future<List<Category>> getCategories() async {
    final res = await http.get(Uri.parse('$baseUrl/categories'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Category.fromJson(e)).toList();
    }
    throw Exception('Failed to load categories');
  }
}
