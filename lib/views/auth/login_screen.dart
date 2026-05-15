import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../home/dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Scaffold(
        body: Consumer<AuthViewModel>(
          builder: (context, authVM, _) {
            if (authVM.state == AuthState.success) {
              // Navegar al dashboard
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
                authVM.resetState();
              });
            }
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo temporal (si no tienes imagen, usa Icon)
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: CrediscotiaTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Crediscotia',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: CrediscotiaTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: userController,
                    decoration: const InputDecoration(
                      labelText: 'DNI / Usuario',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => authVM.login(userController.text, passController.text),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: authVM.state == AuthState.loading
                        ? const CircularProgressIndicator()
                        : const Text('Ingresar'),
                  ),
                  if (authVM.state == AuthState.error)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        authVM.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}