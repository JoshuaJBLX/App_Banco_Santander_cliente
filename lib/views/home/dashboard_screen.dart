import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';  // ← Este ya está bien (relativo)

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inicio'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
            )
          ],
        ),
        body: Consumer<HomeViewModel>(
          builder: (context, vm, _) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, ${vm.user.name}!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    child: ListTile(
                      title: const Text('Cuenta de Ahorros'),
                      subtitle: Text('Saldo: S/ ${vm.savings.balance.toStringAsFixed(2)}'),
                      leading: const Icon(Icons.savings, color: CrediscotiaTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 4,
                    child: ListTile(
                      title: const Text('Tarjeta de Crédito'),
                      subtitle: Text('Deuda: S/ ${vm.creditCard.pendingAmount.toStringAsFixed(2)}'),
                      leading: const Icon(Icons.credit_card, color: CrediscotiaTheme.primary),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.home, color: CrediscotiaTheme.primary),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.account_balance),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.credit_card),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.person),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}