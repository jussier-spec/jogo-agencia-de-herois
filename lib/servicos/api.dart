import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/heroi.dart';

class ApiService {
  // Emulador Android: 10.0.2.2 aponta para o computador.
  // Se usar celular físico, troque pelo IP do computador, por exemplo 192.168.1.10.
  static const String baseUrl = 'http://192.168.1.7:3000';

  Future<List<Heroi>> buscarTodos() async {
    final resposta = await http.get(Uri.parse('$baseUrl/heroes'));
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao acessar a API');
    }

    final lista = jsonDecode(resposta.body) as List;
    return lista
        .map((item) => Heroi.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
