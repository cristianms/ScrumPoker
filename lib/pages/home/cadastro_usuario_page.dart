import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scrumpoker/models/app_model.dart';
import 'package:scrumpoker/blocs/cadastro_bloc.dart';
import 'package:scrumpoker/models/usuario.dart';
import 'package:scrumpoker/pages/home/home_page.dart';
import 'package:scrumpoker/utils/alert.dart';
import 'package:scrumpoker/utils/imagem_utils.dart';
import 'package:scrumpoker/utils/nav.dart';
import 'package:scrumpoker/utils/snack.dart';
import 'package:scrumpoker/widgets/app_button.dart';
import 'package:scrumpoker/widgets/app_text.dart';

/// Widget que representa o formulário de alteração de dados interno
class CadastroUsuarioPage extends StatefulWidget {
  @override
  _CadastroUsuarioPageState createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  /// Campo Nome
  final _tNome = TextEditingController();

  /// Campo E-mail
  final _tEmail = TextEditingController();

  /// Instância de objeto para captura de foto
  final picker = ImagePicker();

  /// Objeto para armazenar a foto capturada
  File _image;

  /// Chave para acesso aos dados do formulário
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Objeto bloc para controle da ação 'Cadastrar'
  final _bloc = CadastroBloc();

  /// Inicializa estado
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Usuario usuario = Provider.of<AppModel>(context, listen: false).usuario;

    // Preenche os campos do formulário
    this._tNome.text = usuario.nome;
    this._tEmail.text = usuario.email;

    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          InkWell(
            child: _getCircleAvatar(usuario.urlFoto),
            onTap: () => _tirarFotoReduzida(),
          ),
          SizedBox(height: 5),
          Center(
            child: Text(
              "Clique na imagem para atualizar a foto (opcional)",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          AppText(
            "Nome",
            "Informe o seu nome",
            controller: _tNome,
            validator: _validateNome,
            keyboardType: TextInputType.text,
            action: TextInputAction.next,
          ),
          SizedBox(height: 10),
          AppText(
            "E-mail",
            "Não é possível alterar o e-mail",
            controller: _tEmail,
            enable: false,
          ),
          SizedBox(height: 10),
          StreamBuilder<bool>(
            stream: _bloc.stream,
            initialData: false,
            builder: (context, snapshot) {
              return AppButton(
                "Cadastrar",
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
  String _validateNome(String text) {
    if (text.isEmpty) {
      return "Informe o nome";
    }
    return null;
  }

  /// Método que atualiza os dados do usuário
  _onClickCadastrar(context) async {
    // Realiza a validação dor formulário
    if (!_formKey.currentState.validate()) {
      return;
    }
    // Monta objeto Usuario para persistência
    Usuario usuario = Usuario(
      nome: _tNome.text.trim(),
      email: _tEmail.text.trim(),
    );
    final response = await _bloc.cadastrar(context, usuario, file: this._image);
    // Se a request for bem sucedida redireciona para a Home
    if (response.ok) {
      Snack.show("Informações atualizadas!");
      push(context, HomePage(), replace: true);
    } else {
      alert(context, response.msg);
    }
  }

  _tirarFotoReduzida() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.camera,
        imageQuality: 100,
        maxHeight: 300,
        maxWidth: 300);
    setState(() {
      // print()
      this._image = File(pickedFile.path);

//      final bytes = File(pickedFile.path).readAsBytesSync();
//      ImagemUtils.saveImageToPrefs(base64Encode(bytes));
      ImagemUtils.saveImageToPrefs(
          ImagemUtils.base64String(File(pickedFile.path).readAsBytesSync()));
    });
  }

  _getCircleAvatar(url) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: this._image != null || url != null
                  ? BoxShape.circle
                  : BoxShape.rectangle,
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: this._image != null
                      ? FileImage(this._image)
                      : (url != null
                          ? CachedNetworkImageProvider(url)
                          : AssetImage("assets/imagens/camera.png"))),
            ),
          ),
        ],
      ),
    );
  }
}
