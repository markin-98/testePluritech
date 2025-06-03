// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/animal_model.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:3000';
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<Animal>> getAnimais() async {
    final response = await http.get(Uri.parse('$_baseUrl/animais'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      List<Animal> animais = body
          .map((dynamic item) => Animal.fromJson(item))
          .toList();
      return animais;
    } else {
      print('Falaha ao carregar animais: ${response.statusCode} ${response.body}');
      throw Exception('Falha ao carregar animais');
    }
  }

  Future<Animal> addAnimal(Animal animal) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/animais'),
      headers: _headers,
      body: jsonEncode(animal.toJson()),
    );

    if (response.statusCode == 201) {
      return Animal.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('Falha ao adicionar animal: ${response.statusCode} ${response.body}');
      throw Exception('Falha ao adicionar animal.');
    }
  }

  Future<Animal> updateAnimal(int id, Animal animal) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/animais/$id'),
      headers: _headers,
      body: jsonEncode(animal.toJson()),
    );

    if (response.statusCode == 200) {
      return Animal.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('Falha ao atualizar animal: ${response.statusCode} ${response.body}');
      throw Exception('Falha ao atualizar animal');
    }
  }

  Future<void> deleteAnimal(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/animais/$id'));

    if (response.statusCode == 204) {
      return; 
    } else {
      print('Falha ao excluir animal: ${response.statusCode} ${response.body}');
      throw Exception('Falha ao excluir animal');
    }
  }
}
