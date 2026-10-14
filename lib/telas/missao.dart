import 'dart:math';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/heroi.dart';
import '../servicos/banco.dart';

class Missao extends StatefulWidget {
  const Missao({super.key});
  @override
  State<Missao> createState() => _MissaoState();
}

class _MissaoState extends State<Missao> {
  final banco = Banco();
  final random = Random();
  List<Heroi> esquadrao = [];
  List<Heroi> todos = [];
  Set<int> usados = {};
  Heroi? inimigo;
  String atributo = '';
  int round = 0;
  int totalRounds = 0;
  int vitorias = 0;
  int derrotas = 0;
  int empates = 0;
  bool iniciou = false;
  bool processando = false;
  String mensagem = '';

  final atributos = ['intelligence', 'strength', 'speed', 'durability', 'power', 'combat'];

  Future<void> iniciar() async {
    esquadrao = await banco.listarEsquadrao();
    todos = await banco.listarHerois();
    if (esquadrao.length < 5) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('É preciso ter pelo menos 5 agentes.')));
      return;
    }
    totalRounds = 3 + random.nextInt(3);
    vitorias = derrotas = empates = 0;
    round = 1;
    usados = {};
    iniciou = true;
    _novoRound();
    setState(() {});
  }

  void _novoRound() {
    final disponiveis = todos.where((h) => !esquadrao.any((e) => e.id == h.id)).toList();
    inimigo = disponiveis[random.nextInt(disponiveis.length)];
    atributo = atributos[random.nextInt(atributos.length)];
    mensagem = '';
  }

  Future<void> escolher(Heroi jogador) async {
    if (processando || usados.contains(jogador.id)) return;
    processando = true;
    usados.add(jogador.id);
    final meuValor = jogador.poder(atributo);
    final inimigoValor = inimigo!.poder(atributo);
    String resultado;
    if (meuValor > inimigoValor) {
      vitorias++;
      resultado = 'Vitória! $meuValor x $inimigoValor';
    } else if (meuValor < inimigoValor) {
      derrotas++;
      resultado = 'Derrota! $meuValor x $inimigoValor';
    } else {
      empates++;
      resultado = 'Empate! $meuValor x $inimigoValor';
    }
    if (mounted) {
      setState(() => mensagem = resultado);
      await Future.delayed(const Duration(milliseconds: 800));
    }
    if (round >= totalRounds) {
      await _fimDaMissao();
    } else {
      round++;
      _novoRound();
      processando = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _fimDaMissao() async {
    final ganhou = vitorias > totalRounds / 2;
    Heroi? premiado;
    if (ganhou) {
      final participantes = esquadrao.where((h) => usados.contains(h.id)).toList();
      if (participantes.isNotEmpty) {
        premiado = participantes[random.nextInt(participantes.length)];
        final atributoPremio = atributos[random.nextInt(atributos.length)];
        final atual = premiado.poder(atributoPremio);
        premiado.powerstats[atributoPremio] = min(100, atual + 1);
        await banco.atualizarHeroi(premiado);
      }
    }
    processando = false;
    if (!mounted) return;
    AwesomeDialog(
      context: context,
      dialogType: ganhou ? DialogType.success : DialogType.error,
      title: ganhou ? 'Missão Cumprida!' : 'Operação Fracassada!',
      desc: 'Vitórias: $vitorias\nDerrotas: $derrotas\nEmpates: $empates${premiado == null ? '' : '\n\n${premiado.name} recebeu +1 em um atributo.'}',
      btnOkOnPress: () {
        setState(() => iniciou = false);
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    if (!iniciou) return _inicio();
    return _batalha();
  }

  Widget _inicio() {
    return Scaffold(
      appBar: AppBar(title: const Text('Missões')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sports_martial_arts, size: 80),
              const SizedBox(height: 20),
              const Text('Desafio de Crise', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Tenha pelo menos 5 agentes para iniciar.'),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: iniciar, child: const Text('Iniciar Missão')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _batalha() {
    return Scaffold(
      appBar: AppBar(title: Text('Round $round de $totalRounds')),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          const Text('Inimigo da Rodada', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          CachedNetworkImage(imageUrl: inimigo!.imageSm, height: 150, errorWidget: (_, __, ___) => const Icon(Icons.person, size: 80)),
          Text(inimigo!.name, textAlign: TextAlign.center),
          const SizedBox(height: 15),
          Text('Atributo em disputa: $atributo', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (mensagem.isNotEmpty) Padding(padding: const EdgeInsets.all(10), child: Text(mensagem, textAlign: TextAlign.center)),
          const Divider(),
          const Text('Escolha um agente:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: esquadrao.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: .75),
            itemBuilder: (_, index) {
              final h = esquadrao[index];
              final usado = usados.contains(h.id);
              return Card(
                color: usado ? Colors.grey.shade300 : null,
                child: InkWell(
                  onTap: usado ? null : () => escolher(h),
                  child: Column(
                    children: [
                      Expanded(child: CachedNetworkImage(imageUrl: h.imageSm, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.person))),
                      Padding(padding: const EdgeInsets.all(3), child: Text(h.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
