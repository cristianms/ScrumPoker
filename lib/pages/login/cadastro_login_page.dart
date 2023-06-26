import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrumpoker/blocs/cadastro_bloc.dart';
import 'package:scrumpoker/models/provider_app.dart';
import 'package:scrumpoker/models/usuario.dart';
import 'package:scrumpoker/utils/alert.dart';
import 'package:scrumpoker/utils/nav.dart';
import 'package:scrumpoker/widgets/app_button.dart';
import 'package:scrumpoker/widgets/app_text.dart';
import '../home/home_page.dart';
import 'login_page.dart';

/// Widget que representa o formulário de cadastro
class CadastroLoginPage extends StatefulWidget {
  const CadastroLoginPage({Key? key}) : super(key: key);

  @override
  State<CadastroLoginPage> createState() => _CadastroLoginPageState();
}

class _CadastroLoginPageState extends State<CadastroLoginPage> {
  final _tNome = TextEditingController();
  final _tEmail = TextEditingController();
  final _tSenha = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // File? _image;
  // final picker = ImagePicker();

  // Define foco no campo senha
  final _focusEmail = FocusNode();
  final _focusSenha = FocusNode();

  // Bloc
  final _bloc = CadastroBloc();

  late ProviderApp providerApp;

  @override
  void initState() {
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
    return WillPopScope(
        child: MaterialApp(
            theme: ThemeData(),
            darkTheme: ThemeData.dark(),
            home: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text('Cadastro'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: _body(context),
              ),
            )),
        onWillPop: () => _onClickVoltar(context));
  }

  _body(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          // InkWell(
          //   child: _getCircleAvatar(),
          //   onTap: () => _tirarFoto(),
          // ),
          // const SizedBox(height: 5),
          // const Center(
          //   child: Text('Clique na imagem para adicionar uma foto (opcional)',
          //       style: TextStyle(
          //         color: Colors.grey,
          //         fontSize: 12,
          //       )),
          // ),
          AppText(
            'Nome',
            'Informe o seu nome',
            controller: _tNome,
            validator: _validateNome,
            keyboardType: TextInputType.text,
            action: TextInputAction.next,
            autoFocus: true,
            nextFocus: _focusSenha,
          ),
          const SizedBox(height: 10),
          AppText(
            'E-mail',
            'Informe o seu e-mail',
            controller: _tEmail,
            validator: _validateLogin,
            keyboardType: TextInputType.emailAddress,
            action: TextInputAction.next,
            focusNode: _focusSenha,
            nextFocus: _focusEmail,
          ),
          const SizedBox(height: 10),
          AppText(
            'Senha',
            'Digite a senha',
            controller: _tSenha,
            password: true,
            validator: _validateSenha,
            keyboardType: TextInputType.number,
            action: TextInputAction.done,
            focusNode: _focusEmail,
          ),
          const SizedBox(height: 10),
          StreamBuilder<bool>(
              stream: _bloc.stream,
              initialData: false,
              builder: (context, snapshot) {
                return AppButton(
                  'Cadastrar',
                  onPressed: () => _onClickCadastrar(context),
                  showProgress: snapshot.data,
                );
              }),
//          AppButton(
//            "Cadastrar",
//            onPressed: () => _onClickCadastrar(context),
//          ),
          Container(
            height: 46,
            margin: const EdgeInsets.only(top: 10),
            // child: RaisedButton(
            //   color: Colors.white,
            child: TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 22,
                ),
              ),
              onPressed: () {
                _onClickVoltar(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  String? _validateNome(String? text) {
    if (text?.isEmpty ?? true) {
      return 'Informe o nome';
    }
    return null;
  }

  String? _validateLogin(String? text) {
    if (text?.isEmpty ?? true) {
      return 'Informe o e-mail';
    }
    return null;
  }

  String? _validateSenha(String? text) {
    if (text?.isEmpty ?? true) {
      return 'Informe a senha';
    }
    if (text!.length <= 2) {
      return 'Senha precisa ter mais de 2 números';
    }
    return null;
  }

  _onClickVoltar(context) {
    push(context, const LoginPage(), replace: true);
  }

  _onClickCadastrar(context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    String nome = _tNome.text.trim();
    String email = _tEmail.text.trim();
    String senha = _tSenha.text.trim();
    Usuario usuario = Usuario(
      nome: nome,
      email: email,
      senha: senha,
    );
    // final response = await _bloc.inserir(context, usuario, providerApp, file: _image);
    final response = await _bloc.inserir(context, usuario, providerApp, file: null);
    if (response.ok) {
      push(context, const HomePage(), replace: true);
    } else {
      alert(context, response.msg ?? '...');
    }
  }

  // _tirarFoto() async {
  //   final pickedFile = await picker.getImage(source: ImageSource.camera);
  //   setState(() {
  //     if (pickedFile != null) {
  //       _image = File(pickedFile.path);
  //     }
  //   });
  // }

  // _getCircleAvatar() {
  //   return Center(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: <Widget>[
  //         Container(
  //           width: 100,
  //           height: 100,
  //           decoration: BoxDecoration(
  //             shape: _image != null ? BoxShape.circle : BoxShape.rectangle,
  //             image: _getDecorationImage(),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // DecorationImage _getDecorationImage() {
  //   if (_image != null) {
  //     return DecorationImage(image: FileImage(_image!));
  //   }
  //   return const DecorationImage(fit: BoxFit.fill, image: AssetImage('assets/imagens/camera.png'));
  // }
}
