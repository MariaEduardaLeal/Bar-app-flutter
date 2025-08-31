// lib/models.dart
import 'dart:convert';
import 'package:flutter/material.dart';

class Employee {
  final int id;
  final String username;
  final String role; // 'manager', 'waiter', 'kitchen'
  final String name;

  Employee({
    required this.id,
    required this.username,
    required this.role,
    required this.name,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      username: json['username'] as String,
      role: json['role'] as String,
      name: json['name'] as String,
    );
  }
}


class RestaurantTable {
  final int id;
  final int number;
  final String status;
  final int? capacity; // Changed to nullable

  RestaurantTable({required this.id, required this.number, required this.status, this.capacity}); 

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'] as int,
      number: json['number'] as int,
      status: json['status'] as String,
      capacity: json['capacity'] as int?, // This is now correct
    );
  }
}

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category; // 'food', 'drink', 'dessert'

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
            price: json['price'] is String
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price'] as num).toDouble(),
      image: (json['image'] as String?) ?? 'https://via.placeholder.com/150',
      category: json['category'] as String,
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class Order {
  final int id;
  final int waiterId;
  final int? tableId;
  final List<OrderItem> items;
  final String status; // 'pending', 'preparing', 'ready', 'delivered'
  final DateTime timestamp;

  Order({
    required this.id,
    required this.waiterId,
    this.tableId,
    required this.items,
    required this.status,
    required this.timestamp,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'] as List<dynamic>;
    return Order(
      id: json['id'] as int,
      waiterId: json['waiter_id'] as int,
      tableId: json['table_id'] as int?,
      items: itemsJson.map((itemJson) => OrderItem.fromJson(itemJson as Map<String, dynamic>)).toList(),
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final Product product;
  final int quantity;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.product,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }
}