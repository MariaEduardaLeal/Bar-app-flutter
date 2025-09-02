// lib/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'models.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoadingExistingOrder = false;

  @override
  void initState() {
    super.initState();
    // Verifica se a mesa já está ocupada e se há itens existentes para buscar
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.selectedTableId != null) {
        await appState.fetchOrderForTable(appState.selectedTableId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    final isTakeaway = appState.selectedTableId == null;
    final title = isTakeaway ? 'Carrinho (Pedido para Levar)' : 'Carrinho (Mesa ${appState.selectedTableId})';
    final hasExistingOrder = appState.existingOrderItems.isNotEmpty;
    final hasNewItems = appState.cart.isNotEmpty;

    if (!hasExistingOrder && !hasNewItems) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Carrinho'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: Theme.of(context).disabledColor),
              const SizedBox(height: 16),
              Text('Seu carrinho está vazio!', style: TextStyle(fontSize: 18, color: Theme.of(context).disabledColor)),
              const SizedBox(height: 8),
              Text('Adicione alguns itens do cardápio para começar.', style: TextStyle(color: Theme.of(context).disabledColor)),
            ],
          ),
        ),
      );
    }

    double total = appState.cartTotal + appState.existingOrderItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (hasNewItems) ...[
                  _buildSectionHeader('Itens do Pedido Atual'),
                  ...appState.cart.map((item) => _buildCartItem(context, appState, item, isEditable: true)).toList(),
                ],
                if (hasExistingOrder) ...[
                  if (hasNewItems) const Divider(height: 32),
                  _buildSectionHeader('Itens Já Pedidos'),
                  ...appState.existingOrderItems.map((item) => _buildExistingItem(item)).toList(),
                ],
              ],
            ),
          ),
          _buildCartSummary(context, appState, total),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, AppState appState, CartItem item, {bool isEditable = true}) {
    return Card(
      key: ValueKey(item.product.id),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                item.product.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 60),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'R\$ ${item.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 20),
                  onPressed: () => appState.updateCartQuantity(item.product, item.quantity - 1),
                ),
                Text(item.quantity.toString(), style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => appState.updateCartQuantity(item.product, item.quantity + 1),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => appState.removeFromCart(item.product),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExistingItem(OrderItem item) {
    return Card(
      key: ValueKey(item.product.id),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Colors.grey.withOpacity(0.2), // Cor mais escura para desabilitar
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                item.product.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 60),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white70),
                  ),
                  Text(
                    'R\$ ${item.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
            Text(
              '${item.quantity}x',
              style: const TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, AppState appState, double total) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total do Pedido:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('R\$ ${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            ],
          ),
          const SizedBox(height: 16),
          // Botão "Enviar para Cozinha"
          ElevatedButton(
            onPressed: () async {
              await appState.sendOrderToKitchen();
              Navigator.pop(context); // Volta da CartScreen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pedido enviado com sucesso!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Enviar para Cozinha', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 8),
          // Botão "Fechar Conta e Finalizar"
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar Fechamento de Conta?'),
                  content: const Text('Deseja fechar a conta e liberar a mesa?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await appState.closeAccountAndFinalizeOrder();
                        Navigator.pop(context); // Fecha dialog
                        Navigator.pop(context); // Volta da CartScreen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Conta fechada e mesa liberada!')),
                        );
                      },
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Fechar Conta e Finalizar', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}