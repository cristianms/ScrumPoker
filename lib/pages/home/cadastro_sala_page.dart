import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrumpoker/blocs/cadastro_sala_bloc.dart';
import 'package:scrumpoker/models/provider_app.dart';
import 'package:scrumpoker/models/sala.dart';
import 'package:scrumpoker/utils/nav.dart';
import 'package:scrumpoker/utils/snack.dart';
import 'package:scrumpoker/widgets/app_text.dart';

/// Widget que representa o formulário de 'Sala'
class CadastroSalaPage extends StatefulWidget {
  final Sala? sala;

  const CadastroSalaPage({Key? key, this.sala}) : super(key: key);

  @override
  State<CadastroSalaPage> createState() => _CadastroSalaPageState();
}

class _CadastroSalaPageState extends State<CadastroSalaPage> {
  /// Chave para acesso ao formulário
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Campo para a descrição
  final _tDescricao = TextEditingController();

  /// Bloc para controle de cadastro
  final _cadastroSalaBloc = CadastroSalaBloc();

  /// Instância AppModel para provider
  late ProviderApp appModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _cadastroSalaBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Inicializa o provider de AppModel
    appModel = Provider.of<ProviderApp>(context);
    // Inicializa descrição da sala
    _tDescricao.text = widget.sala?.descricao ?? '';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.sala != null ? 'Sala: ${widget.sala?.descricao}' : 'Nova sala'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () async => _onClickCadastrar(context),
              child: const Icon(
                Icons.done,
                size: 26.0,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _body(context),
      ),
    );
  }

  _body(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          AppText(
            'Sala',
            'Informe o nome da sala',
            controller: _tDescricao,
            validator: _validateDescricao,
            keyboardType: TextInputType.text,
            action: TextInputAction.next,
          ),
        ],
      ),
    );
  }

  String? _validateDescricao(String? text) {
    if (text?.isEmpty ?? true) {
      return 'Informe o nome da sala';
    }
    return null;
  }

  Future<void> _onClickCadastrar(context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    var salaCadastro = Sala();
    // Se é uma sala nova
    if (widget.sala == null) {
      salaCadastro.hashCriador = appModel.usuario.hash!;
      // O usuário criador é automaticamente adicionado a lista de participantes
      salaCadastro.hashsParticipantes = [appModel.usuario.hash!];
    }
    // Seta a descrição da sala
    salaCadastro.descricao = _tDescricao.text.trim();
    // Realiza cadastro na API
    final response = await _cadastroSalaBloc.cadastrar(context, salaCadastro);
    if (response.ok) {
      pop(context);
      Snack.show(context, 'Dados cadastrados!');
    }
  }
}
