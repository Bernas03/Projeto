import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_app/database/database_function.dart';
import 'database/database_classes.dart';

class Edit_Pac_Page extends StatelessWidget {
  const Edit_Pac_Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EditPacPage(),
    );
  }
}

class EditPacPage extends StatefulWidget {
  @override
  _EditPacPageState createState() => _EditPacPageState();
}

class _EditPacPageState extends State<EditPacPage> {
  /*Ligação à BD para usar as funções CRUD*/
  final ApiService apiService = ApiService();

  /*Variaveis do atual cuidador logado*/
  int idLogado = 0;
  String nomeLogado = '';
  String cargoLogado = '';

  /*Lista que vai conter todos os pacientes do cuidador logado*/
  List<Paciente> pacientesDoCuidador = [];

  /*Bool para ajudar na verificação dos valores da BD*/
  bool isLoading = true;

  /*Paciente Atual*/
  Paciente pacienteHere = Paciente(
      id: 0,
      idCuidador: 0,
      idSensor: 0,
      codigo: '',
      nome: '',
      dataDeNascimento: DateTime(1),
      genero: '',
      altura: 0,
      peso: 0,
      condicao: '',
      descricao: '');
  int idPaciente = 0;
  String nomePaciente = '';
  String codigoPacinte = '';
  int idCuidadorPaciente = 0;
  int idSensorPaciente = 0;
  String generoPaciente = '';
  DateTime dataPaciente = DateTime(1);
  int alturaPaciente = 0;
  double pesoPacinte = 0;
  String condicaoPaciente = '';
  String descricaoPaciente = '';

  /*Controllers para capturar o texto dos textfield*/
  TextEditingController _controller_nome = TextEditingController();
  TextEditingController _controller_data = TextEditingController();
  TextEditingController _controller_altura = TextEditingController();
  TextEditingController _controller_peso = TextEditingController();
  TextEditingController _controller_condicao = TextEditingController();

  /*Valores finais para passar para a BD*/
  String _nome = '';
  DateTime _data = DateTime(1);
  String _genero = '';
  int _altura = 0;
  double _peso = 0;
  String _condicao = '';

  /*Controller que captura o codigo do textfield, variavel a que se atribui esse valor, neste caso mac do sensor*/
  TextEditingController _controller_sensor = TextEditingController();
  String _sensor = '';

  /*Controller que captura o codigo do textfield, variavel a que se atribui esse valor, neste caso descrição do paciente*/
  TextEditingController _controller_descricao = TextEditingController();
  String _descricao = '';

