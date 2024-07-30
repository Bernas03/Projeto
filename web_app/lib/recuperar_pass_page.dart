import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:web_app/database/database_function.dart';
import 'database/database_classes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class Recuperar_Page extends StatelessWidget{
  const Recuperar_Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RecuperarPage(),
    );
  }
}

class RecuperarPage extends StatefulWidget {
  @override
  _RecuperarPageState createState() => _RecuperarPageState();
}

class _RecuperarPageState extends State<RecuperarPage> {
  /*Ligação à BD para usar as funções CRUD*/
  final ApiService apiService = ApiService();

  /*Controllers para capturar o texto dos textfield*/
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword1 = TextEditingController();
  TextEditingController _controllerPassword2 = TextEditingController();

  /*Variáveis que vão receber os valores dos controllers*/
  String _email = '';
  String _password1 = '';
  String _password2 = '';

  void initState() {
    super.initState();
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

  /*Função que recebe uma string e retorna true se essa string estiver no formato de email, caso contrário retorna false*/
  bool verificaFormatoEmail(String email) {
    // Expressão regular para validar emails
    String p =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = new RegExp(p);

    // Verifica se o email corresponde ao padrão da regex
    return regExp.hasMatch(email);
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
    WidgetsFlutterBinding.ensureInitialized();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 90),
              child: Column(
                /*Area de Criar conta*/
                children: [
                  Text('Criar Conta',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 64,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      )),
                  SizedBox(height: 30),
                  Container(
                    /*Textfield onde se introduz o email*/
                    height: MediaQuery.of(context).size.height * 0.085,
                    width: MediaQuery.of(context).size.width * 0.30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _controllerEmail,
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          border: InputBorder.none,
                          hintText: 'Introduza um email',
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
                    /*Textfield onde se introduz a password*/
                    height: MediaQuery.of(context).size.height * 0.085,
                    width: MediaQuery.of(context).size.width * 0.30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _controllerPassword1,
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                        obscureText: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          border: InputBorder.none,
                          hintText: 'Introduza uma palavra-passe',
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
                    /*Textfield onde se reintroduz a password*/
                    height: MediaQuery.of(context).size.height * 0.085,
                    width: MediaQuery.of(context).size.width * 0.30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _controllerPassword2,
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                        obscureText: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          border: InputBorder.none,
                          hintText: 'Reintroduza uma palavra-passe',
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
                    /*Botão de submissão de formulario*/
                    child: ElevatedButton(
                      onPressed: () async {
                        /*Este botão captura os valores dos textfields usando os controllers, chama as funções de verificação verificaFormatoEmail() e verificaLetrasNumeros() que verifica os inputs*/
                        /*Se as verificações forem =true cria um novo cuidador na BD e avança para a página principal*/
                        setState(() {
                          _email = _controllerEmail.text;
                          _password1 = _controllerPassword1.text;
                          _password2 = _controllerPassword2.text;
                        });
                        bool verificaEmail = verificaFormatoEmail(_email);
                        bool verificaPass = verificaLetrasNumeros(_password1);

                        if (verificaEmail == false) {
                          mostrarSnackbar(context, 'Formato de email inválido');
                        } else if (verificaPass == false) {
                          mostrarSnackbar(context,
                              'A palavra passe tem de ter 8 digitos com letras e números');
                        } else if (_password1 != _password2) {
                          mostrarSnackbar(
                              context, 'As palavras passe têm de ser iguais');
                        }

                        if (verificaEmail == true &&
                            verificaPass == true &&
                            _password1 == _password2) {
                          int maiorId = 0;
                          for (int id = 1;; id++) {
                            // Inicia no ID 1 e continua até encontrar um ID inexistente
                            try {
                              Cuidador cuidador =
                              await apiService.fetchCuidador(id);
                              if (cuidador.id > maiorId) {
                                maiorId = cuidador.id;
                              }
                            } catch (e) {
                              // Quando um ID inexistente for encontrado, interrompa o loop
                              print(
                                  'ID $id inexistente, interrompendo o loop.');
                              break;
                            }
                          }
                          print(maiorId);
                          Cuidador NovoCuidador = Cuidador(
                              id: maiorId + 1,
                              nome: '',
                              email: _email,
                              password: _password1,
                              cargo: '');
                          await apiService.createCuidador(NovoCuidador);

                          SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                          await prefs.setInt("id_cuidador_logado", maiorId + 1);
                          Get.toNamed('/main');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF19D5FF), // Cor de fundo
                        shape: CircleBorder(
                            side: BorderSide(width: 1, color: Colors.black)),
                        padding: EdgeInsets.all(0),
                        minimumSize: Size(
                          MediaQuery.of(context).size.width * 0.1,
                          MediaQuery.of(context).size.height * 0.085,
                        ),
                      ),
                      child: Icon(
                        IconData(0xe09b,
                            fontFamily: 'MaterialIcons',
                            matchTextDirection: true),
                        //Icons.add, // Substitua pelo ícone desejado
                        size: 50.0, // Tamanho do ícone
                        color: Colors.black, // Cor do ícone
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 150),
            Container(
              /*Barra vertical central*/
              width: 1, // Largura da linha
              color: Colors.black,
              height: double.infinity,
            ),
            SizedBox(width: 150),
            Padding(
              padding: EdgeInsets.only(top: 90),
              child: Column(
                children: [
                  Text('Recuperar\npalavra-passe',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 64,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      )),
                  SizedBox(height: 30),
                  Container(
                    /*Textfield onde se introduz o email*/
                    height: MediaQuery.of(context).size.height * 0.085,
                    width: MediaQuery.of(context).size.width * 0.30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: TextField(
                        //controller: _controller,
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          border: InputBorder.none,
                          hintText: 'Introduza o seu email',
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
                    /*Botão de submissão de formulario*/
                    child: ElevatedButton(
                      onPressed: () {
                        /*Funcionalidade a ser implementda*/
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF19D5FF), // Cor de fundo
                        shape: CircleBorder(
                            side:
                            BorderSide(width: 1, color: Colors.black)),
                        padding: EdgeInsets.all(0),
                        minimumSize: Size(
                          MediaQuery.of(context).size.width * 0.1,
                          MediaQuery.of(context).size.height * 0.085,
                        ),
                      ),
                      child: Icon(
                        IconData(0xe09b, fontFamily: 'MaterialIcons', matchTextDirection: true),
                        //Icons.add, // Substitua pelo ícone desejado
                        size: 50.0, // Tamanho do ícone
                        color: Colors.black, // Cor do ícone
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void dispose() {
    _controllerEmail.dispose();
    _controllerPassword1.dispose();
    _controllerPassword2.dispose();
    super.dispose();
  }
}
