import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../models/heroi.dart';
import '../servicos/api.dart';
import '../servicos/banco.dart';
import 'detalhes.dart';

class Agentes extends StatefulWidget {
  const Agentes({super.key});
  @override
  State<Agentes> createState() => _AgentesState();
}

class _AgentesState extends State<Agentes> {
  final banco = Banco();
  final api = ApiService();
  late final PagingController<int, Heroi> pagina;
  bool carregando = true;
  String mensagem = '';

  @override
  void initState() {
    super.initState();
    pagina = PagingController<int, Heroi>(
      getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (numero) => _buscarPagina(numero),
    );
    _sincronizar();
  }

  Future<void> _sincronizar() async {
    try {
      final online = await api.buscarTodos();
      await banco.salvarHerois(online);
      if (mounted) setState(() => mensagem = 'Dados atualizados pela API.');
    } catch (_) {
      if (mounted) setState(() => mensagem = 'Sem internet. Usando os dados salvos.');
    } finally {
      if (mounted) setState(() => carregando = false);
      pagina.refresh();
    }
  }

  Future<List<Heroi>> _buscarPagina(int numero) async {
    final todos = await banco.listarHerois();
    const tamanho = 20;
    final inicio = (numero - 1) * tamanho;
    if (inicio >= todos.length) return [];
    final fim = (inicio + tamanho < todos.length) ? inicio + tamanho : todos.length;
    return todos.sublist(inicio, fim);
  }

  @override
  void dispose() {
    pagina.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agentes')),
      body: Column(
        children: [
          if (carregando) const LinearProgressIndicator(),
          if (mensagem.isNotEmpty) Padding(padding: const EdgeInsets.all(8), child: Text(mensagem)),
          Expanded(
            child: PagingListener<int, Heroi>(
              controller: pagina,
              builder: (context, state, fetchNextPage) => PagedListView<int, Heroi>(
                state: state,
                fetchNextPage: fetchNextPage,
                builderDelegate: PagedChildBuilderDelegate<Heroi>(
                  itemBuilder: (context, heroi, index) => Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: heroi.imageSm,
                        width: 55,
                        height: 70,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Icon(Icons.person),
                      ),
                      title: Text(heroi.name),
                      subtitle: Text('Força: ${heroi.poder('strength')}  |  Inteligência: ${heroi.poder('intelligence')}'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Detalhes(heroi: heroi))),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
