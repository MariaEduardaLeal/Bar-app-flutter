import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class KitchenDashboardScreen extends StatelessWidget {
  const KitchenDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Painel da Cozinha'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => appState.logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bem-vindo, ${user?.name ?? ''}!', textAlign: TextAlign.center),
            SizedBox(height: 8),
            Text('Em breve, o seu painel de pedidos estará aqui.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}


