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
  List<OrderItem> _existingOrderItems = []; // Nova variável de estado

  Employee? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get error => _error;
  int? get selectedTableId => _selectedTableId;
  List<RestaurantTable> get tables => _tables;
  List<Product> get products => _products;
  List<CartItem> get cart => _cart;
  List<Order> get orders => _orders;
  List<OrderItem> get existingOrderItems => _existingOrderItems;
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
    _existingOrderItems = [];
    notifyListeners();
  }

  void selectTable(int? tableId) {
    _selectedTableId = tableId;
    clearCart(); // Limpa o carrinho ao selecionar uma nova mesa
    _existingOrderItems = []; // Limpa os itens de pedidos anteriores
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

  Future<void> fetchOrderForTable(int tableId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      final response = await _dio.get('$_baseUrl/orders/by-table/$tableId');
      final order = Order.fromJson(response.data);
      _existingOrderItems = order.items;
      notifyListeners();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _existingOrderItems = [];
      } else {
        _error = 'Erro ao carregar pedido da mesa.';
      }
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

  Future<void> sendOrderToKitchen() async {
    if (_cart.isEmpty) return;

    final orderData = {
      'waiterId': _currentUser?.id,
      'tableId': _selectedTableId,
      'items': _cart.map((item) => {
        'productId': item.product.id,
        'quantity': item.quantity,
        'price': item.product.price,
      }).toList(),
    };

    try {
      await _dio.post('$_baseUrl/orders/send-to-kitchen', data: orderData);
      
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
      _existingOrderItems = [];
      notifyListeners();
    } on DioException {
      _error = 'Erro ao enviar pedido para cozinha.';
      notifyListeners();
    }
  }

  Future<void> closeAccountAndFinalizeOrder() async {
    try {
      // Envia os itens novos primeiro, se houver
      if (_cart.isNotEmpty) {
        final orderData = {
          'waiterId': _currentUser?.id,
          'tableId': _selectedTableId,
          'items': _cart.map((item) => {
            'productId': item.product.id,
            'quantity': item.quantity,
            'price': item.product.price,
          }).toList(),
        };
        await _dio.post('$_baseUrl/orders/send-to-kitchen', data: orderData);
      }

      // Obtém o ID do pedido (pode ser o que acabamos de criar ou o existente)
      // A chamada para `fetchOrderForTable` garante que `existingOrderItems` e `_selectedTableId` estão preenchidos.
      // Precisa de um endpoint para obter o orderId.
      final response = await _dio.get('$_baseUrl/waiter/orders/by-table/$_selectedTableId');
      final order = Order.fromJson(response.data);
      final orderId = order.id;

      // Fecha a conta
      await _dio.post('$_baseUrl/orders/close-account', data: {
        'orderId': orderId,
        'tableId': _selectedTableId,
      });

      final tableIndex = _tables.indexWhere((table) => table.id == _selectedTableId);
      if (tableIndex >= 0) {
        _tables[tableIndex] = RestaurantTable(
          id: _tables[tableIndex].id,
          number: _tables[tableIndex].number,
          status: 'available',
          capacity: _tables[tableIndex].capacity,
        );
      }
      
      _selectedTableId = null;
      clearCart();
      _existingOrderItems = [];
      notifyListeners();
    } on DioException {
      _error = 'Erro ao fechar a conta.';
      notifyListeners();
    }
  }

  Future<void> fetchKitchenOrders() async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      final response = await _dio.get('$_baseUrl/kitchen/orders');
      _orders = (response.data as List)
          .map((json) => Order.fromJson(json))
          .toList();
      notifyListeners();
    } on DioException {
      _error = 'Erro ao carregar pedidos da cozinha.';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      await _dio.patch('$_baseUrl/orders/$orderId/status', data: {
        'status': newStatus,
      });
      await fetchKitchenOrders(); // Atualiza a lista de pedidos após a mudança
    } on DioException {
      _error = 'Erro ao atualizar o status do pedido.';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}