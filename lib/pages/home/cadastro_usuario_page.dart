// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scrumpoker/models/provider_app.dart';
import 'package:scrumpoker/blocs/cadastro_bloc.dart';
import 'package:scrumpoker/models/usuario.dart';
import 'package:scrumpoker/pages/home/home_page.dart';
import 'package:scrumpoker/utils/alert.dart';
import 'package:scrumpoker/utils/nav.dart';
import 'package:scrumpoker/utils/snack.dart';
import 'package:scrumpoker/widgets/app_button.dart';
import 'package:scrumpoker/widgets/app_text.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:scrumpoker/utils/imagem_utils.dart';

/// Widget que representa o formulário de alteração de dados interno
class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({Key? key}) : super(key: key);

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  /// Campo Nome
  final _tNome = TextEditingController();

  /// Campo E-mail
  final _tEmail = TextEditingController();

  /// Instância de objeto para captura de foto
  final picker = ImagePicker();

  // /// Objeto para armazenar a foto capturada
  // File? _image;

  /// Chave para acesso aos dados do formulário
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Objeto bloc para controle da ação 'Cadastrar'
  final _bloc = CadastroBloc();

  late ProviderApp providerApp;

  /// Inicializa estado
  @override
  void initState() {
    providerApp = Provider.of<ProviderApp>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Usuario usuario = Provider.of<ProviderApp>(context, listen: false).usuario;

    // Preenche os campos do formulário
    _tNome.text = usuario.nome ?? '';
    _tEmail.text = usuario.email ?? '';

    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          const SizedBox(height: 5),
          AppText(
            'Nome',
            'Informe o seu nome',
            controller: _tNome,
            validator: _validateNome,
            keyboardType: TextInputType.text,
            action: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          AppText(
            'E-mail',
            'Não é possível alterar o e-mail',
            controller: _tEmail,
            enable: false,
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
            },
          ),
        ],
      ),
    );
  }

  // Validador do campo Nome
  String? _validateNome(String? text) {
    if (text?.isEmpty ?? true) {
      return 'Informe o nome';
    }
    return null;
  }

  /// Método que atualiza os dados do usuário
  _onClickCadastrar(context) async {
    // Realiza a validação dor formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Monta objeto Usuario para persistência
    Usuario usuario = Usuario(
      nome: _tNome.text.trim(),
      email: _tEmail.text.trim(),
    );
    final response = await _bloc.cadastrar(context, usuario, providerApp);
    // Se a request for bem sucedida redireciona para a Home
    if (response.ok) {
      Snack.show(context, 'Informações atualizadas!');
      push(context, const HomePage(), replace: true);
    } else {
      alert(context, response.msg ?? '...');
    }
  }
}
