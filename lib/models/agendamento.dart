// lib/models/agendamento.dart
class Agendamento {
  final int idAnimal;
  final String nomeAnimal; // Adicione este campo para facilitar a exibição
  final int? idVeterinario;
  final DateTime dataAgendamento;
  final String horaAgendamento;
  final String tipoServico;
  final String? observacoes;

  Agendamento({
    required this.idAnimal,
    required this.nomeAnimal,
    this.idVeterinario,
    required this.dataAgendamento,
    required this.horaAgendamento,
    required this.tipoServico,
    this.observacoes,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      idAnimal: json['id_animal'],
      nomeAnimal: json['nome_animal'], // Supondo que a API Django retorne o nome do animal
      idVeterinario: json['id_veterinario'],
      dataAgendamento: DateTime.parse(json['data_agendamento']),
      horaAgendamento: json['hora_agendamento'],
      tipoServico: json['tipo_servico'],
      observacoes: json['observacoes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_animal': idAnimal,
      'id_veterinario': idVeterinario,
      'data_agendamento': dataAgendamento.toIso8601String().substring(0, 10), // Formato YYYY-MM-DD
      'hora_agendamento': horaAgendamento,
      'tipo_servico': tipoServico,
      'observacoes': observacoes,
    };
  }
}