  void initState() {
    super.initState();
    _loadCuidadorData();
    _loadPaciente();
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

  /*Função que vai buscar os valores do paciente atual à BD, usando o id guardado no SharedPreferences*/
  void _loadPaciente() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    idPaciente = await prefs.getInt("id_pacinte") ?? 0;

    pacienteHere = await apiService.fetchPaciente(idPaciente);
    idPaciente = pacienteHere.id;
    idCuidadorPaciente = pacienteHere.idCuidador;
    idSensorPaciente = pacienteHere.idSensor;
    codigoPacinte = pacienteHere.codigo;
    nomePaciente = pacienteHere.nome;
    dataPaciente = pacienteHere.dataDeNascimento;
    generoPaciente = pacienteHere.genero;
    alturaPaciente = pacienteHere.altura;
    pesoPacinte = pacienteHere.peso;
    condicaoPaciente = pacienteHere.condicao;
    descricaoPaciente = pacienteHere.descricao;
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

  /*Função que é usada para escolher a data num textfield*/
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dataPaciente != DateTime(0) ? dataPaciente : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != dataPaciente)
      setState(() {
        _data = picked;
        _controller_data.text = DateFormat('dd/MM/yyyy').format(_data);
      });
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      /*Adicionado para interceptar o botão de "voltar"*/
      onWillPop: () async {
        /*Botão voltar redireciona para a pagina principal*/
        Get.toNamed('/main');
        return false;
      },
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
                        /*Coluna esquerda*/
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
                            /*cargo do cuidador*/
                            cargoLogado.isEmpty
                                ? 'Conclua o seu registo'
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
                          SizedBox(height: 40),
                          Container(
                            /*Menu dinamico onde tem todos os pacientes*/
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
                                        final paciente =
                                            pacientesDoCuidador[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
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
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 5),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 150),
                      Column(
                        /*Coluna central*/
                        /*Inicio do formulario*/
                        children: [
                          Container(
                            /*Imagem de perfil od paciente*/
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
                            /*Nome do paciente*/
                            //'Nome do Paciente',
                            nomePaciente.isEmpty ? '' : nomePaciente,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            /*Codigo unico do paciente*/
                            //'codigo do paciente',
                            codigoPacinte.isEmpty
                                ? 'Complete os campos abaixo'
                                : codigoPacinte,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          SizedBox(height: 25),
                          Container(
                            /*Textfield do nome*/
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.width * 0.22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: TextField(
                                controller: _controller_nome,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 20),
                                  border: InputBorder.none,
                                  hintText: //'Nome Completo',
                                      nomePaciente.isEmpty
                                          ? 'Nome do paciente'
                                          : nomePaciente,
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
                          SizedBox(height: 15),
                          Container(
                            /*Textfield da data de nascimento*/
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.width * 0.22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: TextField(
                                controller: _controller_data,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 20),
                                  border: InputBorder.none,
                                  hintText: //'Data de Nascimento',
                                      dataPaciente == DateTime(1)
                                          ? 'Data de nascimento'
                                          : DateFormat('yyyy-MM-dd')
                                              .format(dataPaciente),
                                  hintStyle: TextStyle(
                                    color: Color(0xFF5B5B5B),
                                    fontSize: 16,
                                    fontFamily: 'Libre Franklin',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                readOnly: true,
                                onTap: () => _selectDate(context),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Container(
                            /*Textfield do genero*/
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.width * 0.22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _genero.isNotEmpty ? _genero : null,
                                  hint: Center(
                                    child: Text(
                                      //'genero',
                                      generoPaciente.isEmpty
                                          ? 'Género do paciente'
                                          : generoPaciente,
                                      style: TextStyle(
                                        color: Color(0xFF5B5B5B),
                                        fontSize: 16,
                                        fontFamily: 'Libre Franklin',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _genero = newValue ?? '';
                                    });
                                  },
                                  items: <String>['Masculino', 'Feminino']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Center(
                                        child: Text(
                                          value,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            /*Linha do Peso e da altura*/
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                /*Textfield da altura*/
                                height:
                                    MediaQuery.of(context).size.height * 0.07,
                                width: MediaQuery.of(context).size.width * 0.1,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(width: 1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: TextField(
                                    controller: _controller_altura,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      border: InputBorder.none,
                                      hintText: //'Altura',
                                          alturaPaciente == 0
                                              ? 'Altura do paciente'
                                              : '$alturaPaciente cm',
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
                              SizedBox(width: 15),
                              Container(
                                /*Textfield do peso*/
                                height:
                                    MediaQuery.of(context).size.height * 0.07,
                                width: MediaQuery.of(context).size.width * 0.1,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(width: 1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: TextField(
                                    controller: _controller_peso,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      border: InputBorder.none,
                                      hintText: //'Peso',
                                          pesoPacinte == 0
                                              ? 'Peso do paciente'
                                              : '$pesoPacinte kg',
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
                            ],
                          ),
                          SizedBox(height: 15),
                          Container(
                            /*Textfield da condição*/
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.width * 0.22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: TextField(
                                controller: _controller_condicao,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 20),
                                  border: InputBorder.none,
                                  hintText: //'Condição',
                                      condicaoPaciente.isEmpty
                                          ? 'Condição médica'
                                          : condicaoPaciente,
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
                          SizedBox(height: 15),
                          Container(
                            /*Botão atualizar*/
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.width * 0.22,
                            child: ElevatedButton(
                              onPressed: () async {
                                /*Captura os valores dos textfield e atualiza os dados do cuidador na BD*/
                                Paciente sendPaciente;

                                //tratamento nome
                                if (_controller_nome.text == '') {
                                  _nome = nomePaciente;
                                } else {
                                  _nome = _controller_nome.text;
                                }
                                if (_controller_condicao.text == '') {
                                  _condicao = condicaoPaciente;
                                } else {
                                  _condicao = _controller_condicao.text;
                                }
                                if (_controller_data.text == '') {
                                  _data = dataPaciente;
                                } else {
                                  //String convert = _controller_data.text;
                                  //_data = DateTime.parse(convert);
                                }
                                String mensagem_altura =
                                    'Altura inválida!\nIntroduza uma altura válida';
                                String mensagem_peso =
                                    'Peso inválido!\nIntroduza um peso válido';
                                bool verify = true;
                                if (_controller_altura.text == '') {
                                  _altura = alturaPaciente;
                                } else {
                                  int? value1 =
                                  int.tryParse(_controller_altura.text);
                                  if (value1 == null) {
                                    mostrarSnackbar(context, mensagem_altura);
                                    verify = false;
                                  } else {
                                    _altura = value1;
                                  }
                                }

                                if (_controller_peso.text == '') {
                                  _peso = pesoPacinte;
                                } else {
                                  double? value2 =
                                  double.tryParse(_controller_peso.text);
                                  if (value2 == null) {
                                    mostrarSnackbar(context, mensagem_peso);
                                    verify = false;
                                  } else {
                                    _peso = value2;
                                  }
                                }

                                if (_genero == '') {
                                  sendPaciente = Paciente(
                                      id: idPaciente,
                                      idCuidador: idCuidadorPaciente,
                                      idSensor: idSensorPaciente,
                                      codigo: codigoPacinte,
                                      nome: _nome,
                                      dataDeNascimento: _data,
                                      genero: generoPaciente,
                                      altura: _altura,
                                      peso: _peso,
                                      condicao: _condicao,
                                      descricao: descricaoPaciente);
                                } else {
                                  sendPaciente = Paciente(
                                      id: idPaciente,
                                      idCuidador: idCuidadorPaciente,
                                      idSensor: idSensorPaciente,
                                      codigo: codigoPacinte,
                                      nome: _nome,
                                      dataDeNascimento: _data,
                                      genero: _genero,
                                      altura: _altura,
                                      peso: _peso,
                                      condicao: _condicao,
                                      descricao: descricaoPaciente);
                                }

                                try {
                                  await apiService.updatePaciente(
                                      idPaciente, sendPaciente);
                                  if (verify == true) {
                                    mostrarSnackbar(context,
                                        'Dados atualizados com sucesso!');
                                  }
                                } catch (e) {
                                  print('Erro no update');
                                }

                                //print(idPaciente);
                                //print('Nome: $_nome');
                                //print('Data: ${_data == DateTime(1) ? 'Data não definida' : DateFormat('yyyy-MM-dd').format(_data)}');
                                //print('Gênero: $_genero');
                                //print('Altura: $_altura cm');
                                //print('Peso: $_peso kg');
                                //print('Condição: $_condicao');
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
                        ],
                      ),
                      SizedBox(width: 150),
                      Column(
                        /*Coluna da esquerda*/
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Atribuir de Sensor',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 42,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          SizedBox(height: 15),
                          Container(
                            /*textField do mac do sensor*/
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.width * 0.22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: TextField(
                                controller: _controller_sensor,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 20),
                                  border: InputBorder.none,
                                  hintText:
                                      'Introduza o MAC do sensor deste paciente',
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
                          SizedBox(height: 25),
                          Container(
                            /*Botão atualizar*/
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.width * 0.22,
                            child: ElevatedButton(
                              onPressed: () async {
                                /*Captura o mac e verifica se existe algum existente, se sim atribui esse sensor ao paciente*/
                                bool verifySensor = false;
                                int idSensorEncontrado = 0;
                                if (_controller_sensor.text != '') {
                                  _sensor = _controller_sensor.text;

                                  for (int id = 1;; id++) {
                                    try {
                                      Sensor sensor =
                                          await apiService.fetchSensor(id);
                                      if (_sensor == sensor.macAdress) {
                                        verifySensor = true;
                                        idSensorEncontrado = sensor.id;
                                      }
                                    } catch (e) {
                                      // Quando um ID inexistente for encontrado, interrompa o loop
                                      print(
                                          'ID $id inexistente, interrompendo o loop.');
                                      break;
                                    }
                                  }
                                  if (verifySensor == true) {
                                    Paciente sendPaciente = Paciente(
                                        id: idPaciente,
                                        idCuidador: idCuidadorPaciente,
                                        idSensor: idSensorEncontrado,
                                        codigo: codigoPacinte,
                                        nome: nomePaciente,
                                        dataDeNascimento: dataPaciente,
                                        genero: generoPaciente,
                                        altura: alturaPaciente,
                                        peso: pesoPacinte,
                                        condicao: condicaoPaciente,
                                        descricao: descricaoPaciente);
                                    try {
                                      await apiService.updatePaciente(
                                          idPaciente, sendPaciente);
                                      mostrarSnackbar(
                                          context, 'Sensor atribuido');
                                    } catch (e) {
                                      print('Erro no update!');
                                    }
                                  } else {
                                    mostrarSnackbar(
                                        context, 'Sensor não encontrado');
                                  }
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
                                'Atribuir Sensor',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Libre Franklin',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 70),
                          Stack(
                            /*Caixa geral área da descrição*/
                            children: [
                              Container(
                                /*Caixa grande da descrição, funciona tambem como textfield para o user introduzir uma descrição completa*/
                                width: MediaQuery.of(context).size.width * 0.3,
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                decoration: ShapeDecoration(
                                  //color: Color(0xFFFFFEFE),
                                  color: Color.fromRGBO(255, 255, 255, 0.7),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(width: 2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 50, left: 6),
                                  child: SingleChildScrollView(
                                    child: TextField(
                                      controller: _controller_descricao,
                                      decoration: InputDecoration(
                                        hintText: descricaoPaciente.isEmpty
                                            ? 'Introduza uma descrição detalhada deste paciente'
                                            : descricaoPaciente,
                                        hintMaxLines:
                                            300, // Define o número máximo de linhas para o hintText
                                        hintStyle: TextStyle(
                                          color: descricaoPaciente.isEmpty
                                              ? Color(0xFF5B5B5B)
                                              : Color(0xFF000000),
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.025,
                                        ),
                                        border: InputBorder
                                            .none, // Remove a linha inferior
                                        enabledBorder: InputBorder
                                            .none, // Remove a linha inferior quando habilitado
                                        focusedBorder: InputBorder
                                            .none, // Remove a linha inferior quando focado
                                      ),
                                      style: TextStyle(
                                        color: Color(0xFF000000),
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.025,
                                      ),
                                      maxLines:
                                          null, // Permite múltiplas linhas
                                      keyboardType: TextInputType
                                          .multiline, // Define o tipo de teclado como multiline
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                /*Caixa pequena da descrição (titulo)*/
                                width: MediaQuery.of(context).size.width * 0.3,
                                height:
                                    MediaQuery.of(context).size.height * 0.08,
                                decoration: ShapeDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 0.7),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(width: 2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween, // Adicionado para alinhar o botão à direita
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        'Descrição do paciente',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.035,
                                          fontFamily: 'Libre Franklin',
                                          fontWeight: FontWeight.w400,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Container(
                                        /*Botão para submeter a descrição*/
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.065,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            /*Atualiza a descrição do paciente na BD*/
                                            if (_controller_descricao.text !=
                                                '') {
                                              _descricao =
                                                  _controller_descricao.text;

                                              Paciente sendPaciente = Paciente(
                                                  id: idPaciente,
                                                  idCuidador: idCuidadorPaciente,
                                                  idSensor: idSensorPaciente,
                                                  codigo: codigoPacinte,
                                                  nome: nomePaciente,
                                                  dataDeNascimento: dataPaciente,
                                                  genero: generoPaciente,
                                                  altura: alturaPaciente,
                                                  peso: pesoPacinte,
                                                  condicao: condicaoPaciente,
                                                  descricao: _descricao);
                                              try {
                                                await apiService.updatePaciente(
                                                    idPaciente, sendPaciente);
                                              } catch (e) {
                                                print('Erro no update!');
                                              }
                                              _controller_descricao.clear();
                                              Get.offAllNamed('/');
                                              Get.toNamed('/main/paciente/edit_pac');
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Color(0xFF19D5FF), // Cor de fundo
                                            shape: CircleBorder(
                                                side: BorderSide(
                                                    width: 1,
                                                    color: Colors.black)),
                                            padding: EdgeInsets.all(0),
                                          ),
                                          child: Icon(
                                            IconData(0xe09b,
                                                fontFamily: 'MaterialIcons',
                                                matchTextDirection: true),
                                            size: 30.0, // Tamanho do ícone
                                            color: Colors.black, // Cor do ícone
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
    _controller_nome.dispose();
    _controller_data.dispose();
    _controller_altura.dispose();
    _controller_peso.dispose();
    _controller_condicao.dispose();
    super.dispose();
  }
}
