/*Classe do cuidador, converte os dados de/para JSON*/
class Cuidador {
  int id;
  String nome;
  String email;
  String password;
  String cargo;

  Cuidador(
      {required this.id,
      required this.nome,
      required this.email,
      required this.password,
      required this.cargo});
  factory Cuidador.fromJson(Map<String, dynamic> json) {
    return Cuidador(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      password: json['password'],
      cargo: json['cargo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'password': password,
      'cargo': cargo,
    };
  }
}

/*Classe da mensagem, converte os dados de/para JSON*/
class Mensagem {
  int id;
  int idCuidador;
  int idPaciente;
  String mensagem;

  Mensagem(
      {required this.id,
      required this.idCuidador,
      required this.idPaciente,
      required this.mensagem});

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      id: json['id'],
      idCuidador: json['id_cuidador'],
      idPaciente: json['id_paciente'],
      mensagem: json['mensagem'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_cuidador': idCuidador,
      'id_paciente': idPaciente,
      'mensagem': mensagem,
    };
  }
}

/*Classe do paciente, converte os dados de/para JSON*/
class Paciente {
  int id;
  int idCuidador;
  int idSensor;
  String codigo;
  String nome;
  DateTime dataDeNascimento;
  String genero;
  int altura;
  double peso;
  String condicao;
  String descricao;

  Paciente(
      {required this.id,
      required this.idCuidador,
      required this.idSensor,
      required this.codigo,
      required this.nome,
      required this.dataDeNascimento,
      required this.genero,
      required this.altura,
      required this.peso,
      required this.condicao,
      required this.descricao});

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'],
      idCuidador: json['id_cuidador'],
      idSensor: json['id_sensor'],
      codigo: json['codigo'],
      nome: json['nome'],
      dataDeNascimento: DateTime.parse(
          json['data_de_nascimento']), // Convertendo string para DateTime
      genero: json['genero'],
      altura: json['altura'],
      peso: json['peso'],
      condicao: json['condicao'],
      descricao: json['descricao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_cuidador': idCuidador,
      'id_sensor': idSensor,
      'codigo': codigo,
      'nome': nome,
      'data_de_nascimento': dataDeNascimento
          .toIso8601String(), // Convertendo DateTime para string
      'genero': genero,
      'altura': altura,
      'peso': peso,
      'condicao': condicao,
      'descricao': descricao,
    };
  }
}

/*Classe do sensor, converte os dados de/para JSON*/
class Sensor {
  int id;
  String macAdress;
  String dados;

  Sensor({required this.id, required this.macAdress, required this.dados});

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'],
      macAdress: json['mac_adress'],
      dados: json['dados'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mac_adress': macAdress,
      'dados': dados,
    };
  }
}
