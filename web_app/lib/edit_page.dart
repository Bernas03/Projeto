import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_app/database/database_function.dart';
import 'database/database_classes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class Edit_Page extends StatelessWidget {
  const Edit_Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EditPage(),
    );
  }
}

class EditPage extends StatefulWidget {
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  /*Ligação à BD para usar as funções CRUD*/
  final ApiService apiService = ApiService();

  /*Variaveis do atual cuidador logado*/
  int idLogado = 0;
  String nomeLogado = '';
  String emailLogado = '';
  String passLogado = '';
  String cargoLogado = '';

  /*Controllers para capturar o texto dos textfield*/
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  TextEditingController _controllerCargo = TextEditingController();

  /*Valores finais para passar para a BD*/
  String _nome = '';
  String _email = '';
  String _password = '';
  String _cargo = '';

  /*hintText para a password*/
  String hintText = 'Palavra-passe';

  void initState() {
    super.initState();
  }

  /*Função que mostra so password com o cursor em cima*/
  void _onEnter(PointerEvent details) {
    setState(() {
      hintText = passLogado;
    });
  }

  /*Função que garante que a password fica oculta*/
  void _onExit(PointerEvent details) {
    setState(() {
      hintText = 'Palavra-passe';
    });
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

  /*Função que recebe uma string e retorna true se essa string tiver letras e numeros e for maior ou igual que 8 carateres, caso contrário retorna false*/
  bool verificaLetrasNumeros(String input) {
    // Verificar se a string contém pelo menos uma letra
    bool hasLetters = input.contains(RegExp(r'[a-zA-Z]'));

    // Verificar se a string contém pelo menos um número
    bool hasNumbers = input.contains(RegExp(r'[0-9]'));

    // Verificar se a string tem pelo menos 8 caracteres
    bool hasMinimumLength = input.length >= 8;

    // Retornar verdadeiro se contiver letras, números e tiver pelo menos 8 caracteres
    return hasLetters && hasNumbers && hasMinimumLength;
  }

  @override
  Widget build(BuildContext context) {
    /*Metodo para ir buscar os valores atuais do cuidador à SharedPreferences*/
    SharedPreferences.getInstance().then((_prefs) async {
      idLogado = (await _prefs.getInt('id_cuidador_logado'))!;
    }).then((value) async {
      Cuidador cuidadorLogado = await apiService.fetchCuidador(idLogado);
      setState(() {
        nomeLogado = cuidadorLogado.nome;
        emailLogado = cuidadorLogado.email;
        passLogado = cuidadorLogado.password;
        cargoLogado = cuidadorLogado.cargo;
      });
    });

    return WillPopScope(
      /*Adicionado para interceptar o botão de "voltar"*/
      onWillPop: () async {
        /*Botão voltar redireciona para a pagina principal*/
        Get.toNamed('/main');
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(top: 30, left: 30),
            child: Column(
              /*Início do formulário*/
              children: [
                Container(
                  /*Imagem de perfil*/
                  width: MediaQuery.of(context).size.width * 0.1,
                  decoration: BoxDecoration(
                    color: Color(0xFF686B69),
                    shape: BoxShape.circle, // Define a forma como circular
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
                Text(
                  /*Nome do cuidador*/
                  //'Nome do Cuidador',
                  nomeLogado,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  /*cargo do cuidador*/
                  //'“médico”',
                  cargoLogado,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
                SizedBox(height: 15),
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
                      controller: _controllerNome,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        border: InputBorder.none,
                        hintText:
                            //'Nome',
                            nomeLogado.isEmpty
                                ? 'Introduza o seu nome'
                                : nomeLogado,
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
                  /*textField do email*/
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: MediaQuery.of(context).size.width * 0.22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _controllerEmail,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        border: InputBorder.none,
                        hintText:
                            //'Email',
                            emailLogado,
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
                MouseRegion(
                  /*textField da password*/
                  onEnter: _onEnter,
                  onExit: _onExit,
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
                        controller: _controllerPassword,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          border: InputBorder.none,
                          hintText: hintText,
                          //'Palavra-passe',
                          //passLogado,
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
                  /*textField do cargo*/
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: MediaQuery.of(context).size.width * 0.22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _controllerCargo,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        border: InputBorder.none,
                        hintText:
                            //'Cargo',
                            cargoLogado.isEmpty
                                ? 'Introduza o seu cargo'
                                : cargoLogado,
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
                  /*Botão atualizar formulario*/
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: MediaQuery.of(context).size.width * 0.22,
                  child: ElevatedButton(
                    onPressed: () async {
                      /*Captura os valores dos textfield e atualiza os dados do cuidador na BD*/
                      _nome = _controllerNome.text;
                      _email = _controllerEmail.text;
                      _password = _controllerPassword.text;
                      _cargo = _controllerCargo.text;

                      bool verificaPass = false;

                      if (_nome == '') {
                        _nome = nomeLogado;
                      }
                      if (_email == '') {
                        _email = emailLogado;
                      }
                      if (_cargo == '') {
                        _cargo = cargoLogado;
                      }
                      if (_password == '') {
                        _password = passLogado;
                      }
                      verificaPass = verificaLetrasNumeros(_password);
                      print(_password);
                      print(verificaPass);

                      if (verificaPass == false) {
                        mostrarSnackbar(context,
                            'A palavra passe tem de ter 8 digitos com letras e números');
                      }

                      try {
                        if (verificaPass == true) {
                          Cuidador novoCuidador = Cuidador(
                              id: idLogado,
                              nome: _nome,
                              email: _email,
                              password: _password,
                              cargo: _cargo);
                          await apiService.updateCuidador(idLogado, novoCuidador);
                          print('cuidador atualizado!');
                        }
                      } catch (e) {
                        print('Erro ao atualizar cuidador');
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
          ),
        ),
      ),
    );
  }
  void dispose() {
    _controllerEmail.dispose();
    _controllerNome.dispose();
    _controllerPassword.dispose();
    _controllerCargo.dispose();
    super.dispose();
  }
}
