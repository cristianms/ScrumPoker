// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrumpoker/models/provider_app.dart';
import 'package:scrumpoker/models/sala.dart';
import 'package:scrumpoker/models/usuario.dart';
import 'package:scrumpoker/models/votacao.dart';
import 'package:scrumpoker/pages/home/votacao_page.dart';
import 'package:scrumpoker/services/firebase_service.dart';
import 'package:scrumpoker/utils/nav.dart';
import 'package:scrumpoker/widgets/text_error.dart';

/// Widget que representa a tela de votação
class DashboardPage extends StatefulWidget {
  const DashboardPage({Key key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  /// Obtém usuário logado
  Usuario usuario;

  @override
  void initState() {
    super.initState();
    // Obtém usuário logado
    usuario = Provider.of<ProviderApp>(context, listen: false).usuario;
  }

  @override
  Widget build(BuildContext context) {
    // Obtém usuário logado
    Usuario usuario = Provider.of<ProviderApp>(context, listen: false).usuario;
    return Column(
      children: [
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
      stream: FirebaseService()
          .salasStream
          .where(
            'hashsParticipantes',
            arrayContains: usuario.hash,
          )
          .orderBy('descricao')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const TextError("Não foi possível buscar as salas");
        }
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return const MensagemNenhumaSala();
        }

        final docsSalasVinculadasUsuario = snapshot.data.docs;

        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: double.infinity,
                child: ListView.builder(
                  itemCount: docsSalasVinculadasUsuario != null ? docsSalasVinculadasUsuario.length : 0,
                  itemBuilder: (context, index) {
                    Sala sala = Sala.fromMap(docsSalasVinculadasUsuario[index].data());
                    return CardSalaDashboard(
                      sala: sala,
                      usuario: usuario,
                      snapSala: docsSalasVinculadasUsuario[index],
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
}

class MensagemNenhumaSala extends StatelessWidget {
  const MensagemNenhumaSala({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          text: 'Você ainda não tem nenhum vínculo uma ',
          style: TextStyle(color: Colors.black54, fontSize: 22),
          children: <TextSpan>[
            TextSpan(
              text: 'sala.\n\n',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: 'Você pode criar uma nova sala, utilizando o botão abaixo, e convidar o seu time para o ',
            ),
            TextSpan(
              text: 'Planning Poker ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: 'enviando o ',
            ),
            TextSpan(
              text: 'código de convite ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: 'gerado pela sala.\n\n',
            ),
            TextSpan(
              text: 'Ou se você recebeu um código aplique-o utilizando o botão abaixo.',
            ),
          ],
        ),
      ),
    );
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
    Provider.of<ProviderApp>(context, listen: false).sala = sala;
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
