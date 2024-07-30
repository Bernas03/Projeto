import 'package:andoid_studio/database/database_classes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'database/database_function.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Profile_Page extends StatelessWidget {
  const Profile_Page({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(children: [
          EditarPage(),
        ]),
      ),
    );
  }
}

class EditarPage extends StatefulWidget {
  @override
  State<EditarPage> createState() => _EditarPageState();
}
/*Valores finais para passar para a BD*/
class _EditarPageState extends State<EditarPage> {
  /*Ligação à BD para usar as funções CRUD*/
  final ApiService apiService = ApiService();

  /*Controllers para capturar o texto dos textfield*/
  TextEditingController _controller_nome = TextEditingController();
  TextEditingController _controller_data = TextEditingController();
  TextEditingController _controller_altura = TextEditingController();
  TextEditingController _controller_peso = TextEditingController();


  String _nome = '';
  DateTime _data = DateTime(1);
  String _genero = '';
  int _altura = 0;
  double _peso = 0;

  /*Variaveis para ir buscar à BD do paciente*/
  int idAtual = 0;
  int idCuidadorAtual = 0;
  int idSensorAtual = 0;
  String codigoAtual = '';
  String nomeAtual = '';
  DateTime dataAtual = DateTime(0);
  String generoAtual = '';
  int alturaAtual = 0;
  double pesoAtual = 0;
  String condicaoAtual = '';
  String descricaoAtual = '';

  /*Objetos Paciente*/
  late Paciente pacienteAtual;
  late Paciente sendPaciente;
  late Paciente sendPaciente2;

