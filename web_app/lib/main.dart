import 'package:flutter/material.dart';
import 'package:web_app/edit_pac_page.dart';
import 'package:web_app/login_page.dart';
import 'package:web_app/main_page.dart';
import 'package:web_app/paciente-page.dart';
import 'package:web_app/recuperar_pass_page.dart';
import 'package:web_app/edit_page.dart';
import 'package:get/get.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';



void main() {
  setUrlStrategy(PathUrlStrategy());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      /*Rotas para navegar entre páginas*/
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => Login_Page()),
        GetPage(name: '/recuperar', page: () => Recuperar_Page()),
        GetPage(name: '/main', page: () => Main_Page(), children: [
          GetPage(name: '/paciente', page: () => Paciente_Page(), children: [
            GetPage(name: '/edit_pac', page: () => Edit_Pac_Page()),
          ]),
        ]),
        GetPage(name: '/edit', page: () => Edit_Page()),
        GetPage(name: '/edit_pac', page: () => Edit_Pac_Page()),
      ],

    );
  }
}