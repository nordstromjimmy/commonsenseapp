import 'package:commonsense_app/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fact.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class FactsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Fact> facts = [];
  List<Category> categories = [];
  int? selectedCategoryId;
  String language = 'en';
  bool isLoading = false;
  bool hasMore = true;
  int _offset = 0;
  static const int _pageSize = 20;

  AppStrings strings = AppStrings.en;

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('user_language') ?? 'English';
    language = lang == 'Swedish' ? 'sv' : 'en';
    strings = AppStrings.of(language);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    language = lang == 'Swedish' ? 'sv' : 'en';
    strings = AppStrings.of(language);
    await loadInitial();
  }

  Future<void> loadInitial() async {
    isLoading = true;
    _offset = 0;
    hasMore = true;
    notifyListeners();

    try {
      categories = await _api.getCategories(lang: language);
    } catch (e) {
      print('Categories error: $e');
    }

    try {
      if (selectedCategoryId == null) {
        facts = await _api.getRandomFacts(count: 1000, lang: language);
        hasMore = false;
      } else {
        facts = await _api.getFacts(
          limit: _pageSize,
          offset: 0,
          categoryId: selectedCategoryId,
          lang: language,
        );
        _offset = facts.length;
        hasMore = facts.length == _pageSize;
      }
    } catch (e) {
      print('Facts error: $e');
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
        lang: language,
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

  Future<void> retry() async {
    await loadInitial();
  }
}
