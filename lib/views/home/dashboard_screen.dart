import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../models/account_model.dart';
import '../../models/credit_request_model.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ApiService apiService;

  const DashboardScreen({super.key, required this.apiService});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = HomeViewModel(widget.apiService);
        vm.loadAllData();
        return vm;
      },
      child: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          final screens = [
            _buildHomeTab(context, vm),
            _buildSavingsTab(vm),
            _buildCreditsTab(vm),
            _buildProfileTab(context, vm),
          ];

          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: screens[_currentIndex],
            bottomNavigationBar: _buildBottomNav(vm),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav(HomeViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, 'Inicio', 0),
            _navItem(Icons.savings, 'Ahorros', 1),
            _navItem(Icons.credit_card, 'Créditos', 2),
            _navItem(Icons.person, 'Perfil', 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? CrediscotiaTheme.primary : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? CrediscotiaTheme.primary : Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ─── PESTAÑA INICIO ──────────────────────────────────────────
  Widget _buildHomeTab(BuildContext context, HomeViewModel vm) {
    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => vm.loadAllData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(vm),
            const SizedBox(height: 20),
            if (vm.savingsAccounts.isNotEmpty)
              _buildBalanceCard(vm.savingsAccounts.first),
            if (vm.savingsAccounts.length > 1)
              _buildOtherAccounts(vm),
            const SizedBox(height: 20),
            _buildMovementsSection(vm),
            const SizedBox(height: 20),
            _buildSolicitudesSection(context, vm),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(HomeViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [CrediscotiaTheme.primary, Color(0xFFCC0000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: CrediscotiaTheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Bienvenido!',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            vm.user?.nombreCompleto ?? 'Cargando...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Botón notificaciones
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined,
                                color: Colors.white),
                            onPressed: () {
                              _showNotifications(vm);
                            },
                          ),
                          if (vm.notifications.any((n) => !n.leida))
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.yellow,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () {
                          vm.logout();
                          widget.apiService.setToken(null);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LoginScreen(apiService: widget.apiService),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Indicador de error
              if (vm.errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vm.errorMessage,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(SavingsAccount account) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saldo disponible',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  account.codCuentaAhorro,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              account.saldoFormateado,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: CrediscotiaTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    Icons.upload,
                    'Depositar',
                    Colors.green,
                    () => _showOperacionDialog(true, account),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    Icons.download,
                    'Retirar',
                    CrediscotiaTheme.primary,
                    () => _showOperacionDialog(false, account),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherAccounts(HomeViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Otras cuentas',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ...vm.savingsAccounts.skip(1).map((acc) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(acc.codCuentaAhorro,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(acc.saldoFormateado,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CrediscotiaTheme.primary)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMovementsSection(HomeViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Últimos movimientos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: vm.movements.length > 5
                    ? () => _showAllMovements(vm)
                    : null,
                child: const Text('Ver todos'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...vm.movements.take(5).map((m) => _buildMovementItem(m)),
      ],
    );
  }

  Widget _buildMovementItem(Movement m) {
    final color = m.esIngreso ? Colors.green : Colors.red;
    final icon = m.esIngreso ? Icons.arrow_downward : Icons.arrow_upward;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.concepto ?? 'Movimiento',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    m.codOperacion,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              m.montoFormateado,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── MIS SOLICITUDES ──────────────────────────────────────────
  Widget _buildSolicitudesSection(BuildContext context, HomeViewModel vm) {
    if (vm.solicitudes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Solicitudes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () async {
                  await vm.loadSolicitudes();
                  if (context.mounted) {
                    _showTodasSolicitudes(vm);
                  }
                },
                child: const Text('Ver todas'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...vm.solicitudes.take(3).map((s) => _buildSolicitudItem(context, s)),
      ],
    );
  }

  Widget _buildSolicitudItem(BuildContext context, CreditRequest s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: InkWell(
        onTap: () => _showSolicitudDetalle(context, s),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: s.estadoColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(s.estadoIcon, color: s.estadoColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.numeroExpediente,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      'S/ ${s.montoSolicitado.toStringAsFixed(2)} · ${s.plazoMeses} meses',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: s.estadoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  s.estadoFormateado,
                  style: TextStyle(
                    color: s.estadoColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSolicitudDetalle(BuildContext context, CreditRequest s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(s.estadoIcon, color: s.estadoColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                s.numeroExpediente,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detalleRow('Estado', s.estadoFormateado, s.estadoColor),
              const SizedBox(height: 8),
              _detalleRow('Producto', s.producto ?? '---'),
              const SizedBox(height: 8),
              _detalleRow('Monto', 'S/ ${s.montoSolicitado.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _detalleRow('Plazo', '${s.plazoMeses} meses'),
              const SizedBox(height: 8),
              _detalleRow('TEA', '${s.tea.toStringAsFixed(2)}%'),
              const SizedBox(height: 8),
              _detalleRow('Garantía', s.garantia ?? '---'),
              const SizedBox(height: 8),
              _detalleRow('Destino', s.destinoCredito ?? '---'),
              const SizedBox(height: 8),
              _detalleRow('Tipo de negocio', s.tipoNegocio ?? '---'),
              const SizedBox(height: 8),
              _detalleRow('Nombre del negocio', s.nombreNegocio ?? '---'),
              if (s.antiguedadNegocioMeses != null) ...[
                const SizedBox(height: 8),
                _detalleRow('Antigüedad', '${s.antiguedadNegocioMeses} meses'),
              ],
              if (s.ingresosEstimados != null) ...[
                const SizedBox(height: 8),
                _detalleRow('Ingresos mensuales', 'S/ ${s.ingresosEstimados!.toStringAsFixed(2)}'),
              ],
              if (s.gastosMensuales != null) ...[
                const SizedBox(height: 8),
                _detalleRow('Gastos mensuales', 'S/ ${s.gastosMensuales!.toStringAsFixed(2)}'),
              ],
              if (s.telefono != null) ...[
                const SizedBox(height: 8),
                _detalleRow('Teléfono', s.telefono!),
              ],
              if (s.fechaSolicitud != null) ...[
                const SizedBox(height: 8),
                _detalleRow('Fecha', '${s.fechaSolicitud!.day}/${s.fechaSolicitud!.month}/${s.fechaSolicitud!.year}'),
              ],
              if (s.asesorAsignado != null) ...[
                const SizedBox(height: 8),
                _detalleRow('Asesor', s.asesorAsignado!),
              ],
              if (s.montoAprobado != null) ...[
                const SizedBox(height: 8),
                _detalleRow('Monto aprobado', 'S/ ${s.montoAprobado!.toStringAsFixed(2)}'),
              ],
              if (s.motivoRechazo != null) ...[
                const SizedBox(height: 8),
                _detalleRow('Motivo rechazo', s.motivoRechazo!, Colors.red),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _detalleRow(String label, String value, [Color? color]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  void _showTodasSolicitudes(HomeViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Mis Solicitudes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (vm.solicitudes.isEmpty)
              const Center(child: Text('No tienes solicitudes registradas'))
            else
              ...vm.solicitudes.map((s) => _buildSolicitudItem(context, s)),
          ],
        ),
      ),
    );
  }

  // ─── PESTAÑA AHORROS ─────────────────────────────────────────
  Widget _buildSavingsTab(HomeViewModel vm) {
    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: () => vm.loadAllData(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Cuentas de Ahorro',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...vm.savingsAccounts.map((acc) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(acc.codCuentaAhorro,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: CrediscotiaTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            acc.estado ?? 'ACTIVA',
                            style: const TextStyle(
                                color: CrediscotiaTheme.primary, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      acc.moneda ?? 'PEN',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      acc.saldoFormateado,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: CrediscotiaTheme.primary,
                      ),
                    ),
                    if (acc.tea != null)
                      Text(
                        'TEA: ${(acc.tea! * 100).toStringAsFixed(2)}%',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                  ],
                ),
              )),
          if (vm.savingsAccounts.isEmpty)
            const Center(
              child: Text('No tienes cuentas de ahorro',
                  style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  // ─── PESTAÑA CRÉDITOS ────────────────────────────────────────
  Widget _buildCreditsTab(HomeViewModel vm) {
    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: () => vm.loadAllData(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const Text(
                'Créditos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              InkWell(
                onTap: () => _showSolicitudCredito(vm),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: CrediscotiaTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 18, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Nuevo', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...vm.creditAccounts.map((cred) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cred.codCuentaCredito,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cred.diasMora > 0
                                ? Colors.red.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cred.diasMora > 0
                                ? '${cred.diasMora}d mora'
                                : 'AL DÍA',
                            style: TextStyle(
                              color: cred.diasMora > 0
                                  ? Colors.red
                                  : Colors.green,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(cred.producto ?? 'Crédito',
                        style: TextStyle(color: Colors.grey.shade500)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Saldo pendiente:',
                            style: TextStyle(color: Colors.grey)),
                        Text(
                          cred.saldoFormateado,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    if (cred.cuotasTotal != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cuotas: ${cred.cuotasPagadas ?? 0}/${cred.cuotasTotal}',
                              style: TextStyle(color: Colors.grey.shade500)),
                          TextButton(
                            onPressed: () =>
                                _showCronograma(vm, cred.codCuentaCredito),
                            child: const Text('Ver cronograma'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              )),
          if (vm.creditAccounts.isEmpty)
            const Center(
              child: Text('No tienes créditos activos',
                  style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  // ─── PESTAÑA PERFIL ──────────────────────────────────────────
  Widget _buildProfileTab(BuildContext context, HomeViewModel vm) {
    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: CrediscotiaTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            vm.user?.nombreCompleto ?? '---',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: CrediscotiaTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'DNI: ${vm.user?.numeroDocumento ?? "---"}',
              style: const TextStyle(color: CrediscotiaTheme.primary),
            ),
          ),
          const SizedBox(height: 30),
          _buildInfoRow(Icons.email_outlined, 'Email', vm.user?.email ?? '---'),
          _buildInfoRow(Icons.phone_outlined, 'Teléfono',
              vm.user?.telefono ?? '---'),
          _buildInfoRow(Icons.badge_outlined, 'Código Cliente',
              vm.user?.codCliente ?? '---'),
          const SizedBox(height: 30),
          // Estadísticas
          _buildStatsCard(vm),
          const SizedBox(height: 20),
          // Botón de tarjetas
          if (vm.cards.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildCardsSection(vm),
          ],
          const SizedBox(height: 30),
          // Botón salir
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                vm.logout();
                widget.apiService.setToken(null);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LoginScreen(apiService: widget.apiService),
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(HomeViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Cuentas', vm.savingsAccounts.length.toString(), Icons.savings),
          _statItem('Créditos', vm.creditAccounts.length.toString(), Icons.credit_card),
          _statItem('Tarjetas', vm.cards.length.toString(), Icons.credit_score),
          _statItem('Mov.', vm.movements.length.toString(), Icons.swap_horiz),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: CrediscotiaTheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
      ],
    );
  }

  Widget _buildCardsSection(HomeViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tus Tarjetas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...vm.cards.map((card) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CrediscotiaTheme.primary,
                    CrediscotiaTheme.primaryDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card.marca ?? 'TARJETA',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        card.marca?.toLowerCase() == 'visa'
                            ? Icons.credit_card
                            : Icons.credit_score,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    card.numeroEnmascarado,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Límite',
                              style: TextStyle(color: Colors.white70, fontSize: 11)),
                          Text(
                            'S/ ${(card.lineaCredito ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Utilizado',
                              style: TextStyle(color: Colors.white70, fontSize: 11)),
                          Text(
                            'S/ ${(card.saldoUtilizado ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ─── SOLICITUD DE CRÉDITO ─────────────────────────────────────
  void _showSolicitudCredito(HomeViewModel vm) {
    final montoController = TextEditingController();
    final plazoController = TextEditingController(text: '12');
    final tipoNegocioController = TextEditingController();
    final nombreNegocioController = TextEditingController();
    final antiguedadController = TextEditingController();
    final ingresosController = TextEditingController();
    final gastosController = TextEditingController();
    final telefonoController = TextEditingController();

    String productoSeleccionado = 'Credito Empresarial - Microempresa';
    String garantiaSeleccionada = 'sin_garantia';
    String destinoSeleccionado = 'Capital de trabajo: compra de mercaderia';
    double? teaSeleccionada;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nueva Solicitud de Crédito'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Completa los datos para solicitar un crédito.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                // Producto
                const Text('Producto:',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                const SizedBox(height: 8),
                _buildDestinoOption(
                    'Credito Empresarial - Microempresa', 'Crédito Empresarial — Microempresa',
                    productoSeleccionado, (v) {
                  setDialogState(() {
                    productoSeleccionado = v;
                    teaSeleccionada = v.contains('43.92') ? 43.92 : 40.92;
                  });
                }),
                _buildDestinoOption(
                    'Credito Empresarial - Pequeña Empresa', 'Crédito Empresarial — Pequeña Empresa',
                    productoSeleccionado, (v) {
                  setDialogState(() {
                    productoSeleccionado = v;
                    teaSeleccionada = v.contains('43.92') ? 43.92 : 40.92;
                  });
                }),
                const SizedBox(height: 16),
                // Monto solicitado
                TextField(
                  controller: montoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Monto solicitado (S/)',
                    prefixText: 'S/ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Plazo en meses
                TextField(
                  controller: plazoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Plazo (meses)',
                    hintText: 'Ej: 12, 24, 36',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // TEA y Cuota calculada
                if (teaSeleccionada != null &&
                    montoController.text.isNotEmpty &&
                    plazoController.text.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CrediscotiaTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TEA',
                                style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text('${teaSeleccionada!.toStringAsFixed(2)}%',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: CrediscotiaTheme.primary)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Cuota ref.',
                                style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(
                                'S/ ${_calcularCuota(double.tryParse(montoController.text) ?? 0, int.tryParse(plazoController.text) ?? 1, teaSeleccionada!).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: CrediscotiaTheme.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Garantía
                const Text('Garantía:',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                const SizedBox(height: 8),
                _buildDestinoOption(
                    'sin_garantia', 'Sin Garantía', garantiaSeleccionada,
                    (v) => setDialogState(() => garantiaSeleccionada = v)),
                _buildDestinoOption('prendaria', 'Prendaria', garantiaSeleccionada,
                    (v) => setDialogState(() => garantiaSeleccionada = v)),
                _buildDestinoOption(
                    'hipotecaria', 'Hipotecaria', garantiaSeleccionada,
                    (v) => setDialogState(() => garantiaSeleccionada = v)),
                const SizedBox(height: 16),
                // Destino del crédito
                TextField(
                  controller: TextEditingController(text: destinoSeleccionado),
                  onChanged: (v) => destinoSeleccionado = v,
                  decoration: InputDecoration(
                    labelText: 'Destino del crédito',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Tipo de negocio
                TextField(
                  controller: tipoNegocioController,
                  decoration: InputDecoration(
                    labelText: 'Tipo de negocio',
                    hintText: 'Ej: Bodega',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Nombre del negocio
                TextField(
                  controller: nombreNegocioController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del negocio',
                    hintText: 'Ej: Bodega Don Anaxi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Antigüedad
                TextField(
                  controller: antiguedadController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Antigüedad del negocio (meses)',
                    hintText: 'Ej: 48',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Ingresos mensuales
                TextField(
                  controller: ingresosController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Ingresos mensuales estimados (S/)',
                    prefixText: 'S/ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Gastos mensuales
                TextField(
                  controller: gastosController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Gastos mensuales (S/)',
                    prefixText: 'S/ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Teléfono
                TextField(
                  controller: telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Teléfono de contacto',
                    hintText: 'Ej: 964110201',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (vm.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(vm.errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                vm.clearError();
                Navigator.pop(ctx);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final monto = double.tryParse(montoController.text);
                final plazo = int.tryParse(plazoController.text);
                final antiguedad = int.tryParse(antiguedadController.text);
                final ingresos = double.tryParse(ingresosController.text);
                final gastos = double.tryParse(gastosController.text);
                final telefono = telefonoController.text.trim();
                final tipoNegocio = tipoNegocioController.text.trim();
                final nombreNegocio = nombreNegocioController.text.trim();

                if (monto == null || monto <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Ingresa un monto válido'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }
                if (plazo == null || plazo <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Ingresa un plazo válido'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }
                if (tipoNegocio.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Ingresa el tipo de negocio'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }
                if (nombreNegocio.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Ingresa el nombre del negocio'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }
                if (antiguedad == null || antiguedad <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Ingresa la antigüedad del negocio'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }
                if (ingresos == null || ingresos <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Ingresa los ingresos mensuales'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }
                if (gastos == null || gastos < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Ingresa los gastos mensuales'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }
                if (telefono.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Ingresa el teléfono de contacto'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }

                final tea = productoSeleccionado.contains('43.92') ? 43.92 : 40.92;

                final resultado = await vm.crearSolicitudCredito(
                  monto: monto,
                  plazoMeses: plazo,
                  producto: productoSeleccionado,
                  tea: tea,
                  garantia: garantiaSeleccionada,
                  destinoCredito: destinoSeleccionado,
                  tipoNegocio: tipoNegocio,
                  nombreNegocio: nombreNegocio,
                  antiguedadNegocioMeses: antiguedad,
                  ingresosEstimados: ingresos,
                  gastosMensuales: gastos,
                  telefono: telefono,
                );

                if (resultado != null && context.mounted) {
                  Navigator.pop(ctx);
                  final expediente = resultado['numero_expediente'] ?? '---';
                  showDialog(
                    context: context,
                    builder: (ctx2) => AlertDialog(
                      title: const Icon(Icons.check_circle,
                          color: Colors.green, size: 60),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('¡Solicitud Enviada!',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(
                            'Tu solicitud de crédito por S/ ${monto.toStringAsFixed(2)} '
                            'a $plazo meses ha sido registrada.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: CrediscotiaTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Text('N° de Expediente',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(expediente,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: CrediscotiaTheme.primary,
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Un asesor se comunicará contigo para continuar con el proceso.',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx2),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CrediscotiaTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Enviar Solicitud'),
            ),
          ],
        ),
      ),
    );
  }

  double _calcularCuota(double monto, int plazo, double tea) {
    if (monto <= 0 || plazo <= 0) return 0;
    final tem = pow(1 + tea / 100, 1 / 12) - 1;
    final cuota = monto *
        (tem * pow(1 + tem, plazo)) /
        (pow(1 + tem, plazo) - 1);
    return cuota;
  }

  Widget _buildDestinoOption(
      String value, String label, String selected, Function(String) onChanged) {
    final isSelected = selected == value;
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? CrediscotiaTheme.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 13, color: isSelected ? CrediscotiaTheme.primary : Colors.black87)),
          ],
        ),
      ),
    );
  }

  // ─── DIÁLOGOS ─────────────────────────────────────────────────
  void _showOperacionDialog(bool esDeposito, SavingsAccount account) {
    final montoController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(esDeposito ? 'Depositar' : 'Retirar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Cuenta: ${account.codCuentaAhorro}'),
            Text('Saldo: ${account.saldoFormateado}'),
            const SizedBox(height: 12),
            TextField(
              controller: montoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monto (S/)',
                prefixText: 'S/ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final monto = double.tryParse(montoController.text);
              if (monto == null || monto <= 0) return;

              Navigator.pop(ctx);
              final vm = context.read<HomeViewModel>();
              final exito = await vm.realizarOperacion(
                cuentaOrigen: account.codCuentaAhorro,
                tipo: esDeposito ? 'recarga' : 'transferencia',
                monto: monto,
              );
              if (exito && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${esDeposito ? "Depósito" : "Retiro"} registrado exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CrediscotiaTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showAllMovements(HomeViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Todos los movimientos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...vm.movements.map((m) => _buildMovementItem(m)),
          ],
        ),
      ),
    );
  }

  void _showNotifications(HomeViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Notificaciones',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${vm.notifications.length} total',
                    style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
            const SizedBox(height: 16),
            if (vm.notifications.isEmpty)
              const Center(child: Text('Sin notificaciones')),
            ...vm.notifications.map((n) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: n.leida ? Colors.white : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          n.leida ? Colors.grey.shade200 : Colors.blue.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.titulo,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      if (n.cuerpo != null) ...[
                        const SizedBox(height: 4),
                        Text(n.cuerpo!,
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showCronograma(HomeViewModel vm, String creditCode) {
    showDialog(
      context: context,
      builder: (ctx) {
        return FutureBuilder<List>(
          future: vm.loadInstallments(creditCode),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: Center(child: CircularProgressIndicator()),
              );
            }
            final cuotas = snapshot.data ?? [];
            return AlertDialog(
              title: Text('Cronograma - $creditCode'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: cuotas.length,
                  itemBuilder: (_, i) {
                    final c = cuotas[i] as Installment;
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: c.pagada
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        radius: 16,
                        child: Text('${c.nroCuota}',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  c.pagada ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      title: Text('Vence: ${c.fechaVencimiento}',
                          style: const TextStyle(fontSize: 13)),
                      subtitle: Text(c.montoFormateado,
                          style: const TextStyle(fontSize: 12)),
                      trailing: Text(
                        c.pagada ? 'PAGADA' : 'PENDIENTE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color:
                              c.pagada ? Colors.green : Colors.orange,
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}