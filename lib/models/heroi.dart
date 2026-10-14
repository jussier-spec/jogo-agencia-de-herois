class Heroi {
  int id;
  String name;
  String imageSm;
  String imageLg;
  Map<String, dynamic> powerstats;
  Map<String, dynamic> appearance;
  Map<String, dynamic> biography;
  Map<String, dynamic> work;
  Map<String, dynamic> connections;

  Heroi({
    required this.id,
    required this.name,
    required this.imageSm,
    required this.imageLg,
    required this.powerstats,
    required this.appearance,
    required this.biography,
    required this.work,
    required this.connections,
  });

  factory Heroi.fromJson(Map<String, dynamic> json) {
    final images = Map<String, dynamic>.from(json['images'] ?? {});
    return Heroi(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: '${json['name'] ?? 'Sem nome'}',
      imageSm: '${images['sm'] ?? ''}',
      imageLg: '${images['lg'] ?? images['md'] ?? images['sm'] ?? ''}',
      powerstats: Map<String, dynamic>.from(json['powerstats'] ?? {}),
      appearance: Map<String, dynamic>.from(json['appearance'] ?? {}),
      biography: Map<String, dynamic>.from(json['biography'] ?? {}),
      work: Map<String, dynamic>.from(json['work'] ?? {}),
      connections: Map<String, dynamic>.from(json['connections'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'images': {'sm': imageSm, 'lg': imageLg},
      'powerstats': powerstats,
      'appearance': appearance,
      'biography': biography,
      'work': work,
      'connections': connections,
    };
  }

  int poder(String nome) {
    final valor = int.tryParse('${powerstats[nome] ?? 0}') ?? 0;
    return valor < 0 ? 0 : valor;
  }
}
