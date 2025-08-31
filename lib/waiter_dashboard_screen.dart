import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'models.dart';
import 'menu_screen.dart';

class WaiterDashboardScreen extends StatefulWidget {
  const WaiterDashboardScreen({Key? key}) : super(key: key);

  @override
  State<WaiterDashboardScreen> createState() => _WaiterDashboardScreenState();
}

class _WaiterDashboardScreenState extends State<WaiterDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).fetchTables();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${user?.name ?? ''}!', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              appState.logout();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (appState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (appState.error.isNotEmpty)
                Center(child: Text(appState.error))
              else
                _buildTableGrid(context, appState.tables),
              _buildTakeawayButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableGrid(BuildContext context, List<RestaurantTable> tables) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 1.3,
        ),
        itemCount: tables.length,
        itemBuilder: (context, index) {
          final table = tables[index];
          final isAvailable = table.status == 'available';
          final color = isAvailable ? Colors.green.shade400 : Colors.red.shade400;
          final icon = isAvailable ? Icons.check_circle_outline : Icons.cancel_outlined;

          return InkWell(
            onTap: () {
              if (isAvailable) {
                appState.selectTable(table.id);
                appState.fetchProducts();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MenuScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mesa ocupada!')),
                );
              }
            },
            child: Card(
              color: color,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 36, color: Colors.white),
                    const SizedBox(height: 4),
                    Text(
                      'Mesa ${table.number}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAvailable ? 'Livre' : 'Ocupada',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTakeawayButton(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: ElevatedButton.icon(
        onPressed: () {
          appState.selectTable(null);
          appState.fetchProducts();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const MenuScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        label: const Text('Novo Pedido para Levar', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.takeout_dining),
      ),
    );
  }
}