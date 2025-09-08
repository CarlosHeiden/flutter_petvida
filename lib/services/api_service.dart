// lib/services/api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_petvida/models/agendamento.dart';
import 'package:flutter_petvida/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: API_BASE_URL,
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 3),
    ),
  );

  // Método para autenticação e obtenção do token
  Future<String?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/login/', // Rota de login no seu backend Django
        data: {
          'username': username,
          'password': password,
        },
      );

      final token = response.data['token']; // Supondo que a API retorne um JSON com a chave 'token'
      if (token != null) {
        // Salvar o token localmente para futuras requisições
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('authToken', token);
      }
      return token;
    } on DioException catch (e) {
      print('Erro de Login: ${e.response?.statusCode}');
      print('Detalhes do erro: ${e.response?.data}');
      return null;
    }
  }

  // Método para obter o token salvo
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Método para criar um novo agendamento
  Future<bool> createAgendamento(Agendamento agendamento) async {
    final token = await getAuthToken();
    if (token == null) {
      print('Token de autenticação não encontrado.');
      return false;
    }

    try {
      await _dio.post(
        '/agendamentos/', // Rota para criar agendamento no seu backend
        data: agendamento.toJson(),
        options: Options(
          headers: {'Authorization': 'Token $token'},
        ),
      );
      return true;
    } on DioException catch (e) {
      print('Erro ao criar agendamento: ${e.response?.statusCode}');
      print('Detalhes do erro: ${e.response?.data}');
      return false;
    }
  }

  // Método para buscar a lista de agendamentos
  Future<List<Agendamento>> getAgendamentos() async {
    final token = await getAuthToken();
    if (token == null) {
      print('Token de autenticação não encontrado.');
      return [];
    }
    
    try {
      final response = await _dio.get(
        '/agendamentos/', // Rota para listar agendamentos
        options: Options(
          headers: {'Authorization': 'Token $token'},
        ),
      );
      
      return (response.data as List)
          .map((item) => Agendamento.fromJson(item))
          .toList();
    } on DioException catch (e) {
      print('Erro ao buscar agendamentos: ${e.response?.statusCode}');
      print('Detalhes do erro: ${e.response?.data}');
      return [];
    }
  }

  // Método para fazer logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }
}