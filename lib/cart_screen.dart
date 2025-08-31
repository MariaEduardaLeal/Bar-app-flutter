import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'models.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    if (appState.cart.isEmpty) {
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

    // Lógica corrigida para verificar se é pedido para levar
    final isTakeaway = appState.selectedTableId == null;
    final title = isTakeaway ? 'Carrinho (Pedido para Levar)' : 'Carrinho (Mesa ${appState.selectedTableId})';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: appState.cart.length,
              itemBuilder: (context, index) {
                final cartItem = appState.cart[index];
                return _buildCartItem(context, appState, cartItem);
              },
            ),
          ),
          _buildCartSummary(context, appState),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, AppState appState, CartItem item) {
    return Card(
      key: ValueKey(item.product.id), // Melhora performance em rebuilds
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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

  Widget _buildCartSummary(BuildContext context, AppState appState) {
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
              Text('R\$ ${appState.cartTotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Adiciona confirmação
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar Pedido?'),
                  content: const Text('Deseja finalizar o pedido?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        appState.placeOrder();
                        Navigator.pop(context); // Fecha dialog
                        Navigator.pop(context); // Volta da CartScreen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pedido enviado com sucesso!')),
                        );
                      },
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Finalizar Pedido', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}