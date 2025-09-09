// lib/screens/agendamento_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_petvida/models/animal.dart';
import 'package:flutter_petvida/models/servicos.dart';
import 'package:flutter_petvida/services/api_service.dart';


class AgendamentoScreen extends StatefulWidget {
  const AgendamentoScreen({super.key});

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  // ... (variáveis e métodos) ...

  final ApiService _apiService = ApiService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Future<List<Animal>> _animaisFuture;
  late Future<List<Servicos>> _servicosFuture;

  int? _animalSelecionado;
  // ...

  @override
  void initState() {
    super.initState();
    // Use a nova função para obter os animais do cache
    _animaisFuture = _apiService.getMyAnimals();
    _servicosFuture = _apiService.getServicos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Agendamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            // ...
            children: [
              FutureBuilder<List<Animal>>(
                future: _animaisFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return const Text("Nenhum animal cadastrado.");
                    }
                    return DropdownButtonFormField<int>(
                      value: _animalSelecionado,
                      items: snapshot.data!.map((animal) {
                        return DropdownMenuItem<int>(
                          value: animal.id,
                          child: Text(animal.nome),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() { _animalSelecionado = newValue; });
                      },
                      validator: (value) => value == null ? 'Selecione um animal.' : null,
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              FutureBuilder<List<Servicos>>(
                future: _servicosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return const Text("Nenhum serviço disponível.");
                    }
                    return DropdownButtonFormField<int>(
                      items: snapshot.data!.map((servico) {
                        return DropdownMenuItem<int>(
                          value: servico.id,
                          child: Text(servico.nomeServico),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        // Implemente a lógica de seleção de serviço aqui
                      },
                      validator: (value) => value == null ? 'Selecione um serviço.' : null,
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              // ... (outros campos) ...
            ],
          ),
        ),
      ),
    );
  }
}