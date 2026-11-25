import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/motorcycle.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class MotorcycleProvider extends ChangeNotifier {
  MotorcycleProvider({required this.database, required this.api});

  final DatabaseService database;
  final ApiService api;

  List<Motorcycle> motorcycles = [];
  Set<String> favoriteIds = {};
  String query = '';
  String selectedBrand = 'Semua';
  String selectedCategory = 'Semua';
  bool isLoading = false;
  String? loadError;

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();
    try {
      final raw = await rootBundle.loadString('assets/data/motorcycles.json');
      final decoded = jsonDecode(raw) as List<dynamic>;
      motorcycles = decoded
          .map((item) => Motorcycle.fromJson(item as Map<String, dynamic>))
          .toList();
      favoriteIds = await database.getFavoriteIds();
      loadError = null;
    } catch (error) {
      loadError = 'Katalog belum dapat dimuat: $error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Motorcycle> get filteredMotorcycles => motorcycles.where((motor) {
        final text = '${motor.brand} ${motor.name}'.toLowerCase();
        final matchesQuery = text.contains(query.trim().toLowerCase());
        final matchesBrand =
            selectedBrand == 'Semua' || motor.brand == selectedBrand;
        final matchesCategory =
            selectedCategory == 'Semua' || motor.category == selectedCategory;
        return matchesQuery && matchesBrand && matchesCategory;
      }).toList();

  List<Motorcycle> get favorites =>
      motorcycles.where((motor) => favoriteIds.contains(motor.id)).toList();

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void setBrand(String value) {
    selectedBrand = value;
    notifyListeners();
  }

  void setCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  void resetFilters() {
    query = '';
    selectedBrand = 'Semua';
    selectedCategory = 'Semua';
    notifyListeners();
  }

  Future<void> toggleFavorite(Motorcycle motor) async {
    final add = !favoriteIds.contains(motor.id);
    await database.setFavorite(motor.id, add);
    if (add) {
      favoriteIds.add(motor.id);
    } else {
      favoriteIds.remove(motor.id);
    }
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchApi(Motorcycle motor) async {
    final cached = await database.getApiCache(motor.id);
    if (cached != null) {
      return (jsonDecode(cached) as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }
    final result = await api.search(make: motor.brand, model: motor.name);
    await database.saveApiCache(motor.id, jsonEncode(result));
    return result;
  }
}
