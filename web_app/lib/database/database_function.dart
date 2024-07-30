import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_app/database/database_classes.dart';

/*A classe APIService tem todos os metodos que servem para fazer as alterações na BD*/
class ApiService {
  final String baseUrl = "http://83.212.126.14:8000";

  /*Funções CRUD do cuidador*/
  /*Cria um cuidador na BD*/
  Future<Cuidador> createCuidador(Cuidador cuidador) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cuidadores/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(cuidador.toJson()),
    );

    if (response.statusCode == 200) {
      return Cuidador.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create cuidador');
    }
  }

  /*Procura um cuidador na BD pelo seu ID*/
  Future<Cuidador> fetchCuidador(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/cuidadores/$id'));

    if (response.statusCode == 200) {
      return Cuidador.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to fetch cuidador');
    }
  }

  /*Atualiza os dados de um cuidador na BD pelo seu ID*/
  Future<Cuidador> updateCuidador(int id, Cuidador cuidador) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cuidadores/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(cuidador.toJson()),
    );

    if (response.statusCode == 200) {
      return Cuidador.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update cuidador');
    }
  }

  /*Apaga um cuidador na BD pelo seu ID*/
  Future<void> deleteCuidador(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/cuidadores/$id'));

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to delete cuidador');
    }
  }

  /*Funções CRUD da mensagem*/
  /*Cria uma mensagem na BD*/
  Future<Mensagem> createMensagem(Mensagem mensagem) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mensagens/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(mensagem.toJson()),
    );

    if (response.statusCode == 200) {
      return Mensagem.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create mensagem');
    }
  }

  /*Procura uma mensagem na BD pelo seu ID*/
  Future<Mensagem> fetchMensagem(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/mensagens/$id'));

    if (response.statusCode == 200) {
      return Mensagem.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to fetch mensagem');
    }
  }

  /*Atualiza os dados uma mensagem na BD pelo seu ID*/
  Future<Mensagem> updateMensagem(int id, Mensagem mensagem) async {
    final response = await http.put(
      Uri.parse('$baseUrl/mensagens/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(mensagem.toJson()),
    );

    if (response.statusCode == 200) {
      return Mensagem.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update mensagem');
    }
  }

  /*Apaga uma mensagem na BD pelo seu ID*/
  Future<void> deleteMensagem(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/mensagens/$id'));

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to delete mensagem');
    }
  }

  /*Funções CRUD do paciente*/
  /*Cria um paciente na BD*/
  Future<Paciente> createPaciente(Paciente paciente) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pacientes/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(paciente.toJson()),
    );

    if (response.statusCode == 200) {
      return Paciente.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create paciente');
    }
  }

  /*Procura um paciente na BD pelo seu ID*/
  Future<Paciente> fetchPaciente(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/pacientes/$id'));

    if (response.statusCode == 200) {
      return Paciente.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to fetch paciente');
    }
  }

  /*Atualiza os dados um paciente na BD pelo seu ID*/
  Future<Paciente> updatePaciente(int id, Paciente paciente) async {
    final response = await http.put(
      Uri.parse('$baseUrl/pacientes/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(paciente.toJson()),
    );

    if (response.statusCode == 200) {
      return Paciente.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update paciente');
    }
  }

  /*Apaga um paciente na BD pelo seu ID*/
  Future<void> deletePaciente(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/pacientes/$id'));

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to delete paciente');
    }
  }

  /*Funções CRUD do paciente*/
  /*Cria um sensor na BD*/
  Future<Sensor> createSensor(Sensor sensor) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sensores/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(sensor.toJson()),
    );

    if (response.statusCode == 200) {
      return Sensor.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create sensor');
    }
  }

  /*Procura um sensor na BD pelo seu ID*/
  Future<Sensor> fetchSensor(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/sensores/$id'));

    if (response.statusCode == 200) {
      return Sensor.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to fetch sensor');
    }
  }

  /*Atualiza os dados um sensor na BD pelo seu ID*/
  Future<Sensor> updateSensor(int id, Sensor sensor) async {
    final response = await http.put(
      Uri.parse('$baseUrl/sensores/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(sensor.toJson()),
    );

    if (response.statusCode == 200) {
      return Sensor.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update sensor');
    }
  }


  /*Apaga um sensor na BD pelo seu ID*/
  Future<void> deleteSensor(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/sensores/$id'));

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to delete sensor');
    }
  }
}
