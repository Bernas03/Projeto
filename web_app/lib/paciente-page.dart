import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:web_app/database/database_function.dart';
import 'database/database_classes.dart';

class Paciente_Page extends StatelessWidget {
  const Paciente_Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PacientePage(),
    );
  }
}

class PacientePage extends StatefulWidget {
  @override
  _PacientePageState createState() => _PacientePageState();
}

class _PacientePageState extends State<PacientePage> {
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

  /*Controller usado para fazer scroll no gráfico*/
  final ScrollController _scrollController = ScrollController();

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

  TextEditingController _controller_mensagem = TextEditingController();
  String _mensagem = '';

  @override
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

  /*Função que mostra um Alert Dialog com a condição e a descrição do paceinte*/
  void showAlertDialog(
      BuildContext context, String condicao, String descricao) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(condicao),
          content: Text(descricao),
        );
      },
    );
  }

  /*Vai buscar os dados recolhidos pelo sensor à BD, que estão em forma de string e converte para uma lista de doubles*/
  Future<List<double>> dadosEmLista() async {
    Sensor sensor = await apiService.fetchSensor(idSensorPaciente);
    List<int> listaDeInts = sensor.dados.split(',').map(int.parse).toList();
    List<double> listaDeDoubles =
        listaDeInts.map((int e) => e.toDouble()).toList();

    return listaDeDoubles;
  }

  /*Função que recebe uma lista de doubles e os converte em FlSpot, para serem introduzidos num gáfico*/
  List<FlSpot> _getFlSpots(List<double> values) {
    return values.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }

  /*Widget que cria um gráfico usando uma lista de doubles*/
  Widget createLineChart(List<double> values) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: _getFlSpots(values),
                isCurved: true,
                color: Colors.blue,
                barWidth: 2,
                belowBarData: BarAreaData(
                    show: false, color: Colors.blue.withOpacity(0.3)),
                dotData:
                    FlDotData(show: false), // Removendo os pontos dos valores
              ),
            ],
            minX: 0,
            maxX: values.length.toDouble(),
            minY: values.reduce((a, b) => a < b ? a : b),
            maxY: values.reduce((a, b) => a > b ? a : b),
          ),
        ),
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
                                              Get.offAllNamed('/');
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
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 80),
                      Column(
                        /*Coluna central*/
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
                          Row(
                            children: [
                              Text(
                                /*Nome do paciente*/
                                //'Nome do Paciente',
                                nomePaciente,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 32,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                              Text(
                                /*Codigo unico do paciente*/
                                //'codigo do paciente',
                                '($codigoPacinte)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(
                            /*Condição do paciente*/
                            //'Condiçao',
                            condicaoPaciente,
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
                          Row(
                            children: [
                              Container(
                                /*Botão consulta de dados*/
                                height:
                                    MediaQuery.of(context).size.height * 0.08,
                                width: MediaQuery.of(context).size.width * 0.12,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    /*Mostra o showAlertDialog() onde mostra um dialog com a condiçao e descrição do paciente*/
                                    showAlertDialog(context, condicaoPaciente,
                                        descricaoPaciente);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF19D5FF),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                  child: Text(
                                    'Consultar Informações',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Libre Franklin',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                /*Botão para editar dados do paciente*/
                                height:
                                    MediaQuery.of(context).size.height * 0.08,
                                width: MediaQuery.of(context).size.width * 0.12,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    /*Navega para a pagina de editar paciente*/
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    int id =
                                        await prefs.getInt("id_pacinte") ?? 0;
                                    await prefs.setInt("id_pacinte", id);
                                    Get.toNamed('/main/paciente/edit_pac');
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
                                    textAlign: TextAlign.center,
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
                          SizedBox(height: 20),
                          Stack(
                            /*Caixa geral da área de mensagem*/
                            children: [
                              Container(
                                /*Caixa grande da mensagem, funciona tambem como textfield para o user introduzir uma mensagem*/
                                width: MediaQuery.of(context).size.width * 0.3,
                                height:
                                    MediaQuery.of(context).size.height * 0.45,
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
                                      controller: _controller_mensagem,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Escreva aqui uma mensagem este paciente',
                                        hintMaxLines:
                                            300, // Define o número máximo de linhas para o hintText
                                        hintStyle: TextStyle(
                                          color: Color(0xFF5B5B5B),
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
                                /*Caixa pequena da mensagem (titulo)*/
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
                                        'Mensagem para o paciente',
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
                                            /*Atualiza a mensagem do paciente na BD*/
                                            if (_controller_mensagem.text !=
                                                '') {
                                              _mensagem =
                                                  _controller_mensagem.text;
                                              Mensagem sendMensagem;
                                              int maiorId = 0;
                                              bool verify = false;
                                              for (int id = 1;; id++) {
                                                try {
                                                  Mensagem mensagem =
                                                      await apiService
                                                          .fetchMensagem(id);
                                                  if (mensagem.idPaciente ==
                                                          idPaciente &&
                                                      mensagem.idCuidador ==
                                                          idLogado) {
                                                    sendMensagem = Mensagem(
                                                        id: mensagem.id,
                                                        idCuidador: idLogado,
                                                        idPaciente: idPaciente,
                                                        mensagem: _mensagem);
                                                    try {
                                                      await apiService
                                                          .updateMensagem(
                                                              mensagem.id,
                                                              sendMensagem);
                                                      verify = true;
                                                    } catch (e) {
                                                      print('erro no update');
                                                    }
                                                  }
                                                  if (mensagem.id > maiorId) {
                                                    maiorId = mensagem.id;
                                                  }
                                                } catch (e) {
                                                  print('fetch');
                                                  break;
                                                }
                                              }
                                              if (verify == false) {
                                                sendMensagem = Mensagem(
                                                    id: maiorId + 1,
                                                    idCuidador: idLogado,
                                                    idPaciente: idPaciente,
                                                    mensagem: _mensagem);
                                                await apiService.createMensagem(
                                                    sendMensagem);
                                              }
                                              _controller_mensagem.clear();
                                              Get.offAllNamed('/');
                                              Get.toNamed('/main/paciente/');
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(
                                                0xFF19D5FF), // Cor de fundo
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
                      ),
                      SizedBox(width: 80),
                      Column(
                        /*Coluna da esquerda*/
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            /*Gráfico dos dados de ECG recolhidos pelo sensor*/
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: MediaQuery.of(context).size.height * 0.45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1),
                            ),
                            child: FutureBuilder<List<double>>(
                              future:
                                  dadosEmLista(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (snapshot.hasData) {
                                  if (snapshot.data!.length < 10) {
                                    return Center(
                                        child: Text('Sem dados a mostrar'));
                                  } else {
                                    double containerWidth =
                                        18.0 * snapshot.data!.length;
                                    return Scrollbar(
                                      controller: _scrollController,
                                      thumbVisibility: true,
                                      interactive: true,
                                      scrollbarOrientation:
                                          ScrollbarOrientation.bottom,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: _scrollController,
                                        child: Container(
                                          width:
                                              containerWidth, // Defina um valor adequado aqui
                                          child:
                                              createLineChart(snapshot.data!),
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  return Center(
                                      child: Text('No data available'));
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 40),
                          Container(
                            /*Botão de apagar paciente*/
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: MediaQuery.of(context).size.width * 0.23,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                /*Mostra um dialog de confirmação de eliminação de paciente, apos confirmar elimina um paciente permanentemente e navega para a pagina principal*/
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Tem a certeza?'),
                                      content: Text(
                                          'Ao eliminar o paciente perderá todos os dados do mesmo!'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Não'),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Fecha o dialogo
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Sim'),
                                          onPressed: () async {
                                            Navigator.of(context)
                                                .pop(); // Fecha o dialogo
                                            await apiService
                                                .deletePaciente(idPaciente);
                                            for (int id = 1;; id++) {
                                              try {
                                                Mensagem mensagem =
                                                    await apiService
                                                        .fetchMensagem(id);
                                                if (mensagem.idPaciente ==
                                                    idPaciente) {
                                                  await apiService
                                                      .deleteMensagem(id);
                                                }
                                              } catch (e) {
                                                print('fetch');
                                                break;
                                              }
                                            }
                                            Get.offAllNamed('/');
                                            Get.toNamed('/main');
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFF82424),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Text(
                                'Eliminar paciente permanentemente?',
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
}
