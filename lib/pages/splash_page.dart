// @dart=2.9
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrumpoker/models/app_model.dart';
import 'package:scrumpoker/models/usuario.dart';
import 'package:scrumpoker/pages/home/home_page.dart';
import 'package:scrumpoker/pages/login/login_page.dart';
import 'package:scrumpoker/services/firebase_service.dart';
import 'package:scrumpoker/utils/nav.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  /// Instancia FirebaseService
  FirebaseService firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();

    // Delay de 3 segundos
    Future futureDelay = Future.delayed(Duration(seconds: 4));
    // Autenticação no Firebase
    User firebaseUser = FirebaseAuth.instance.currentUser;
    // Quando todas as future terminarem faz a validação
    Future.wait([futureDelay]).then((List values) {
      // Retorno da future que recupera o usuário autenticado
      if (firebaseUser != null) {
        // Tenta encontrar o usuário logado no banco de dados
        firebaseService
            .getUsuarioCollectionByHash(firebaseUser.uid)
            .then((Usuario usuario) => verificaUsuario(usuario));
      } else {
        push(context, LoginPage(), replace: true);
      }
    });
  }

  /// Verifica se usuário existe para direcionar para a pagina correta
  verificaUsuario(Usuario usuario) {
    if (usuario != null) {
      Provider.of<AppModel>(context, listen: false).usuario = usuario;
      push(context, HomePage(), replace: true);
    } else {
      push(context, LoginPage(), replace: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
//          child: CircularProgressIndicator(),
          child: FlutterLogo(
            size: 150,
          ),
        ),
      ],
    );
  }
}