  /*Bool para ajudar na verificação dos valores da BD*/
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPacienteData();
  }

  /*Função que vai buscar à BD os dados do paciente, mensagem e sensor de acordo com o paciente logado*/
  Future<void> _loadPacienteData() async {
    int idPacienteLogado = 0;
    SharedPreferences.getInstance().then((_prefs) async {
      idPacienteLogado = (await _prefs.getInt('id-paciente-logado'))!;
    }).then((value) async {
      for (int id = 1;; id++) {
        // Inicia no ID 1 e continua até encontrar um ID inexistente
        try {
          Paciente paciente = await apiService.fetchPaciente(id);
          if (paciente.id == idPacienteLogado) {
            setState(() {
              idAtual = idPacienteLogado;
              idCuidadorAtual = paciente.idCuidador;
              idSensorAtual = paciente.idSensor;
              codigoAtual = paciente.codigo;
              nomeAtual = paciente.nome;
              dataAtual = paciente.dataDeNascimento;
              generoAtual = paciente.genero;
              alturaAtual = paciente.altura;
              pesoAtual = paciente.peso;
              condicaoAtual = paciente.condicao;
              descricaoAtual = paciente.descricao;
            });
          }
        } catch (e) {
          // Quando um ID inexistente for encontrado, interrompa o loop
          print('ID $id inexistente, interrompendo o loop.');
          setState(() {
            isLoading = false;
          });
          break;
        }
      }
    });
    final dataAtualFormatada = DateFormat('dd/MM/yyyy').format(dataAtual);
    //Objeto paciente com o que esta atualemnte logado
    pacienteAtual = new Paciente(
        id: idAtual,
        idCuidador: idCuidadorAtual,
        idSensor: idSensorAtual,
        codigo: codigoAtual,
        nome: nomeAtual,
        dataDeNascimento: dataAtual,
        genero: generoAtual,
        altura: alturaAtual,
        peso: pesoAtual,
        condicao: condicaoAtual,
        descricao: descricaoAtual);
  }

  /*Função que é usada para escolher a data num textfield*/
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dataAtual != DateTime(0) ? dataAtual : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != dataAtual)
      setState(() {
        _data = picked;
        _controller_data.text = DateFormat('dd/MM/yyyy').format(_data);
      });
  }

  /*Esta função que recebe uma String e que a mostra no ecrã dentro de uma snack bar em forma de aviso*/
  void mostrarSnackbar(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: Duration(seconds: 5), // Tempo que a snackbar ficará visível
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.white,
              child: Stack(
                children: [
                  Align(
                    /*Imagem de fundo*/
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Image.asset(
                        'assets/images/background_img3.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Column(
                          /*Início do formulário*/
                          children: [
                            Container(
                              /*Imagem de perfil*/
                              width: MediaQuery.of(context).size.width * 0.48,
                              decoration: BoxDecoration(
                                color: Color(0xFF686B69),
                                shape: BoxShape
                                    .circle, // Define a forma como circular
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/perfil_img.png',
                                  fit: BoxFit
                                      .cover, // Ajusta a imagem para cobrir o espaço do círculo
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Container(
                              /*TextField do nome*/
                              height: MediaQuery.of(context).size.height * 0.06,
                              width: MediaQuery.of(context).size.width * 0.67,
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
                                    hintText:
                                        //'Nome Completo',
                                        nomeAtual,
                                    hintStyle: TextStyle(
                                      color: Color(0xFF5B5B5B),
                                      fontSize: 28,
                                      fontFamily: 'Libre Franklin',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Container(
                              /*TextField da data de nascimento*/
                              height: MediaQuery.of(context).size.height * 0.06,
                              width: MediaQuery.of(context).size.width * 0.67,
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
                                    hintText:
                                        //'Data de Nascimento',
                                        //dataAtualFormatada,
                                        DateFormat('yyyy-MM-dd')
                                            .format(dataAtual),
                                    hintStyle: TextStyle(
                                      color: Color(0xFF5B5B5B),
                                      fontSize: 28,
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
                              /*TextField do genero*/
                              height: MediaQuery.of(context).size.height * 0.06,
                              width: MediaQuery.of(context).size.width * 0.67,
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
                                        generoAtual,
                                        style: TextStyle(
                                          color: Color(0xFF5B5B5B),
                                          fontSize: 28,
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
                                            style:
                                                TextStyle(color: Colors.black),
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
                                  /*TextField da altura*/
                                  height:
                                      MediaQuery.of(context).size.height * 0.06,
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
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
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        border: InputBorder.none,
                                        hintText:
                                            //'Altura',
                                            '$alturaAtual cm',
                                        hintStyle: TextStyle(
                                          color: Color(0xFF5B5B5B),
                                          fontSize: 28,
                                          fontFamily: 'Libre Franklin',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15),
                                Container(
                                  /*TextField do peso*/
                                  height:
                                      MediaQuery.of(context).size.height * 0.06,
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
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
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        border: InputBorder.none,
                                        hintText:
                                            //'Peso',
                                            '$pesoAtual kg',
                                        hintStyle: TextStyle(
                                          color: Color(0xFF5B5B5B),
                                          fontSize: 28,
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
                              /*Botão de submissão do formulário*/
                              height: MediaQuery.of(context).size.height * 0.06,
                              width: MediaQuery.of(context).size.width * 0.67,
                              child: ElevatedButton(
                                onPressed: () async {
                                  /*Função que verifica todos os parametros e envia os valores para a BD*/
                                  //tratamento nome
                                  if (_controller_nome.text == '') {
                                    _nome = nomeAtual;
                                  } else {
                                    _nome = _controller_nome.text;
                                  }
                                  if (_controller_data.text == '') {
                                    _data = dataAtual;
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
                                    _altura = alturaAtual;
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
                                    _peso = pesoAtual;
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
                                        id: idAtual,
                                        idCuidador: idCuidadorAtual,
                                        idSensor: idSensorAtual,
                                        codigo: codigoAtual,
                                        nome: _nome,
                                        dataDeNascimento: _data,
                                        genero: generoAtual,
                                        altura: _altura,
                                        peso: _peso,
                                        condicao: condicaoAtual,
                                        descricao: descricaoAtual);
                                  } else {
                                    sendPaciente = Paciente(
                                        id: idAtual,
                                        idCuidador: idCuidadorAtual,
                                        idSensor: idSensorAtual,
                                        codigo: codigoAtual,
                                        nome: _nome,
                                        dataDeNascimento: _data,
                                        genero: _genero,
                                        altura: _altura,
                                        peso: _peso,
                                        condicao: condicaoAtual,
                                        descricao: descricaoAtual);
                                  }
                                  /*Envia os valores do paciente para a BD, chama a função mostrarSnackbar() para dar feedback*/
                                  try {
                                    await apiService.updatePaciente(
                                        idAtual, sendPaciente);
                                    if (verify == true) {
                                      mostrarSnackbar(context,
                                          'Dados atualizados com sucesso!');
                                    }
                                  } catch (e) {
                                    print('Erro no update');
                                  }
                                  verify = true;
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
                                    fontSize: 24,
                                    fontFamily: 'Libre Franklin',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 25),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
    super.dispose();
  }
}
