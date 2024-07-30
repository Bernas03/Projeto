import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_app/database/database_function.dart';
import 'database/database_classes.dart';
import 'dart:math';
import 'package:get/get.dart';

class Main_Page extends StatelessWidget {
  const Main_Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /*Ligação à BD para usar as funções CRUD*/
  final ApiService apiService = ApiService();

  /*Variaveis do cuidador logado*/
  int idLogado = 0;
  String nomeLogado = '';
  String cargoLogado = '';

  /*Controller que captura o codigo do textfield, variavel a que se atribui esse valor*/
  TextEditingController _controllerSensor = TextEditingController();
  String _sensor = '';

  /*Lista que vai conter todos os pacientes do cuidador logado*/
  List<Paciente> pacientesDoCuidador = [];

  /*Bool para ajudar na verificação dos valores da BD*/
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCuidadorData();
  }

  /*Vai buscar as informações do Cuidador logado à BD, usando o ID guardado no SharedPreferences*/
  Future<void> _loadCuidadorData() async {
    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      idLogado = _prefs.getInt('id_cuidador_logado') ?? 0;
      if (idLogado != 0) {
        Cuidador cuidadorLogado = await apiService.fetchCuidador(idLogado);
        List<Paciente> pacientes = await fetchPacientesDoCuidador(idLogado);
        setState(() {
          nomeLogado = cuidadorLogado.nome;
          cargoLogado = cuidadorLogado.cargo;
          pacientesDoCuidador = pacientes;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar os dados do cuidador: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  /*Função para exibir o diálogo de confirmação ao tentar sair da app*/
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Sair da aplicação?'),
            content:
                Text('Sair da aplicação implicará voltar a efetuar o login'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Não', style: TextStyle(color: Colors.blueAccent)),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                },
                child: Text('Sim', style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          ),
        )) ??
        false;
  }

  /*Função que recebe uma string e mostra uma caixa de mensagens com o texto da String recebida*/
  void mostrarPopup(BuildContext context, String mensagem,
      {int duracaoSegundos = 5}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: duracaoSegundos), () {
          Navigator.of(context).pop(true);
        });
        return AlertDialog(
          content: Text(mensagem),
          backgroundColor: Colors.black.withOpacity(0.7),
          contentTextStyle: TextStyle(color: Colors.white, fontSize: 16),
        );
      },
    );
  }

  /*Função que recebe uma String e que a mostra no ecrã dentro de uma snack bar em forma de aviso*/
  void mostrarSnackbar(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: Duration(seconds: 3), // Tempo que a snackbar ficará visível
      ),
    );
  }

  /*Função que recebe o ID do cuidador logado e devolve uma lista de todos os pacientes desse cuidador*/
  Future<List<Paciente>> fetchPacientesDoCuidador(int idLogado) async {
    List<Paciente> pacientesDoCuidador = [];

    for (int id = 1;; id++) {
      try {
        Paciente paciente = await apiService.fetchPaciente(id);
        if (paciente.idCuidador == idLogado) {
          pacientesDoCuidador.add(paciente);
        }
      } catch (e) {
        // Quando um ID inexistente for encontrado, interrompa o loop
        print('ID $id inexistente, interrompendo o loop.');
        break;
      }
    }
    return pacientesDoCuidador;
  }

  /*Função que recebe uma data de nascimento e devolve a idade atual consoante a data recebida*/
  int calcularIdade(DateTime dataDeNascimento) {
    DateTime hoje = DateTime.now();
    int idade = hoje.year - dataDeNascimento.year;

    // Verificar se o aniversário ainda não ocorreu neste ano
    if (hoje.month < dataDeNascimento.month ||
        (hoje.month == dataDeNascimento.month &&
            hoje.day < dataDeNascimento.day)) {
      idade--;
    }
    return idade;
  }

  /*Função que devolve um numero hexadecimal unico e aleatorio, para atribiur a um novo codigo de paciente*/
  Future<String> generateUniqueHexadecimal() async {
    Random random = Random();
    Set<String> existingCodigos = {};

    // Coletar todos os códigos dos pacientes existentes
    for (int id = 1;; id++) {
      try {
        Paciente paciente = await apiService.fetchPaciente(id);
        existingCodigos.add(paciente.codigo);
      } catch (e) {
        print('ID $id inexistente, interrompendo o loop.');
        break;
      }
    }

    // Função recursiva para gerar um código hexadecimal único
    String generateRandomHexadecimal() {
      String newCodigo =
          random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
      if (existingCodigos.contains(newCodigo)) {
        return generateRandomHexadecimal();
      } else {
        return newCodigo;
      }
    }

    // Chamar a função recursiva
    return generateRandomHexadecimal();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      /*Adicionado para interceptar o botão de "voltar"*/
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        /*coluna esquerda*/
                        children: [
                          Container(
                            /*Imagem de perfil*/
                            width: MediaQuery.of(context).size.width * 0.1,
                            decoration: BoxDecoration(
                              color: Color(0xFF686B69),
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/perfil_img.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            /*Nome do cuidador*/
                            nomeLogado.isEmpty ? '' : nomeLogado,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            /*Cargo do cuidador*/
                            cargoLogado.isEmpty
                                ? 'Conclua o seu registo em baixo'
                                : cargoLogado,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 25),
                          Container(
                            /*Botão de navegção*/
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: ElevatedButton(
                              onPressed: () {
                                /*navega para a pagina de editar proprio perfil*/
                                Get.toNamed('/edit');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF19D5FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Text(
                                'Atualizar Dados',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Libre Franklin',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                        ],
                      ),
                      SizedBox(width: 185),
                      Container(
                        /*Menu dinamico onde tem todos os pacientes e em ultimo um botão de adiconar um novo paciente*/
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: pacientesDoCuidador.length,
                                  itemBuilder: (context, index) {
                                    final paciente = pacientesDoCuidador[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          /*Cada elemento da lista navega para a pagina do proprio paciente, usando o SharedPreferences para mandar os dados do paciente selecionado*/
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          await prefs.setInt(
                                              "id_pacinte", paciente.id);
                                          Get.toNamed('/main/paciente');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.14,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Row(
                                            /*Campos em cada botão: nome, idade, condição e codigo pessoal*/
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      //'nome',
                                                      paciente.nome,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.5,
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      //'condição',
                                                      paciente.condicao,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 5),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      //'Idade:',
                                                      //DateFormat('yyyy-MM-dd').format(paciente.dataDeNascimento),
                                                      '${calcularIdade(paciente.dataDeNascimento).toString()} anos',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.5,
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      //'codigo',
                                                      paciente.codigo,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 10),
                                Container(
                                  /*Botao para criar um novo paciente*/
                                  height:
                                      MediaQuery.of(context).size.height * 0.12,
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[300],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () async {
                                      /*Cria um novo paciente com os campos todos a zero, mas com um código aleatório e com o id do cuidador sincronizado*/
                                      /*Navega para a página de editar paciente*/
                                      String uniqueHex =
                                          await generateUniqueHexadecimal();
                                      print(
                                          'Código hexadecimal único: $uniqueHex');

                                      int maiorId = 0;
                                      for (int id = 1;; id++) {
                                        // Inicia no ID 1 e continua até encontrar um ID inexistente
                                        try {
                                          Paciente paciente = await apiService
                                              .fetchPaciente(id);
                                          if (paciente.id > maiorId) {
                                            maiorId = paciente.id;
                                          }
                                        } catch (e) {
                                          // Quando um ID inexistente for encontrado, interrompa o loop
                                          print(
                                              'ID $id inexistente, interrompendo o loop.');
                                          break;
                                        }
                                      }
                                      DateTime inputDataNull =
                                          DateTime(2000, 1, 1);
                                      try {
                                        Paciente novoPaciente = Paciente(
                                            id: maiorId + 1,
                                            idCuidador: idLogado,
                                            idSensor: 0,
                                            codigo: uniqueHex,
                                            nome: '',
                                            dataDeNascimento: inputDataNull,
                                            genero: '',
                                            altura: 0,
                                            peso: 0,
                                            condicao: '',
                                            descricao: '');
                                        await apiService
                                            .createPaciente(novoPaciente);
                                      } catch (e) {
                                        // Quando um ID inexistente for encontrado, interrompa o loop
                                        print('erro ao criar paciente');
                                      }
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setInt(
                                          "id_pacinte", maiorId + 1);
                                      Get.toNamed('/edit_pac');
                                    },
                                    child: Icon(
                                      Icons.add,
                                      size: 50.0, // Tamanho do ícone
                                      color: Colors.black, // Cor do ícone
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 180),
                      Column(
                        /*coluna esquerda*/
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 200),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.07,
                              width: MediaQuery.of(context).size.width * 0.22,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: TextField(
                                  /*Textfield onde se introduz um novo mac do sensor*/
                                  controller: _controllerSensor,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    border: InputBorder.none,
                                    hintText:
                                        'Introduza o mac de um novo sensor',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF5B5B5B),
                                      fontSize: 16,
                                      fontFamily: 'Libre Franklin',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                          Container(
                            /*Botão atualizar*/
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.width * 0.22,
                            child: ElevatedButton(
                              onPressed: () async {
                                /*Captura o mac introduzido e adiciona à BD um sensor ocm esse mac*/
                                _sensor = _controllerSensor.text;

                                int maiorId = 0;
                                for (int id = 1;; id++) {
                                  // Inicia no ID 1 e continua até encontrar um ID inexistente
                                  try {
                                    Sensor sensores =
                                        await apiService.fetchSensor(id);
                                    if (sensores.id > maiorId) {
                                      maiorId = sensores.id;
                                    }
                                  } catch (e) {
                                    // Quando um ID inexistente for encontrado, interrompa o loop
                                    print(
                                        'ID $id inexistente, interrompendo o loop.');
                                    break;
                                  }
                                }
                                try {
                                  Sensor novoSensor = Sensor(
                                      id: maiorId + 1,
                                      macAdress: _sensor,
                                      dados: '');
                                  await apiService.createSensor(novoSensor);
                                  mostrarSnackbar(context,
                                      'Sensor adicionado com sucesso!');
                                } catch (e) {
                                  // Quando um ID inexistente for encontrado, interrompa o loop
                                  mostrarSnackbar(context,
                                      'Erro ao adicionar sensor, tente novamente');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF19D5FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Text(
                                'Criar Sensor',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Libre Franklin',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _controllerSensor.dispose();
    super.dispose();
  }
}
