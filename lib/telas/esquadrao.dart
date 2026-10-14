import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/heroi.dart';
import '../servicos/banco.dart';
import 'meu_agente.dart';

class Esquadrao extends StatefulWidget {
  const Esquadrao({super.key});
  @override
  State<Esquadrao> createState() => _EsquadraoState();
}

class _EsquadraoState extends State<Esquadrao> {
  List<Heroi> lista = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    lista = await Banco().listarEsquadrao();
    if (mounted) setState(() => carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meu Esquadrão (${lista.length}/15)')),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : lista.isEmpty
              ? const Center(child: Text('Nenhum agente recrutado.'))
              : ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (_, index) {
                    final h = lista[index];
                    return Card(
                      child: ListTile(
                        leading: CachedNetworkImage(imageUrl: h.imageSm, width: 55, height: 65, fit: BoxFit.cover),
                        title: Text(h.name),
                        subtitle: Text('Maior atributo: ${_maior(h)}'),
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => MeuAgente(heroi: h)));
                          _carregar();
                        },
                      ),
                    );
                  },
                ),
    );
  }

  String _maior(Heroi h) {
    final nomes = ['intelligence', 'strength', 'speed', 'durability', 'power', 'combat'];
    nomes.sort((a, b) => h.poder(b).compareTo(h.poder(a)));
    return nomes.first;
  }
}
