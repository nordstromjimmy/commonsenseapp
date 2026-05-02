import 'package:flutter/material.dart';
import '../models/fact.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class FactsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Fact> facts = [];
  List<Category> categories = [];
  int? selectedCategoryId;
  bool isLoading = false;
  bool hasMore = true;
  int _offset = 0;
  static const int _pageSize = 20;

  Future<void> loadInitial() async {
    isLoading = true;
    _offset = 0;
    hasMore = true;
    notifyListeners();
    try {
      categories = await _api.getCategories();
      if (selectedCategoryId == null) {
        facts = await _api.getRandomFacts(count: _pageSize);
        hasMore = false;
      } else {
        facts = await _api.getFacts(
          limit: _pageSize,
          offset: 0,
          categoryId: selectedCategoryId,
        );
        _offset = facts.length;
        hasMore = facts.length == _pageSize;
      }
    } catch (e) {
      facts = [];
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    notifyListeners();
    try {
      final more = await _api.getFacts(
        limit: _pageSize,
        offset: _offset,
        categoryId: selectedCategoryId,
      );
      facts.addAll(more);
      _offset += more.length;
      hasMore = more.length == _pageSize;
    } catch (e) {}
    isLoading = false;
    notifyListeners();
  }

  Future<void> selectCategory(int? categoryId) async {
    selectedCategoryId = categoryId;
    await loadInitial();
  }

  Future<List<Fact>> getRandomFacts({int count = 10}) async {
    return await _api.getRandomFacts(
      count: count,
      categoryId: selectedCategoryId,
    );
  }
}
