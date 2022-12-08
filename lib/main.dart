// @dart=2.9
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scrumpoker/models/app_model.dart';
import 'package:scrumpoker/pages/splash_page.dart';
import 'package:scrumpoker/utils/global_scaffold.dart';

/// Inicializa aplicativo
void main() async {
  // Isso é recomendado pelo FireFlutter para utilizar chamadas assíncronas dentro da main (Firebase.initializeApp())
  WidgetsFlutterBinding.ensureInitialized();
  // Chama o primeiro widget da árvore
  runApp(InicializadorFirebase());
}

/// Widget que representa a inicialização do Firebase
class InicializadorFirebase extends StatelessWidget {
  /// Executa a inicialização do Firebase fora do 'build'
  final Future<FirebaseApp> _initializacaoFirebase = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializacaoFirebase,
      builder: (BuildContext context, snapshot) {
        // Verifica se ocorreram erros ao inicializar o Firebase
        if (snapshot.hasError) {
          return Text('Ocorreu algum erro com a iniciaização do Firebase:\n${snapshot.error.toString()}');
        }
        // Se inicializou o Firebase com sucesso segue a vida...
        if (snapshot.connectionState == ConnectionState.done) {
          return App();
        }
        // Se não, fica aguardando...
        return CircularProgressIndicator();
      },
    );
  }
}

/// App que representa a raiz da navegação dos widgets
class App extends StatelessWidget {
  /// Principal widget da aplicação
  @override
  Widget build(BuildContext context) {
    // Mantém orientação apenas retrato
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Scrum Poker',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SplashPage(),
        builder: (_, Widget child) {
          return Scaffold(
            key: GlobalScaffold.instance.scaffoldKey,
            body: child,
          );
        },
      ),
    );
  }
}
