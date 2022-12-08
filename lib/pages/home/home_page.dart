// @dart=2.9
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrumpoker/models/app_model.dart';
import 'package:scrumpoker/models/usuario.dart';
import 'package:scrumpoker/pages/home/cadastro_usuario_page.dart';
import 'package:scrumpoker/pages/home/dashboard_page.dart';
import 'package:scrumpoker/pages/login/login_page.dart';
import 'package:scrumpoker/services/firebase_service.dart';
import 'package:scrumpoker/utils/nav.dart';
import 'cadastro_sala_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin<HomePage> {
  /// Página selecionada no menu lateral
  int selectedIndex;

  /// Usuario logado
  Usuario usuario;

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedIndex = 0;
    });
    // Trata DynamicLinks
    //fetchLinkData();
  }

  // /// Obtém dados do DynamicLink, caso o app tenha sido aberto a partir de um link
  // void fetchLinkData() async {
  //   // Faz uma chamada para o link real do Firebase, pois ele chegou aqui encurtado por nós mesmos
  //   var link = await FirebaseDynamicLinks.instance.getInitialLink();
  //   // Caso o aplicativo tenha sido inicializado através do DynamicLink, faz a manipulação
  //   manipulaDadosLink(link);
  //   // Caso o aplicativo já esteja aberto e receba um DynamicLink, faz a manipulação
  //   FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
  //     manipulaDadosLink(dynamicLink);
  //   });
  // }

  // /// Obtém os parâmetros do DynamicLink recebido
  // void manipulaDadosLink(PendingDynamicLinkData data) {
  //   final Uri uri = data?.link;
  //   if (uri != null) {
  //     final queryParams = uri.queryParameters;
  //     if (queryParams.length > 0) {
  //       String hashSala = queryParams["hash"];
  //       _validarCodigoConviteAutomatico(context, hashSala);
  //     }
  //   }
  // }

  // /// Valida o código de convite
  // void _validarCodigoConviteAutomatico(BuildContext context, String hashSala) {
  //   if (hashSala.length > 0) {
  //     // Obtém usuário logado
  //     usuario = Provider.of<AppModel>(context, listen: false).usuario;
  //     FirebaseService().utilizarConvite(context, hashSala, usuario.hash);
  //   } else {
  //     Snack.show(context, "Convite inválido!");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    Usuario usuario = Provider.of<AppModel>(context, listen: true).usuario;

    List arrayTitles = ['Home', 'Meus dados'];
    List arrayPages = [const DashboardPage(), const CadastroUsuarioPage()];

    return Scaffold(
      appBar: AppBar(
        title: Text(arrayTitles[selectedIndex]),
      ),
      body: SafeArea(
        left: true,
        right: true,
        top: true,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: arrayPages[selectedIndex],
        ),
      ),
      drawer: SafeArea(
        child: Drawer(
          key: scaffoldKey,
          child: ListView(
            children: <Widget>[
              usuario != null ? _header(context, usuario) : Container(),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text("Home"),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedIndex = 0;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Meus dados"),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedIndex = 1;
                  });
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text("Logout"),
                onTap: () => _onClickLogout(context),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: "Cadastrar nova sala",
        onPressed: () => _onClickCadastrarNovaSala(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Cabeçalho do drawer menu
  UserAccountsDrawerHeader _header(BuildContext context, Usuario usuario) {
    return UserAccountsDrawerHeader(
      accountName: Text(usuario.nome ?? 'Vazio'),
      accountEmail: Text(usuario.email ?? 'Vazio'),
      currentAccountPicture: usuario.urlFoto != null
          ? CircleAvatar(
              // backgroundImage: NetworkImage(usuario.photoUrl),
              backgroundImage: CachedNetworkImageProvider(usuario.urlFoto),
            )
          : Image.asset("assets/imagens/usuario.png"),
    );
  }

  /// Função de logout
  _onClickLogout(BuildContext context) {
    // Logout do Firebase
    FirebaseService().logout();
    // Encerra página atual (Home)
    Navigator.pop(context);
    // Abre tela de login
    push(context, const LoginPage(), replace: true);
  }

  /// Função para cadastro de nova sala
  _onClickCadastrarNovaSala(BuildContext context) {
    push(context, const CadastroSalaPage());
  }
}
