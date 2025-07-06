import 'package:flutter/material.dart';

class DashboardDistribuidor extends StatefulWidget {
  const DashboardDistribuidor({super.key});

  @override
  State<DashboardDistribuidor> createState() => _DashboardDistribuidorState();
}

class _DashboardDistribuidorState extends State<DashboardDistribuidor> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Vista Distribuidor',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}