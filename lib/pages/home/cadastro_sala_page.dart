// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final DocumentSnapshot snapshotSala;

  const CadastroSalaPage({Key key, this.snapshotSala}) : super(key: key);

  @override
  State<CadastroSalaPage> createState() => _CadastroSalaPageState();
}

class _CadastroSalaPageState extends State<CadastroSalaPage> {
  /// Campo para a descrição
  final _tDescricao = TextEditingController();

  /// Chave para acesso ao formulário
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Bloc para controle de cadastro
  final _bloc = CadastroSalaBloc();

  /// Objeto Sala
  Sala sala = Sala();
  // Instância AppModel para provider
  ProviderApp appModel;

  @override
  void initState() {
    super.initState();
    // Se receber a snapshot é uma alteração, então carregamos os dados
    if (widget.snapshotSala != null) {
      sala = Sala.fromMap(widget.snapshotSala.data());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Inicializa o provider de AppModel
    appModel = Provider.of<ProviderApp>(context);

    if (widget.snapshotSala != null) {
      _tDescricao.text = sala.descricao;
    }

    var tituloAppBar = widget.snapshotSala != null ? 'Sala: ${sala.descricao}' : 'Nova sala';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(tituloAppBar),
        actions: sala == null
            ? null
            : <Widget>[
                // Padding(
                //   padding: EdgeInsets.only(right: 20.0),
                //   child: GestureDetector(
                //     onTap: () async {
                //       final response = await FirebaseService()
                //           .deletar(context, widget.snapshotSala?.id);
                //       if (response.ok) {
                //         pop(context);
                //         pop(context);
                //         Snack.show("Sala excluída");
                //       }
                //     },
                //     child: Icon(
                //       Icons.delete,
                //       size: 26.0,
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () async {
                      _onClickCadastrar(context);
                    },
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
          // SizedBox(height: 10),
          // StreamBuilder<bool>(
          //   stream: _bloc.stream,
          //   initialData: false,
          //   builder: (context, snapshot) {
          //     return AppButton(
          //       "Cadastrar",
          //       onPressed: () => _onClickCadastrar(context),
          //       showProgress: snapshot.data,
          //     );
          //   },
          // ),
          // Container(
          //   height: 46,
          //   margin: EdgeInsets.only(top: 10),
          //   // child: RaisedButton(
          //   //   color: Colors.white,
          //   child: ElevatedButton(
          //     // color: Colors.white,
          //     child: Text(
          //       "Cancelar",
          //       style: TextStyle(
          //         color: Colors.blue,
          //         fontSize: 22,
          //       ),
          //     ),
          //     onPressed: () {
          //       _onClickVoltar(context);
          //     },
          //   ),
          // ), // voltar
        ],
      ),
    );
  }

  String _validateDescricao(String text) {
    if (text.isEmpty) {
      return 'Informe o nome da sala';
    }
    return null;
  }

  // _onClickVoltar(context) {
  //   pop(context);
  // }

  _onClickCadastrar(context) async {
    String descricao = _tDescricao.text.trim();
    if (!_formKey.currentState.validate()) {
      return;
    }
    sala.descricao = descricao;
    // Se é uma sala nova
    if (widget.snapshotSala == null) {
      sala.hashCriador = appModel.usuario.hash;
      // O usuário criador é automaticamente adicionado a lista de participantes
      sala.hashsParticipantes = [appModel.usuario.hash];
    }
    final response = await _bloc.cadastrar(
      context,
      sala,
      widget.snapshotSala?.id,
    );
    if (response.ok) {
      pop(context);
      Snack.show(context, 'Dados cadastrados!');
    }
  }
}
