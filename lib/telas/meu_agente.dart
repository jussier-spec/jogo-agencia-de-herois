import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/heroi.dart';
import '../servicos/banco.dart';
import 'detalhes.dart';

class MeuAgente extends StatelessWidget {
  final Heroi heroi;
  const MeuAgente({super.key, required this.heroi});

  void _dispensar(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      title: 'Dispensar agente?',
      desc: 'Deseja retirar ${heroi.name} do esquadrão?',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        await Banco().removerDoEsquadrao(heroi.id);
        if (context.mounted) Navigator.pop(context);
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Agente')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(heroi.name, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          CachedNetworkImage(imageUrl: heroi.imageLg, height: 300, errorWidget: (_, __, ___) => const Icon(Icons.person, size: 100)),
          ...['intelligence', 'strength', 'speed', 'durability', 'power', 'combat'].map((p) => Text('$p: ${heroi.poder(p)}')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Detalhes(heroi: heroi))), child: const Text('Ver detalhes')),
          ElevatedButton(onPressed: () => _dispensar(context), child: const Text('Dispensar do Esquadrão')),
        ],
      ),
    );
  }
}
