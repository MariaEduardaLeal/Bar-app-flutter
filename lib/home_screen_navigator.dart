import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'waiter_dashboard_screen.dart'; // Ainda vamos criar este arquivo
import 'manager_dashboard_screen.dart'; // Ainda vamos criar este arquivo
import 'kitchen_dashboard_screen.dart'; // Ainda vamos criar este arquivo
import 'auth_login_screen.dart';

class HomeScreenNavigator extends StatelessWidget {
  const HomeScreenNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (appState.currentUser == null) {
      return const AuthLoginScreen();
    }

    // Navega para o dashboard correto com base no perfil do usuário
    switch (appState.currentUser!.role) {
      case 'waiter':
        return const WaiterDashboardScreen();
      case 'kitchen':
        return const KitchenDashboardScreen();
      case 'manager':
        return const ManagerDashboardScreen();
      default:
        // Caso o perfil seja desconhecido, volta para a tela de login
        appState.logout();
        return const AuthLoginScreen();
    }
  }
}
