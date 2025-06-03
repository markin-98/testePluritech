class Animal {
  final int? id;
  String nomeTutor;
  String contatoTutor;
  String especie;
  String raca;
  DateTime dataEntrada;
  DateTime? previsaoDataSaida;
  final int? diariasAteHoje;
  final int? diariasPrevistas;

  Animal({
    this.id,
    required this.nomeTutor,
    required this.contatoTutor,
    required this.especie,
    required this.raca,
    required this.dataEntrada,
    this.previsaoDataSaida,
    this.diariasAteHoje,
    this.diariasPrevistas,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomeTutor': nomeTutor,
      'contatoTutor': contatoTutor,
      'especie': especie,
      'raca': raca,
      'dataEntraga': dataEntrada.toIso8601String().substring(0, 10),
      'previsaoDataSaida': previsaoDataSaida?.toIso8601String().substring(
        0,
        10,
      ),
    };
  }

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as int?,
      nomeTutor: json['nomeTutor'] as String,
      contatoTutor: json['contatoTutor'] as String,
      especie: json['especie'] as String,
      raca: json['raca'] as String,
      dataEntrada: DateTime.parse(json['dataEntrada'] as String),
      previsaoDataSaida: json['previsaoDataSaida'] != null
          ? DateTime.parse(json['previsaoDataSaida'] as String)
          : null,
      diariasAteHoje: json['diariasAteHoje'] as int?,
      diariasPrevistas: json['diariasPrevistas'] as int?,
    );
  }
}
