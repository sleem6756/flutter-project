import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:routing/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();

  final List<String> _categories = [];
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this); // Initialize with 0
    _fetchCategories();
    _searchController.addListener(_filterProducts);
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _dio.get(
        'https://dummyjson.com/products/category-list',
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final List<String> fetchedCategories = List<String>.from(data as List);
        if (!mounted) return;
        setState(() {
          _categories.add('All');
          _categories.addAll(fetchedCategories);
          _tabController = TabController(
            length: _categories.length,
            vsync: this,
          );
        });
        _fetchProducts(); // Call fetchProducts after setting the state.
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    }
  }

  Future<void> _fetchProducts({String? category}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    _selectedCategory = category ?? 'All';
    List<dynamic> newProducts = [];

    try {
      final url = _selectedCategory == 'All'
          ? 'https://dummyjson.com/products'
          : 'https://dummyjson.com/products/category/$_selectedCategory';
      final response = await _dio.get(url);

      if (response.statusCode == 200 && mounted) {
        newProducts = response.data['products'];
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load products: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _products = newProducts;
          _filterProducts(); // Apply search filter to the new products
          _isLoading = false;
        });
      }
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(_products);
      } else {
        _filteredProducts = _products.where((product) {
          return product['title'].toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        bottom: _categories.isEmpty
            ? const PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: Center(child: CircularProgressIndicator()),
              )
            : TabBar(
                // This colon was missing
                controller: _tabController,
                isScrollable: true,
                tabs: _categories
                    .map((category) => Tab(text: category))
                    .toList(),
                onTap: (index) {
                  _fetchProducts(
                    category: _categories[index] == 'All'
                        ? null
                        : _categories[index],
                  );
                },
              ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? const Center(child: Text('No products found.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Card(
                        elevation: 4,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Image.network(
                                product['thumbnail'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                    ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ).copyWith(bottom: 8.0),
                              // child: Text('\$${product['price']}'),
                              child: Text('\$${product['price'].toString()}'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
