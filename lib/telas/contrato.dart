import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/heroi.dart';
import '../servicos/api.dart';
import '../servicos/banco.dart';

class Contrato extends StatefulWidget {
  const Contrato({super.key});
  @override
  State<Contrato> createState() => _ContratoState();
}

class _ContratoState extends State<Contrato> {
  List<Heroi> contratos = [];
  bool carregando = true;
  String erro = '';
  final banco = Banco();

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final hoje = DateTime.now()
          .toIso8601String()
          .substring(0, 10);

      final ultimaData = prefs.getString('data_contrato');

      // Verifica quantos contratos já existem
      final quantidade = await banco.quantidadeContratos();

      // PRIMEIRO SORTEIO
      if (quantidade == 0) {
        await _sortearCinco();

        await prefs.setString(
          'data_contrato',
          hoje,
        );
      }

      // SORTEIO DOS PRÓXIMOS DIAS
      else if (ultimaData != hoje) {
        await _sortearUm();

        await prefs.setString(
          'data_contrato',
          hoje,
        );
      }

      await _carregarContratos();
    } catch (e) {
      erro = 'Não foi possível carregar os contratos.';
    }

    if (mounted) {
      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> _sortearCinco() async {
    List<Heroi> herois = await banco.listarHerois();

    // Se o banco estiver vazio, busca na API
    if (herois.isEmpty) {
      final dados = await ApiService().buscarTodos();

      await banco.salvarHerois(dados);

      herois = await banco.listarHerois();
    }

    if (herois.length < 5) {
      throw Exception('Não existem 5 heróis disponíveis.');
    }

    // Embaralha os heróis
    herois.shuffle();

    // Pega os 5 primeiros
    for (int i = 0; i < 5; i++) {
      await banco.salvarContrato(herois[i].id);
    }
  }

  Future<void> _sortearUm() async {
    final todos = await banco.listarHerois();

    final idsSorteados = await banco.listarIdsContratos();

    // Retira os heróis que já foram sorteados
    final disponiveis = todos.where((heroi) {
      return !idsSorteados.contains(heroi.id);
    }).toList();

    // Não existem mais heróis para sortear
    if (disponiveis.isEmpty) {
      return;
    }

    final random = Random();

    final posicao = random.nextInt(
      disponiveis.length,
    );

    final novoHeroi = disponiveis[posicao];

    await banco.salvarContrato(novoHeroi.id);
  }

  Future<void> _carregarContratos() async {
    final ids = await banco.listarIdsContratos();

    final lista = <Heroi>[];

    for (final id in ids) {
      final heroi = await banco.buscarHeroi(id);

      if (heroi != null) {
        lista.add(heroi);
      }
    }

    setState(() {
      contratos = lista;
    });
  }

  Future<void> _recrutar(Heroi heroi) async {
    final quantidade = await banco.quantidadeEsquadrao();

    if (quantidade >= 15) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Esquadrão cheio: máximo 15 agentes.',
            ),
          ),
        );
      }

      return;
    }

    if (await banco.estaNoEsquadrao(heroi.id)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Esse agente já está no esquadrão.',
            ),
          ),
        );
      }

      return;
    }

    await banco.salvarNoEsquadrao(heroi.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agente recrutado!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contrato Diário')),
      body: carregando
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : erro.isNotEmpty
            ? Center(
                child: Text(erro),
              )
            : contratos.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum contrato disponível.',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: contratos.length,
                    itemBuilder: (context, index) {
                      final heroi = contratos[index];

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 20,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                heroi.name,
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 15),

                              CachedNetworkImage(
                                imageUrl: heroi.imageLg,
                                height: 250,
                                errorWidget: (
                                  _,
                                  __,
                                  ___,
                                ) {
                                  return const Icon(
                                    Icons.person,
                                    size: 100,
                                  );
                                },
                              ),

                              const SizedBox(height: 15),

                              Text(
                                'Força: ${heroi.poder('strength')}',
                              ),

                              Text(
                                'Velocidade: ${heroi.poder('speed')}',
                              ),

                              Text(
                                'Combate: ${heroi.poder('combat')}',
                              ),

                              const SizedBox(height: 20),

                              ElevatedButton(
                                onPressed: () {
                                  _recrutar(heroi);
                                },
                                child: const Text(
                                  'Recrutar para o Esquadrão',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
    );
  }
}
