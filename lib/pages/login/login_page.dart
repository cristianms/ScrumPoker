import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
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

import '../home/home_page.dart';

/// Widget que representa a tela de login
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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

  late ProviderApp providerApp;

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

    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    return MaterialApp(
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(resizeToAvoidBottomInset: false, body: _body(brightness)),
    );
  }

  Widget _body(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? [const Color(0xFF0A1628), const Color(0xFF1C2B3A)] : [const Color(0xFFEEF2FF), const Color(0xFFF0F4FF)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: kIsWeb ? 0 : 24, vertical: 40),
          child: Form(
            key: _formkey,
            child: Container(
              width: kIsWeb ? 460 : double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF152032) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(child: Image.asset('assets/imagens/scrumpoker_icon.png', height: 90)),
                  const SizedBox(height: 16),
                  // Título
                  Center(
                    child: Text(
                      'Scrum Poker',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: isDark ? Colors.white : const Color(0xFF1A237E)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text('Faça login para continuar', style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.grey.shade500)),
                  ),
                  const SizedBox(height: 32),
                  // Campo e-mail
                  AppText(
                    'E-mail',
                    'Digite o seu e-mail',
                    controller: tLogin,
                    validator: _validateLogin,
                    keyboardType: TextInputType.emailAddress,
                    action: TextInputAction.next,
                    nextFocus: _focusSenha,
                    autoFocus: true,
                  ),
                  const SizedBox(height: 16),
                  // Campo senha
                  AppText(
                    'Senha',
                    'Digite a sua senha',
                    controller: tSenha,
                    password: true,
                    validator: _validateSenha,
                    keyboardType: TextInputType.visiblePassword,
                    action: TextInputAction.done,
                    focusNode: _focusSenha,
                  ),
                  const SizedBox(height: 24),
                  // Botão Login
                  StreamBuilder<bool>(
                    stream: _bloc.stream,
                    initialData: false,
                    builder: (context, snapshot) {
                      return AppButton('Login', onPressed: _onClickLogin, showProgress: snapshot.data ?? true);
                    },
                  ),
                  const SizedBox(height: 20),
                  // Separador
                  Row(
                    children: [
                      Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('ou', style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey.shade400)),
                      ),
                      Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Botão Google
                  StreamBuilder<bool>(
                    stream: _streamControllerGoogleSigIn.stream,
                    initialData: false,
                    builder: (context, snapshot) {
                      return _googleButton(isDark, snapshot.data ?? false);
                    },
                  ),
                  const SizedBox(height: 28),
                  // Cadastro
                  Center(
                    child: GestureDetector(
                      onTap: _onClickCadastrar,
                      child: RichText(
                        text: TextSpan(
                          text: 'Não tem uma conta? ',
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.grey.shade600),
                          children: [
                            TextSpan(
                              text: 'Cadastre-se',
                              style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _googleButton(bool isDark, bool loading) {
    const Color primary = Color(0xFF4285F4);
    const Color primaryDeep = Color(0xFF2A6DD9);
    final isEnabled = !loading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      constraints: const BoxConstraints(minHeight: kIsWeb ? 56 : 50),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isEnabled ? const LinearGradient(colors: [primary, primaryDeep], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
        color: isEnabled ? null : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: isDark ? 0.45 : 0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isEnabled ? () => _onClickLoginGoogle(context) : null,
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: kIsWeb ? 18 : 14),
            child: Center(
              child: loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                          child: const Center(
                            child: Text(
                              'G',
                              style: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Entrar com Google',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future _onClickLogin() async {
    var navigator = Navigator.of(context);
    bool formOk = _formkey.currentState?.validate() ?? false;
    if (!formOk) {
      return;
    }
    String email = tLogin.text;
    String senha = tSenha.text;
    Usuario usuarioLogin = Usuario(email: email, senha: senha);
    ApiResponse response = await _bloc.login(context, usuarioLogin, providerApp);
    if (response.ok ?? false) {
      if (mounted) {
        push(navigator, const HomePage(), replace: true);
      }
    } else {
      if (mounted) {
        alert(context, response.msg ?? 'Não foi possível realizar o login');
      }
    }
  }

  _onClickLoginGoogle(BuildContext context) async {
    _streamControllerGoogleSigIn.add(true);
    var navigator = Navigator.of(context);
    ApiResponse response = await _bloc.loginGoogle(context, providerApp);
    if (response.ok ?? false) {
      if (mounted) {
        push(navigator, const HomePage(), replace: true);
      }
    } else {
      if (context.mounted) {
        alert(
          context,
          response.msg ?? 'Não foi possível realizar o login',
          callback: () {
            return _streamControllerGoogleSigIn.add(false);
          },
        );
      }
    }
  }

  _onClickCadastrar() {
    var navigator = Navigator.of(context);
    push(navigator, const CadastroLoginPage(), replace: true);
  }

  String? _validateLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite o texto';
    }
    return null;
  }

  String? _validateSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite o texto';
    }
    if (value.length < 6) {
      return 'A senha deve conter pelo menos 6 dígitos. Verifique';
    }
    return null;
  }
}
