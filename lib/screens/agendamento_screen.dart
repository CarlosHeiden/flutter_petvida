// lib/screens/agendamento_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_petvida/models/agendamento.dart';
import 'package:flutter_petvida/services/api_service.dart';

class AgendamentoScreen extends StatefulWidget {
  const AgendamentoScreen({super.key});

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  final TextEditingController _observacoesController = TextEditingController();

  // Dados de exemplo, você deverá buscar esses dados da sua API
  final List<String> _tiposDeServico = ['Banho', 'Tosa', 'Banho com Tosa'];
  final List<int> _animais = [1, 2, 3]; // IDs dos animais
  final List<int> _veterinarios = [1, 2, 3]; // IDs dos veterinários

  String? _servicoSelecionado;
  int? _animalSelecionado;
  int? _veterinarioSelecionado;
  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada,
    );
    if (picked != null && picked != _horaSelecionada) {
      setState(() {
        _horaSelecionada = picked;
      });
    }
  }

  Future<void> _submitAgendamento() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final agendamento = Agendamento(
        idAnimal: _animalSelecionado!,
        nomeAnimal: 'Animal $_animalSelecionado', // Substitua pelo nome real do animal
        idVeterinario: _veterinarioSelecionado,
        dataAgendamento: _dataSelecionada,
        horaAgendamento: '${_horaSelecionada.hour}:${_horaSelecionada.minute}',
        tipoServico: _servicoSelecionado!,
        observacoes: _observacoesController.text.isEmpty ? null : _observacoesController.text,
      );

      final success = await _apiService.createAgendamento(agendamento);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true); // Retorna true para a tela anterior
          // Mostrar SnackBar de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agendamento criado com sucesso!')),
          );
        } else {
          // Mostrar SnackBar de erro
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Falha ao criar agendamento.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo de seleção de animal
              DropdownButtonFormField<int>(
                value: _animalSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Animal',
                  border: OutlineInputBorder(),
                ),
                items: _animais.map((int id) {
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text('Animal ID: $id'), // Substitua por nome do animal
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _animalSelecionado = newValue;
                  });
                },
                validator: (value) => value == null ? 'Por favor, selecione um animal.' : null,
              ),
              const SizedBox(height: 16),
              // Campo de seleção de serviço
              DropdownButtonFormField<String>(
                value: _servicoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Serviço',
                  border: OutlineInputBorder(),
                ),
                items: _tiposDeServico.map((String servico) {
                  return DropdownMenuItem<String>(
                    value: servico,
                    child: Text(servico),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _servicoSelecionado = newValue;
                  });
                },
                validator: (value) => value == null ? 'Por favor, selecione um serviço.' : null,
              ),
              const SizedBox(height: 16),
              // Campo de seleção de veterinário
              DropdownButtonFormField<int>(
                value: _veterinarioSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Veterinário (opcional)',
                  border: OutlineInputBorder(),
                ),
                items: _veterinarios.map((int id) {
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text('Veterinário ID: $id'), // Substitua por nome do veterinário
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _veterinarioSelecionado = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Botão para selecionar a data
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  'Data: ${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year}',
                ),
                onPressed: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              // Botão para selecionar a hora
              ElevatedButton.icon(
                icon: const Icon(Icons.access_time),
                label: Text('Hora: ${_horaSelecionada.format(context)}'),
                onPressed: () => _selectTime(context),
              ),
              const SizedBox(height: 16),
              // Campo de observações
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              // Botão de confirmação
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitAgendamento,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Confirmar Agendamento'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}