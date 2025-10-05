import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ProductProvider with ChangeNotifier {
  List<String> _categories = [];
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<String> get categories => _categories;
  List<dynamic> get products => _products;
  List<dynamic> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  final Dio _dio = Dio();

  Future<void> fetchCategories() async {
    try {
      final response = await _dio.get(
        'https://dummyjson.com/products/category-list',
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final List<String> fetchedCategories = List<String>.from(data as List);
        _categories = ['All', ...fetchedCategories];
        notifyListeners();
      }
    } on DioException {
      rethrow;
    }
  }

  Future<void> fetchProducts({String? category}) async {
    _isLoading = true;
    notifyListeners();

    _selectedCategory = category ?? 'All';
    List<dynamic> newProducts = [];

    try {
      final url = _selectedCategory == 'All'
          ? 'https://dummyjson.com/products'
          : 'https://dummyjson.com/products/category/$_selectedCategory';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        newProducts = response.data['products'];
      }
    } on DioException {
      rethrow;
    } finally {
      _products = newProducts;
      _filterProducts();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _filterProducts();
    notifyListeners();
  }

  void _filterProducts() {
    if (_searchQuery.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products.where((product) {
        return product['title'].toLowerCase().contains(_searchQuery);
      }).toList();
    }
  }
}
