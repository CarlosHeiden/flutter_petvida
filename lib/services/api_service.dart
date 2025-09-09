// lib/services/api_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_petvida/models/agendamento.dart';
import 'package:flutter_petvida/models/animal.dart';
import 'package:flutter_petvida/models/servicos.dart';
import 'package:flutter_petvida/utils/constants.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: API_BASE_URL,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  // Método de login ajustado
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/login/',
        data: {'username': username, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final token = response.data['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);
        await prefs.setString(
          'currentUser',
          jsonEncode({
            'user_id': response.data['user_id'],
            'email': response.data['email'],
          }),
        );
        await prefs.setString(
          'userAnimals',
          jsonEncode(response.data['animais']),
        );
        return response.data;
      }
      return null;
    } on DioException {
      return null;
    }
  }

  // Método para obter os animais do usuário logado
  Future<List<Animal>> getMyAnimals() async {
    final prefs = await SharedPreferences.getInstance();
    final animalsJson = prefs.getString('userAnimals');
    if (animalsJson != null) {
      final List<dynamic> animalsList = jsonDecode(animalsJson);
      return animalsList.map((data) => Animal.fromJson(data)).toList();
    }
    return [];
  }

  // Método para buscar a lista de agendamentos
  Future<List<Agendamento>> getAgendamentos() async {
    final token = await getAuthToken();
    if (token == null) return [];

    try {
      final response = await _dio.get(
        '/agendamentos/',
        options: Options(headers: {'Authorization': 'Token $token'}),
      );
      return (response.data as List)
          .map((item) => Agendamento.fromJson(item))
          .toList();
    } on DioException {
      return [];
    }
  }

  // Método para buscar os serviços
  Future<List<Servicos>> getServicos() async {
    final token = await getAuthToken();
    if (token == null) return [];

    try {
      final response = await _dio.get(
        '/servicos/',
        options: Options(headers: {'Authorization': 'Token $token'}),
      );
      return (response.data as List)
          .map((item) => Servicos.fromJson(item))
          .toList();
    } on DioException {
      return [];
    }
  }

  // Método para criar um novo agendamento
  Future<bool> createAgendamento(Agendamento agendamento) async {
    final token = await getAuthToken();
    if (token == null) return false;

    try {
      await _dio.post(
        '/agendamentos/',
        data: agendamento.toJson(),
        options: Options(headers: {'Authorization': 'Token $token'}),
      );
      return true;
    } on DioException {
      return false;
    }
  }

  // Método para obter o token salvo
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Método para fazer logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }
}
