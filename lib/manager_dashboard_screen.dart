import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Painel do Gerente'),
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
        child: Text('Bem-vindo, ${user?.name ?? ''}!\nEm breve, o seu painel de gerenciamento estará aqui.', textAlign: TextAlign.center),
      ),
    );
  }
}
