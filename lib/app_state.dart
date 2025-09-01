// lib/app_state.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'models.dart';

class AppState with ChangeNotifier {
  final Dio _dio = Dio();
  // Altere este endereço IP para o endereço da sua máquina na rede local
  // final String _baseUrl = 'http://10.0.2.2:3000/api'; 
  final String _baseUrl = 'https://bar-flutter-app.onrender.com/api'; 

  Employee? _currentUser;
  bool _isLoading = false;
  String _error = '';
  int? _selectedTableId;
  List<RestaurantTable> _tables = [];
  List<Product> _products = [];
  final List<CartItem> _cart = [];
  List<Order> _orders = [];

  Employee? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get error => _error;
  int? get selectedTableId => _selectedTableId;
  List<RestaurantTable> get tables => _tables;
  List<Product> get products => _products;
  List<CartItem> get cart => _cart;
  List<Order> get orders => _orders;
  double get cartTotal => _cart.fold(0.0, (total, current) => total + (current.product.price * current.quantity));

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        _currentUser = Employee.fromJson(response.data);
      } else {
        _error = 'Usuário ou senha inválidos.';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        _error = e.response!.data['message'] ?? 'Erro no servidor.';
      } else {
        _error = 'Erro de conexão. Verifique sua rede.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _selectedTableId = null;
    clearCart();
    notifyListeners();
  }

  void selectTable(int? tableId) {
    _selectedTableId = tableId;
    notifyListeners();
  }

  Future<void> fetchTables() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _dio.get('$_baseUrl/tables');
      _tables = (response.data as List)
          .map((json) => RestaurantTable.fromJson(json))
          .toList();
      notifyListeners();
    } on DioException {
      _error = 'Erro ao carregar mesas.';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _dio.get('$_baseUrl/products');
      _products = (response.data as List)
          .map((json) => Product.fromJson(json))
          .toList();
      notifyListeners();
    } on DioException {
      _error = 'Erro ao carregar produtos.';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addToCart(Product product) {
    final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _cart[existingIndex].quantity++;
    } else {
      _cart.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cart.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void updateCartQuantity(Product product, int newQuantity) {
    final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      if (newQuantity <= 0) {
        _cart.removeAt(existingIndex);
      } else {
        _cart[existingIndex].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  Future<void> placeOrder() async {
    if (_cart.isEmpty) return;

    final orderData = {
      'tableId': _selectedTableId,
      'items': _cart.map((item) => {
        'productId': item.product.id,
        'quantity': item.quantity,
      }).toList(),
    };

    try {
      await _dio.post('$_baseUrl/orders', data: orderData);

      final tableIndex = _tables.indexWhere((table) => table.id == _selectedTableId);
      if (tableIndex >= 0) {
        _tables[tableIndex] = RestaurantTable(
          id: _tables[tableIndex].id,
          number: _tables[tableIndex].number,
          status: 'occupied',
          capacity: _tables[tableIndex].capacity,
        );
      }

      clearCart();
      _selectedTableId = null;
      notifyListeners();
    } on DioException {
      _error = 'Erro ao enviar pedido.';
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}