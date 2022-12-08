// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrumpoker/models/app_model.dart';
import 'package:scrumpoker/models/sala.dart';
import 'package:scrumpoker/models/usuario.dart';
import 'package:scrumpoker/models/votacao.dart';
import 'package:scrumpoker/pages/home/cadastro_sala_page.dart';
import 'package:scrumpoker/pages/home/votacao_page.dart';
import 'package:scrumpoker/services/firebase_service.dart';
import 'package:scrumpoker/utils/nav.dart';
import 'package:scrumpoker/utils/snack.dart';
import 'package:scrumpoker/widgets/app_button.dart';
import 'package:scrumpoker/widgets/app_text.dart';
import 'package:scrumpoker/widgets/text_error.dart';

/// Widget que representa a tela de votação
class DashboardPage extends StatefulWidget {
  const DashboardPage({Key key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  /// Campo de código de convite
  final _controllerCodConvite = TextEditingController();

  /// Obtém usuário logado
  Usuario usuario;

  @override
  void initState() {
    super.initState();
    // Obtém usuário logado
    usuario = Provider.of<AppModel>(context, listen: false).usuario;
  }

  @override
  Widget build(BuildContext context) {
    // Obtém usuário logado
    Usuario usuario = Provider.of<AppModel>(context, listen: false).usuario;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: AppButton(
            'Cadastrar nova sala',
            onPressed: () => _onClickCadastrarNovaSala(context),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            'Utilizar código de convite',
            onPressed: () => _showDialog(context),
          ),
        ),
        Expanded(
          child: _listaSalas(context, usuario),
        ),
      ],
    );
  }

  /// Monta lista de salas
  Widget _listaSalas(BuildContext context, Usuario usuario) {
    // Monta lista de acordo com o stream da coleção de salas
    return StreamBuilder<QuerySnapshot>(
      // Busca todas as salas por enquanto, depois vejo como melhorar
      stream: FirebaseService().salasStream.where('hashCriador', isEqualTo: usuario.hash).orderBy('descricao').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const TextError("Não foi possível buscar as salas");
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Text("Nenhuma sala encontrada até o momento"),
          );
        }

        final documentsSalas = snapshot.data.docs;

        final documentsSalasVinculadasUsuario = documentsSalas.where((sala) => Sala.fromMap(sala.data()).hashsParticipantes.contains(usuario.hash)).toList();
        if (documentsSalasVinculadasUsuario.isEmpty) {
          return const Center(
            child: Text(
              'Você ainda não tem vínculo com nenhuma sala.\n\nCrie uma sala e covide seus colegas do time através do código da sala ou aplique o código de convite recebido.',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'RobotoMono'

              ),
            ),
          );
        }

        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: double.infinity,
                child: ListView.builder(
                  itemCount: documentsSalasVinculadasUsuario != null ? documentsSalasVinculadasUsuario.length : 0,
                  itemBuilder: (context, index) {
                    Sala sala = Sala.fromMap(documentsSalasVinculadasUsuario[index].data());
                    return CardSalaDashboard(
                      sala: sala,
                      usuario: usuario,
                      snapSala: documentsSalasVinculadasUsuario[index],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Abre dialog para digitação do convite
  void _showDialog(BuildContext context) async {
    _controllerCodConvite.text = '';
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Utilizar convite'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                AppText(
                  "Código de sala",
                  "Informe o seu código",
                  controller: _controllerCodConvite,
                  keyboardType: TextInputType.text,
                  action: TextInputAction.done,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Utilizar'),
              onPressed: () => _validarCodigoConvite(context),
            ),
          ],
        );
      },
    );
  }

  /// Valida código de convite
  void _validarCodigoConvite(BuildContext context) {
    var codigoConvite = _controllerCodConvite.text;
    if (codigoConvite.isNotEmpty) {
      FirebaseService().utilizarConvite(context, codigoConvite, usuario.hash);
      pop(context);
    } else {
      Snack.show(context, "Convite inválido!");
    }
  }

  /// Função para cadastro de nova sala
  _onClickCadastrarNovaSala(BuildContext context) {
    push(context, const CadastroSalaPage());
  }
}

class CardSalaDashboard extends StatelessWidget {
  const CardSalaDashboard({
    Key key,
    @required this.sala,
    @required this.usuario,
    @required this.snapSala,
  }) : super(key: key);

  final Sala sala;
  final Usuario usuario;
  final DocumentSnapshot<Object> snapSala;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _abreVotacaoSala(
        context,
        sala,
        snapSala,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                sala.descricao ?? "Sem título",
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
              Text(
                "\n${sala.hashsParticipantes.length} participante(s)",
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Método responsável por redirecionar para a tela de votação
  ///
  /// Nesse ponto també é criado o vínculo entre sala e usuário
  void _abreVotacaoSala(BuildContext context, Sala sala, DocumentSnapshot snapshotSalaSelecionada) {
    // Obtém hash da sala
    String hashSala = snapshotSalaSelecionada.id;
    // Seta sala atual no provider
    Provider.of<AppModel>(context, listen: false).sala = sala;
    // Cria objeto Votacao
    Votacao votacao = Votacao(
      hashSala: hashSala,
      hashUsuario: usuario.hash,
    );
    // Vincula usuário a sala através da collection de votações
    FirebaseService().votacoesStream.doc('${hashSala}_${usuario.hash}').set(votacao.toMap());
    // Chama a tela de votação
    push(
      context,
      VotacaoPage(snapshotSala: snapshotSalaSelecionada),
    );
  }
}
