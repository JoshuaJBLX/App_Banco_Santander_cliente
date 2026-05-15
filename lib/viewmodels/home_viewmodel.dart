import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/account_model.dart';

class HomeViewModel extends ChangeNotifier {
  // Datos hardcodeados
  User user = User(name: 'Carlos Pérez', document: '12345678');
  SavingsAccount savings = SavingsAccount(balance: 12500.50);
  CreditCard creditCard = CreditCard(pendingAmount: 2340.00);

  void logout() {
    // Solo resetea estado
    notifyListeners();
  }
}