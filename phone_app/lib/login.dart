import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

import 'database/database_classes.dart';
import 'database/database_function.dart';
import 'home-page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Login(),
    );
  }
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  /*Controller para capturar o texto do textfield, string que vai receber esse codigo de acesso capturado pelo controller*/
  final TextEditingController _controller = TextEditingController();
  String _codigoAcesso = '';

  /*Metodo que é usado nas funcionalidades bluetooth*/
  static const platform = MethodChannel('samples.flutter.dev/bluetooth');

  /*Ligação à BD para usar as funções CRUD*/
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadCodigoAcesso();
    _requestPermissions();
  }

  /*Função que vai buscar o codigo de acesso logado da última vez, ou guarda o novo introduzido usando o SharedPreferences*/
  Future<void> _loadCodigoAcesso() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _codigoAcesso = prefs.getString('codigo-paciente-logado') ?? '';
      _controller.text = _codigoAcesso;
    });
  }

  /*Função que pede ao utilizador as permissões para a app poder usar o bluetooth*/
  Future<void> _requestPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.location.request().isGranted) {
      // Permissões concedidas, buscar dispositivos Bluetooth emparelhados
      _getPairedDevices();
    } else {
      // Permissões negadas, trate a situação conforme necessário
    }
  }

  /*Função que vai buscar os dispositivos emparelhados com o dispositivo da app*/
  Future<void> _getPairedDevices() async {
    try {
      final String result = await platform.invokeMethod('getPairedDevices');
      print(result); // Lista de dispositivos emparelhados
    } on PlatformException catch (e) {
      print("Failed to get paired devices: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    /*Textfield onde o utilzador introduz o codigo de acesso pessoal*/
                    height: MediaQuery.of(context).size.height * 0.068,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          border: InputBorder.none,
                          hintText: 'Introduza o código de acesso',
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
                  SizedBox(height: 20),
                  Container(
                    /*Botão de submissão do codigo*/
                    height: MediaQuery.of(context).size.height * 0.068,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                      onPressed: () async {
                        /*Função que permite a app guardar a string introduzida no textfield e comparar com os valores da BD*/
                        setState(() async {
                          _codigoAcesso = _controller.text;
                          // Verificar se o código de acesso corresponde a algum ID de paciente
                          bool codigoValido = false;
                          int idlogado = 0;
                          for (int id = 1;; id++) {
                            // Inicia no ID 1 e continua até encontrar um ID inexistente
                            try {
                              Paciente paciente =
                                  await apiService.fetchPaciente(id);
                              if (_codigoAcesso == paciente.codigo.toString()) {
                                codigoValido = true;
                                idlogado = paciente.id;
                                break;
                              }
                            } catch (e) {
                              // Quando um ID inexistente for encontrado, interrompa o loop
                              print(
                                  'ID $id inexistente, interrompendo o loop.');
                              break;
                            }
                          }

                          if (codigoValido) {
                            /*Código de acesso válido, guardar no SharedPreferences e navegar para a próxima página*/
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setInt('id-paciente-logado', idlogado);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()),
                            );
                          } else {
                            /*Código de acesso válido, mostrar mensagem de aviso*/
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Text('Código inválido!'),
                                  content: Text(
                                      'Verifique o seu código pessoal e introduza corretamente'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK',
                                          style: TextStyle(
                                              color: Colors.blueAccent)),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF19D5FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'Libre Franklin',
                          fontWeight: FontWeight.w400,
                        ),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
