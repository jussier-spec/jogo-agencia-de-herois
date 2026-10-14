import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import '../models/heroi.dart';

class Detalhes extends StatelessWidget {
  final Heroi heroi;
  const Detalhes({super.key, required this.heroi});

  @override
  Widget build(BuildContext context) {
    final atributos = ['intelligence', 'strength', 'speed', 'durability', 'power', 'combat'];
    return Scaffold(
      appBar: AppBar(title: Text(heroi.name)),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          CachedNetworkImage(
            imageUrl: heroi.imageLg,
            height: 280,
            fit: BoxFit.contain,
            errorWidget: (_, __, ___) => const Icon(Icons.person, size: 100),
          ),
          Text(heroi.name, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          const Text('Powerstats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ...atributos.map((nome) => _barra(nome, heroi.poder(nome))),
          const Divider(),
          _secao('Biografia', heroi.biography),
          _secao('Aparência', heroi.appearance),
          _secao('Trabalho', heroi.work),
          _secao('Conexões', heroi.connections),
        ],
      ),
    );
  }

  Widget _barra(String nome, int valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: PrimerProgressBar(
        maxTotalValue: 100,
        showLegend: true,
        segments: [Segment(value: valor, color: Colors.blue, label: Text(nome), valueLabel: Text('$valor'))],
      ),
    );
  }

  Widget _secao(String titulo, Map<String, dynamic> dados) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ...dados.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('${e.key}: ${e.value}'),
            )),
        const SizedBox(height: 12),
      ],
    );
  }
}
