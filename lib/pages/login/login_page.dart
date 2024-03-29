// @dart=2.9
import 'dart:async';

import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrumpoker/blocs/login_bloc.dart';
import 'package:scrumpoker/models/provider_app.dart';
import 'package:scrumpoker/models/usuario.dart';
import 'package:scrumpoker/pages/login/cadastro_login_page.dart';
import 'package:scrumpoker/utils/alert.dart';
import 'package:scrumpoker/utils/api_response.dart';
import 'package:scrumpoker/utils/nav.dart';
import 'package:scrumpoker/widgets/app_button.dart';
import 'package:scrumpoker/widgets/app_text.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../home/home_page.dart';

/// Widget que representa a tela de login
class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// Declaração da classe principal do componente
class _LoginPageState extends State<LoginPage> {
  /// Chave para controlle do formulário
  final _formkey = GlobalKey<FormState>();

  /// Campo login
  final tLogin = TextEditingController();

  /// Campo senha
  final tSenha = TextEditingController();

  /// Define foco no campo senha
  final _focusSenha = FocusNode();

  /// Bloc
  final _bloc = LoginBloc();

  /// StreamController para a autenticação do Google
  final _streamControllerGoogleSigIn = StreamController<bool>();

  ProviderApp providerApp;

  @override
  void initState() {
    _streamControllerGoogleSigIn.add(false);
    providerApp = Provider.of<ProviderApp>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tLogin.text = '';
    tSenha.text = '';

    // Obtém o modo de brilho (escuro/claro)
    var brightness = MediaQuery.of(context).platformBrightness;
    // Widget inicial
    return MaterialApp(
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _body(brightness),
      ),
    );
  }

  _body(brightness) {
    return Center(
      child: Form(
        key: _formkey,
        child: Container(
          width: kIsWeb ? 500 : null,
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 20),
              //const FlutterLogo(size: 70),
              Image.asset(
                'assets/imagens/scrumpoker_icon.png',
                height: 130,
              ),
              const SizedBox(height: 20),
              AppText(
                'Login',
                'Digite o login',
                controller: tLogin,
                validator: _validateLogin,
                keyboardType: TextInputType.emailAddress,
                action: TextInputAction.next,
                nextFocus: _focusSenha,
                autoFocus: true,
              ),
              const SizedBox(height: 10),
              AppText(
                'Senha',
                'Digite a senha',
                controller: tSenha,
                password: true,
                validator: _validateSenha,
                keyboardType: TextInputType.visiblePassword,
                action: TextInputAction.done,
                focusNode: _focusSenha,
              ),
              const SizedBox(height: 10),
              // Validar login
              StreamBuilder<bool>(
                  stream: _bloc.stream,
                  initialData: false,
                  builder: (context, snapshot) {
                    return AppButton(
                      'Login',
                      onPressed: _onClickLogin,
                      showProgress: snapshot.data,
                    );
                  }),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              // Entrar com conta Google
              StreamBuilder<bool>(
                stream: _streamControllerGoogleSigIn.stream,
                initialData: false,
                builder: (context, snapshot) {
                  if (snapshot.data == false) {
                    return GoogleAuthButton(
                      style: const AuthButtonStyle(
                        height: kIsWeb ? 60 : null,
                      ),
                      text: 'Logar com Google',
                      onPressed: () => _onClickLoginGoogle(context),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              const SizedBox(height: 10),

              /// Novo cadastro
              Container(
                height: 46,
                margin: const EdgeInsets.only(top: 0),
                child: InkWell(
                  onTap: _onClickCadastrar,
                  child: const Text(
                    'Ou cadastre-se aqui',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _onClickLogin() async {
    bool formOk = _formkey.currentState.validate();
    if (!formOk) {
      return;
    }
    String email = tLogin.text;
    String senha = tSenha.text;
    Usuario usuarioLogin = Usuario(
      email: email,
      senha: senha,
    );
    ApiResponse response = await _bloc.login(context, usuarioLogin, providerApp);
    if (response.ok) {
      if (mounted) {
        push(context, const HomePage(), replace: true);
      }
    } else {
      if (mounted) {
        alert(context, response.msg);
      }
    }
  }

  _onClickLoginGoogle(BuildContext context) async {
    _streamControllerGoogleSigIn.add(true);
    ApiResponse response = await _bloc.loginGoogle(context, providerApp);
    if (response.ok) {
      if (mounted) {
        push(context, const HomePage(), replace: true);
      }
    } else {
      if (mounted) {
        alert(context, response.msg, callback: () {
          return _streamControllerGoogleSigIn.add(false);
        });
      }
    }
  }

  _onClickCadastrar() {
    push(context, const CadastroLoginPage(), replace: true);
  }

  String _validateLogin(String value) {
    if (value.isEmpty) {
      return 'Digite o texto';
    }
    return null;
  }

  String _validateSenha(String value) {
    if (value.isEmpty) {
      return 'Digite o texto';
    }
    if (value.length < 6) {
      return 'A senha deve conter pelo menos 6 dígitos. Verifique';
    }
    return null;
  }
}
