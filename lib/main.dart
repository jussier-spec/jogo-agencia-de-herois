import 'package:flutter/material.dart';
import 'telas/inicio.dart';
import 'servicos/banco.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Banco().db;
  runApp(const Aplicativo());
}

class Aplicativo extends StatelessWidget {
  const Aplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agentes',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const Inicio(),
    );
  }
}
