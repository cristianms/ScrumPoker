// @dart=2.9
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scrumpoker/firebase_options.dart';
import 'package:scrumpoker/models/provider_app.dart';
import 'package:scrumpoker/pages/splash_page.dart';
import 'package:scrumpoker/utils/global_scaffold.dart';

/// Inicializa aplicativo
void main() async {
  // Isso é recomendado pelo FireFlutter para utilizar chamadas assíncronas dentro da main (Firebase.initializeApp())
  WidgetsFlutterBinding.ensureInitialized();

  // Executa a inicialização do Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Chama o primeiro widget da árvore
  runApp(const App());
}

/// App que representa a raiz da navegação dos widgets
class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

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
        ChangeNotifierProvider(create: (_) => ProviderApp()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Scrum Poker',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashPage(),
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
