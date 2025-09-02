import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'models.dart';

class KitchenDashboardScreen extends StatefulWidget {
  const KitchenDashboardScreen({Key? key}) : super(key: key);

  @override
  State<KitchenDashboardScreen> createState() => _KitchenDashboardScreenState();
}

class _KitchenDashboardScreenState extends State<KitchenDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).fetchKitchenOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final activeOrders = appState.orders;

    return Scaffold(
      appBar: AppBar(
        title: Text('Painel da Cozinha'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => appState.fetchKitchenOrders(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => appState.logout(),
          ),
        ],
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : activeOrders.isEmpty
          ? Center(
              child: Text(
                'Nenhum pedido ativo no momento.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: activeOrders.length,
              itemBuilder: (context, index) {
                final order = activeOrders[index];
                return _buildOrderCard(context, appState, order);
              },
            ),
    );
  }

  Widget _buildOrderCard(BuildContext context, AppState appState, Order order) {
    String title = order.tableId != null
        ? 'Mesa ${order.table?.number}'
        : 'Pedido para Levar';
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.hourglass_empty;
    String statusText = '';

    switch (order.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        statusText = 'Pendente';
        break;
      case 'preparing':
        statusColor = Colors.blue;
        statusIcon = Icons.kitchen;
        statusText = 'Em Preparo';
        break;
      case 'ready':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        statusText = 'Pronto para Servir';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.error_outline;
        statusText = 'Desconhecido';
        break;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Text(
                      '${item.quantity}x',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.product.name)),
                  ],
                ),
              ),
            ),
            const Divider(height: 16),
            _buildStatusChangeButtons(context, appState, order),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChangeButtons(
    BuildContext context,
    AppState appState,
    Order order,
  ) {
    final isPending = order.status == 'pending';
    final isPreparing = order.status == 'preparing';
    final isReady = order.status == 'ready';

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isPending)
          ElevatedButton.icon(
            onPressed: () => appState.updateOrderStatus(order.id, 'preparing'),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar Preparo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        const SizedBox(width: 8),
        if (isPreparing)
          ElevatedButton.icon(
            onPressed: () => appState.updateOrderStatus(order.id, 'ready'),
            icon: const Icon(Icons.done_all),
            label: const Text('Marcar como Pronto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }
}
