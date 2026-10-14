import 'package:flutter/material.dart';
import 'agentes.dart';
import 'contrato.dart';
import 'esquadrao.dart';
import 'missao.dart';

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agencia de Herois')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, size: 90),
            const SizedBox(height: 20),
            const Text('Central de Herois', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            botao(context, 'Agentes', const Agentes()),
            botao(context, 'Contrato Diário', const Contrato()),
            botao(context, 'Meu Esquadrão', const Esquadrao()),
            botao(context, 'Missões', const Missao()),
          ],
        ),
      ),
    );
  }

  Widget botao(BuildContext context, String texto, Widget tela) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => tela)),
          child: Padding(padding: const EdgeInsets.all(14), child: Text(texto)),
        ),
      ),
    );
  }
}
