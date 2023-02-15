// @dart=2.9
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrumpoker/models/provider_app.dart';
import 'package:scrumpoker/models/usuario.dart';
import 'package:scrumpoker/pages/home/home_page.dart';
import 'package:scrumpoker/pages/login/login_page.dart';
import 'package:scrumpoker/services/firebase_service.dart';
import 'package:scrumpoker/utils/nav.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  /// Instancia FirebaseService
  FirebaseService firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    // Delay de 1 segundo
    final futureDelay = Future.delayed(const Duration(seconds: 2));
    // Autenticação no Firebase
    final firebaseUser = FirebaseAuth.instance.currentUser;
    // Quando todas as future terminarem faz a validação
    Future.wait([futureDelay]).then((List values) {
      // Retorno da future que recupera o usuário autenticado
      if (firebaseUser != null) {
        // Tenta encontrar o usuário logado no banco de dados
        firebaseService.getUsuarioCollectionByHash(firebaseUser.uid).then((Usuario usuario) => verificaUsuario(usuario));
      } else {
        push(context, const LoginPage(), replace: true);
      }
    });
  }

  /// Verifica se usuário existe para direcionar para a pagina correta
  verificaUsuario(Usuario usuario) {
    if (usuario != null) {
      Provider.of<ProviderApp>(context, listen: false).usuario = usuario;
      push(context, const HomePage(), replace: true);
    } else {
      push(context, const LoginPage(), replace: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Image.asset(
            'assets/imagens/scrumpoker_icon.png',
            height: 290,
          ),
        ),
      ],
    );
  }
}
