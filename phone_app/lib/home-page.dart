import 'package:flutter/cupertino.dart';
import 'bitalino_lib/bitalino.dart';
import 'package:flutter/material.dart';
import 'package:andoid_studio/profile-page.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'database/database_classes.dart';
import 'database/database_function.dart';

class Home_Page extends StatelessWidget {
  const Home_Page({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(children: [
          HomePage(),
        ]),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /*Ligação à BD para usar as funções CRUD*/
  final ApiService apiService = ApiService();

  /*Variaveis String que servem para a area de mensagem*/
  String inicial = 'Não nenhuma mensagem neste momento';
  String texto_recebido = '';
  String luisiadas =
      'Naquele ano, em Maio, na Casa dos Maias, a senhora Condessa de Gouvarinho dava um baile. Tinha andado chuva durante o dia, e a alameda, as sebes de buxo, a folhagem tenra das tílias exalavam, na tepidez da noite, uma frescura húmida. Daí o ar da sala de jantar, onde se ceava, estava também impregnado de aroma de lilás, com um sabor a erva viva e molhada. Grandes ramos de lilás e de rosas enchiam as jarras de porcelana colocadas sobre o aparador, diante dos velhos retratos de família, dos grão-senhores de quinhentos, de rosto magro e barba pontiaguda, com a mão crispada no punho da espada. Em cima, no tecto, uma ampla pintura de epopeia, toda emazeda, toda sumida, representava o Assassínio de Viriato. E, pelas paredes de seda amarela, dois grandes Espelhos de Veneza, uma Vénus de Canova, mesas de pau-preto, com floreiras de estanho e estatuetas de biscuit, refletiam a luz dos candelabros, dispostos pelo móvel das travessas, dos doces, das frutas.';

  /*Mensagem para a snackbar do bitalino*/
  String mensagemException =
      'Falha ao conectar com o sensor, desligue e tente novamente';
  String mensagemConnect = 'Sensor conectado com sucesso!';

  /*Valores para abrigar o nome e a data do paciente atual*/
  String nomeAtual = '';
  DateTime dataAtual = DateTime(0);
  int pacienteID = 0;

  int idSensorLogado = 0;
  String macAdress = '';

  /*Booleanos para ajudar em algumas verificações ao longo do codigo*/
  bool botaoPrincipal = false;
  bool boolLigacao = false;
  bool boolDados = false;

  bool isLoadingA = true;
  bool isLoadingB = true;
  bool isLoadingC = true;

  /*Lista de dados que vão ser recolhidos do sensor ECG*/
  List<int> listaRecolha = [];

  @override
  void initState() {
    super.initState();
    setState(() {});
    _loadDatabaseData();
  }

  /*Função que vai buscar à BD os dados do paciente, mensagem e sensor de acordo com o paciente logado*/
  Future<void> _loadDatabaseData() async {
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
              nomeAtual = paciente.nome;
              dataAtual = paciente.dataDeNascimento;
              pacienteID = paciente.id;
              idSensorLogado = paciente.idSensor;
            });
          }
        } catch (e) {
          // Quando um ID inexistente for encontrado, interrompa o loop
          print('ID $id inexistente, interrompendo o loop.');
          setState(() {
            isLoadingA = false;
          });
          break;
        }
      }
      for (int id = 1;; id++) {
        // Inicia no ID 1 e continua até encontrar um ID inexistente
        try {
          Mensagem mensagem = await apiService.fetchMensagem(id);
          if (mensagem.idPaciente == idPacienteLogado) {
            setState(() {
              texto_recebido = mensagem.mensagem;
            });
          }
        } catch (e) {
          // Quando um ID inexistente for encontrado, interrompa o loop
          print('ID $id inexistente, interrompendo o loop.');
          setState(() {
            isLoadingB = false;
          });
          break;
        }
      }
      for (int id = 1;; id++) {
        // Inicia no ID 1 e continua até encontrar um ID inexistente
        try {
          Sensor sensor = await apiService.fetchSensor(id);
          if (idSensorLogado == sensor.id) {
            setState(() {
              macAdress = sensor.macAdress;
            });
          }
        } catch (e) {
          // Quando um ID inexistente for encontrado, interrompa o loop
          print('ID $id inexistente, interrompendo o loop.');
          setState(() {
            isLoadingC = false;
          });
          break;
        }
      }
    });
  }

  /*Função para exibir o diálogo de confirmação ao tentar sair da app*/
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Sair da aplicação?'),
            content: Text('Sair desta forma implica paragem de funcionamento'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Não', style: TextStyle(color: Colors.blueAccent)),
              ),
              TextButton(
                onPressed: () async {
                  bitalinoDisconnect();
                  Navigator.of(context).pop(true);
                },
                child: Text('Sim', style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          ),
        )) ??
        false;
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

  /*Metodos para instanciar, conectar e desconectar o sensor BITalino*/
  BITalinoController? bitalinoController;
  /*Função para conectar e recolher dados do bitalino*/
  Future<void> bitalinoConnect() async {
    // Definindo o controlador BITalino para Android ou iOS
    bitalinoController = BITalinoController(
      //"20:15:10:26:64:77",
      macAdress,
      CommunicationType.BTH,
    );

    try {
      await bitalinoController!.initialize();
      print("Inicialização bem-sucedida.");
    } on PlatformException catch (e) {
      print("Falha na inicialização: ${e.message}");
      return;
    }

    try {
      await bitalinoController!.connect(
        onConnectionLost: () {
          print("Conexão perdida");
        },
      );
      print("Conectado ao dispositivo BITalino.");

      // Iniciar aquisição de dados
      bool success = await bitalinoController!.start(
        [0, 2, 4, 5],
        Frequency.HZ1000,
        onDataAvailable: (BITalinoFrame frame) {
          print('Frame sequence: ${frame.sequence}');
          print('Analog data: ${frame.analog}');
          print('Digital data: ${frame.digital}');

          listaRecolha.add(frame.analog[2]); // O índice 2 é o terceiro elemento
          //print(novaLista); // Imprimir a nova lista
        },
      );

      if (success) {
        print("Aquisição de dados iniciada com sucesso.");
        mostrarSnackbar(context, mensagemConnect);
        setState(() {
          boolLigacao = true;
        });
      } else {
        print("Falha ao iniciar aquisição de dados.");
      }

      // Parar aquisição de dados após um certo período
      await Future.delayed(Duration(days: 100000));

      // Obter estado do dispositivo (Apenas para Android)
      BITalinoState state = await bitalinoController!.state();
      print('Estado do dispositivo:');
      print('Identifier: ${state.identifier}');
      print('Battery: ${state.battery}');
      print('Battery Threshold: ${state.batteryThreshold}');
      print('Analog data: ${state.analog}');
      print('Digital data: ${state.digital}');
    } catch (e) {
      print('Ocorreu uma exceção: $e');
      mostrarSnackbar(context, mensagemException);
    }
  }

  /*Função para desconectar o bitalino*/
  Future<void> bitalinoDisconnect() async {
    //try {
    bool success = await bitalinoController!.stop();
    if (success) {
      print("Aquisição de dados parada com sucesso.");
    } else {
      print("Falha ao parar aquisição de dados.");
    }

    success = await bitalinoController!.disconnect();
    if (success) {
      print("Desconectado do dispositivo BITalino com sucesso.");
      setState(() {
        boolLigacao = false;
      });
    } else {
      print("Falha ao desconectar do dispositivo.");
    }

    success = await bitalinoController!.dispose();
    if (success) {
      print("Controlador BITalino disposto com sucesso.");
    } else {
      print("Falha ao dispor o controlador.");
    }
    //} catch (e) {
    //   print('Ocorreu uma exceção: $e');
    // }
  }

  /*Função que faz a box "Dados" mudar a cor por 5 segundos*/
  Future<void> mudaEstado() async {
    setState(() {
      boolDados = true;
    });
    await Future.delayed(Duration(seconds: 5));
    setState(() {
      boolDados = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      /*Adicionado para interceptar o botão de "voltar"*/
      onWillPop: _onWillPop,
      child: Scaffold(
        body: isLoadingA && isLoadingB && isLoadingC
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
                            /*Coluna que alinha tudo o resto que não a imagem de fundo*/
                            children: [
                              Container(
                                /*O perfil em cima é um botão com imagem nome e data de nascimento*/
                                height:
                                    MediaQuery.of(context).size.height * 0.095,
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: ElevatedButton(
                                  onPressed: () {
                                    /*Função dentro do botão que neste caso vai para a pagina de editar perfil*/
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditarPage()),
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color(0xFFB4B7B5)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        side: BorderSide(width: 1),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                    ),
                                  ),
                                  child: Align(
                                    /*Estética do botão que avança para a pag de editar perfil*/
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08,
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
                                        SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              //'Nome da Pessoa',
                                              nomeAtual,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.023,
                                                fontFamily: 'Libre Franklin',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(height: 3),
                                            Text(
                                              //'Data de nascimento',
                                              //dataAtualFormatada.toString(),
                                              DateFormat('yyyy-MM-dd')
                                                  .format(dataAtual),
                                              style: TextStyle(
                                                color: Color(0xFF686B69),
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.017,
                                                fontFamily: 'Libre Franklin',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              Row(
                                /*Linha do botão de "LIGAR" com as status bar*/
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    /*Status bar esquerda do botao */
                                    width: MediaQuery.of(context).size.width *
                                        0.035,
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    decoration: ShapeDecoration(
                                      color: botaoPrincipal
                                          ? Color(0xFF006400)
                                          : Color(0xFFFF0000),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(width: 1.50),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 30),
                                  Container(
                                    /*Box do botão "LIGAR"*/
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        /*Função que torna o botão num interruptor e que chama a função bitalinoConnect() para fazer a ligação e a recolha de dados e chama a função bitalinoDisconnect() caso alguma coisa corra mal */
                                        setState(() {
                                          botaoPrincipal = !botaoPrincipal;
                                        });
                                        if (botaoPrincipal) {
                                          bitalinoConnect();
                                        } else {
                                          bitalinoDisconnect();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color(0xFF19D5FF), // Cor de fundo
                                        //Colors.blueAccent,
                                        //Color.fromRGBO(25, 213, 255, 0.7),
                                        shape: CircleBorder(
                                          side: BorderSide(
                                              width: 2,
                                              color: Colors.black), // Borda
                                        ),
                                        padding: EdgeInsets.all(
                                            0), // Remove o padding interno
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Text(
                                            botaoPrincipal
                                                ? 'Desligar'
                                                : 'Ligar',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.07,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              height: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 30),
                                  Container(
                                    /*Status bar direita do botao*/
                                    width: MediaQuery.of(context).size.width *
                                        0.035,
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    decoration: ShapeDecoration(
                                      color: botaoPrincipal
                                          ? Color(0xFF006400)
                                          : Color(0xFFFF0000),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(width: 1.50),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Container(
                                /*Botão que envia os dados coletados para a BD*/
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!botaoPrincipal) {
                                      if (listaRecolha.length < 10) {
                                        mostrarSnackbar(context,
                                            'Amostra de dados insuficiente, Recolha mais dados');
                                      }
                                      if (listaRecolha.length >= 10) {
                                        String finalDados =
                                            listaRecolha.join(',');
                                        Sensor sendSensor = Sensor(
                                            id: idSensorLogado,
                                            macAdress: macAdress,
                                            dados: finalDados);
                                        await apiService.updateSensor(
                                            idSensorLogado, sendSensor);
                                        mostrarSnackbar(context,
                                            'Dados enviados com sucesso');
                                        List<int> listavazia = [];
                                        listaRecolha = listavazia;
                                        mudaEstado();
                                      } else {
                                        mostrarSnackbar(context,
                                            'Primeiro desligue a aplicação!');
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF19D5FF),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      side: BorderSide(
                                        color:
                                            Colors.black, // Cor da borda preta
                                        width: 2, // Largura da borda de 1 pixel
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Enviar Dados',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              Row(
                                /*Linha dos indicadores de ligação e de dados*/
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    /*Indicador de ligação*/
                                    width: MediaQuery.of(context).size.width *
                                        0.48,
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                    decoration: ShapeDecoration(
                                      color: Color.fromRGBO(255, 255, 255, 0.7),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 3,
                                          color: boolLigacao
                                              ? Color(0xFF006400)
                                              : Color(0xFFFF0000),
                                        ),
                                      ),
                                    ),
                                    child: Align(
                                      child: Text(
                                        'Ligação',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: boolLigacao
                                              ? Color(0xFF006400)
                                              : Color(0xFFFF0000),
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05,
                                          fontFamily: 'Libre Franklin',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Container(
                                    /*Indicador de dados enviados*/
                                    width: MediaQuery.of(context).size.width *
                                        0.48,
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                    decoration: ShapeDecoration(
                                      color: Color.fromRGBO(255, 255, 255, 0.7),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 3,
                                          color: boolDados
                                              ? Colors.blueAccent
                                              : Color(0xFF686B69),
                                        ),
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Dados',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: boolDados
                                              ? Colors.blueAccent
                                              : Color(0xFF686B69),
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05,
                                          fontFamily: 'Libre Franklin',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Stack(
                                /*Caixa geral da área de mensagem*/
                                children: [
                                  Container(
                                    /*Caixa grande da mensagem, onde mostra a mensagem*/
                                    width: MediaQuery.of(context).size.width *
                                        0.98,
                                    height: MediaQuery.of(context).size.height *
                                        0.45,
                                    decoration: ShapeDecoration(
                                      //color: Color(0xFFFFFEFE),
                                      color: Color.fromRGBO(255, 255, 255, 0.7),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(width: 2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 50, left: 10),
                                      child: SingleChildScrollView(
                                        child: texto_recebido == ''
                                            ? Padding(
                                                padding: EdgeInsets.only(
                                                    top: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.024),
                                                child: Text(
                                                  inicial,
                                                  style: TextStyle(
                                                    color: Color(0xFF5B5B5B),
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.025,
                                                  ),
                                                ),
                                              )
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                    top: MediaQuery.of(context)
                                                                .size
                                                                .height <
                                                            1000
                                                        ? 0
                                                        : 30),
                                                child: Text(
                                                  texto_recebido,
                                                  //luisiadas,
                                                  style: TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.025,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    /*Caixa pequena da mensagem (titulo)*/
                                    width: MediaQuery.of(context).size.width *
                                        0.98,
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    decoration: ShapeDecoration(
                                      //color: Colors.white,
                                      color: Color.fromRGBO(255, 255, 255, 0.7),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(width: 2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        'Mensagem',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.035,
                                          fontFamily: 'Libre Franklin',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
