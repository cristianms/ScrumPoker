import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:scrumpoker/models/app_model.dart';
import 'package:scrumpoker/models/sala.dart';
import 'package:scrumpoker/models/usuario.dart';
import 'package:scrumpoker/models/votacao.dart';
import 'package:scrumpoker/pages/home/cadastro_sala_page.dart';
import 'package:scrumpoker/services/firebase_service.dart';
import 'package:scrumpoker/utils/nav.dart';
import 'package:scrumpoker/utils/snack.dart';
import 'package:scrumpoker/widgets/app_button.dart';
import 'package:scrumpoker/widgets/text_error.dart';
import 'package:share/share.dart';

/// Widget que representa a tela de votação
///
/// Recebe por parâmetro o [DocumentSnapshot] da sala atual, foi feito dessa forma para termos
/// acesso ao id que vai possibilitar a alteração da sala
class VotacaoPage extends StatefulWidget {
  /// Snapshot da sala
  final DocumentSnapshot snapshotSala;

  /// Construtor que recebe o snapshot
  VotacaoPage({this.snapshotSala});

  @override
  _VotacaoPageState createState() =>
      _VotacaoPageState(snapshotSala: this.snapshotSala);
}

enum StatusStream {
  CARREGANDO,
  CONECTADO,
  SEM_DADOS,
  ERRO,
  SALA_EXCLUIDA,
}

class _VotacaoPageState extends State<VotacaoPage> with WidgetsBindingObserver {
  /// Objeto snapshot da sala selecionada
  DocumentSnapshot snapshotSala;

  /// Objeto Sala para a conversão de snashot
  Sala sala;
  /// Objeto Sala para a conversão de snashot
  Sala salaProvider;

  /// Usuario logado
  Usuario usuario;

  /// Usuario logado
  var statusStream;

  /// Construtor
  _VotacaoPageState({this.snapshotSala});

  @override
  void initState() {
    super.initState();
    // Converte map de dados do snapshot para objeto Sala
    sala = Sala.fromMap(snapshotSala.data());
    // Obtém usuário logado
    usuario = Provider.of<AppModel>(context, listen: false).usuario;
    // Obtém sala atual
    salaProvider = Provider.of<AppModel>(context, listen: false).sala;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(sala),
      body:
          // Utiliza o stream de sala para ter acesso a sala em tempo real, para obter a prop "votacaoEncerrada"
          StreamBuilder(
        stream: FirebaseService().salasStream.doc(snapshotSala.id).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Sala salaStream = Sala(descricao: '...');
          // Se não tiver dados ou ocorrer erro
          statusStream = StatusStream.CARREGANDO;
          if (!snapshot.hasData) {
            statusStream = StatusStream.SEM_DADOS;
          } else if (snapshot.hasError) {
            statusStream = StatusStream.ERRO;
          } else if (snapshot.data != null && snapshot.data.data() == null) {
            statusStream = StatusStream.SALA_EXCLUIDA;
          } else {
            // Obtém a snapshot da sala
            salaStream = Sala.fromMap(snapshot.data.data());
            statusStream = StatusStream.CONECTADO;
          }

          print(' > statusStream:');
          print(statusStream);

          return Padding(
            padding: EdgeInsets.all(16),
            child: _body(context, salaStream),
          );
        },
      ),
    );
  }

  /// Monta a AppBar
  _appBar(Sala salaStream) {
    if (salaStream == null) {
      return AppBar(
        title: Text('Sala excluída'),
      );
    }
    return AppBar(
      title: Text('Votação - ${salaStream.descricao}'),
      // Botões de actions no cabeçalho da tela
      actions: <Widget>[
        // Ação de compartilhar o identificador/código da sala
        Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: GestureDetector(
            onTap: () async {
              var dynamicLink = await criaDynamicLink(hash: snapshotSala.id);
              Share.share(
                'Código de participação de sala Scrum:\n${snapshotSala.id}\n\nAplique este código no aplicativo ou clique no link $dynamicLink',
                subject: 'Código de sala - ScrumPoker',
              );
            },
            child: Icon(Icons.share, size: 26.0),
          ),
        ),
        // Ações diversas
        PopupMenuButton<String>(
          onSelected: _onSelect,
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: 'editarSala',
                child: Text('Editar'),
              ),
              PopupMenuItem<String>(
                value: 'apagarSala',
                child: Text('Apagar'),
              ),
            ];
          },
        ),
      ],
    );
  }

  void _onSelect(String value) async {
    switch (value) {
      case 'editarSala':
        push(
          context,
          CadastroSalaPage(
            snapshotSala: snapshotSala,
          ),
        );
        break;
      case 'apagarSala':
        final response =
            await FirebaseService().deletar(context, snapshotSala?.id);
        if (response.ok) {
          pop(context);
          Snack.show("Sala excluída");
        }
        break;
    }
  }

  /// Monta esqueleto da tela (3 grids)
  _body(BuildContext context, Sala salaStream) {
    if (statusStream == StatusStream.CARREGANDO) {
      return Center(child: CircularProgressIndicator());
    }
    if (statusStream == StatusStream.ERRO) {
      return Center(
          child: Text('Ocorreu algum erro no carregamento dos dados'));
    }
    if (statusStream == StatusStream.SEM_DADOS) {
      return Center(child: Text('Nã há dados para apresentar'));
    }
    if (statusStream == StatusStream.SALA_EXCLUIDA) {
      return Center(child: Text('A sala pode ter sido excluída'));
    }
    // return Center(child: Text('A sala pode ter sido excluída'));
    return WillPopScope(
      onWillPop: () => _sairVotacao(context, snapshotSala.id, usuario.hash),
      child: Container(
        child: Column(
          children: [
            // Grid de notas
            Expanded(
              flex: 2,
              child: Card(
                child: Column(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('Selecione a nota',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _gridNotas(),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // Grid de participantes
            Expanded(
              flex: 2,
              child: Card(
                child: Column(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Participantes em votação',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    _gridParticipantes(salaStream),
                  ],
                ),
              ),
            ),

            // Status da votação
            Expanded(
              flex: 2,
              child: Card(
                child: Column(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Status da votação',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        salaStream != null &&
                                salaStream.votacaoConcluida == false
                            ? 'Aguardando todos votarem...'
                            : 'Votação encerrada!',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppButton(
                          'Finalizar',
                          disabled: salaStream != null &&
                                  salaStream.votacaoConcluida == true
                              ? true
                              : false,
                          onPressed: () {
                            FirebaseService()
                                .toggleVotacaoEncerrada(snapshotSala.id, true);
                          },
                        ),
                        SizedBox(width: 10),
                        AppButton(
                          'Reiniciar',
                          disabled: salaStream != null &&
                                  salaStream.votacaoConcluida != null
                              ? !salaStream.votacaoConcluida
                              : false,
                          onPressed: () {
                            FirebaseService().resetarVotacoes(snapshotSala.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Montagem do grid de usuários
  Widget _gridParticipantes(Sala salaStream) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseService()
              .votacoesStream
              .where('hashSala', isEqualTo: snapshotSala.id)
              .snapshots(),
          builder: (context, snapshot) {
            // Se não tiver dados ou ocorrer erro
            if (!snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextError("Nenhum registro encontrado até o momento"),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextError("Não foi possível buscar os dados"),
              );
            }
            // Obtém a lista de snapshots de votacões
            List<DocumentSnapshot> listaSnapsVotacoes = snapshot.data.docs;
            // Converte para lista de votações
            List<dynamic> votacoes = listaSnapsVotacoes
                .map(
                  (snapshot) => Votacao.fromMap(snapshot.data()),
                )
                .toList();

            return GridView.count(
              primary: false,
              padding: EdgeInsets.all(8.0),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              crossAxisCount: 4,
              children: votacoes
                  .map(
                    (votacao) => _itemGridUsuarios(votacao, salaStream),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  /// Montagem do item do grid de usuários
  Widget _itemGridUsuarios(Votacao votacao, Sala salaStream) {
    return FutureBuilder(
      future: FirebaseService().usuariosStream.doc(votacao.hashUsuario).get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        // Se não tiver dados ou ocorrer erro
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextError("Não foi possível buscar os dados"),
          );
        }
        Usuario usuario = Usuario.fromMap(snapshot.data.data());
        return Container(
          height: 10,
          child: Column(
            children: [
              Container(
                // color: Colors.blue,
                child: Text(
                  _cortarNome('${usuario.nome}'),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      child: usuario.urlFoto != null
                          ? CircleAvatar(
                              backgroundImage:
                                  NetworkImage("${usuario.urlFoto}"),
                              backgroundColor: Colors.transparent,
                            )
                          : Image.asset("assets/imagens/usuario.png"),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 0.1,
                          ),
                          color: votacao.nota != null
                              ? Colors.lightGreen
                              : Colors.redAccent,
                        ),
                        child: Center(
                          child: _nota(votacao, salaStream),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Sair da votação
  Future<bool> _sairVotacao(
      BuildContext context, String hashSala, String hashUsuario) {
    // Vincula usuário a sala através da collection de votações
    FirebaseService().excluirVotacao(hashSala, hashUsuario);
    // Volta a tela anterior
    return pop(context);
  }

  String _cortarNome(String s) {
    if (s.length > 8) {
      return s.substring(0, 8) + '...';
    }
    return s;
  }

  /// Montagem do grid de notas para votação
  Widget _gridNotas() {
    return GridView.count(
      primary: false,
      padding: EdgeInsets.all(8.0),
      crossAxisSpacing: 3,
      mainAxisSpacing: 3,
      crossAxisCount: 6,
      children: [
        _circularButton(0),
        _circularButton(1),
        _circularButton(2),
        _circularButton(3),
        _circularButton(5),
        _circularButton(8),
        _circularButton(13),
        _circularButton(21),
        _circularButton(34),
      ],
    );
  }

  /// Montagem do componente de nota
  Widget _circularButton(int nota) {
    return RawMaterialButton(
      constraints: BoxConstraints(),
      elevation: 5.0,
      fillColor: Colors.blue[300],
      child: Text(
        nota.toString(),
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      padding: EdgeInsets.all(5.0),
      shape: CircleBorder(),
      onPressed: () =>
          FirebaseService().votar(context, snapshotSala.id, usuario.hash, nota),
    );
  }

  /// Text da nota
  Widget _nota(Votacao votacao, Sala salaStream) {
    if (votacao.nota == null) {
      return Text('',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold));
    }
    if (salaStream.votacaoConcluida == true) {
      return Text(votacao.nota.toString(),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold));
    }
    if (votacao.hashUsuario == usuario.hash) {
      return Text(votacao.nota.toString(),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold));
    }
    return Icon(Icons.done);
  }

  /// Gera o DynamicLink com o código de convite da sala
  Future<Uri> criaDynamicLink({@required String hash}) async {
    // Monta parâmetros para a criação da URL
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://mlls.page.link/',
      link: Uri.parse('https://mlls.page.link/?hash=$hash'),
      androidParameters: AndroidParameters(
        packageName: 'br.com.cristiandemellos.scrumpoker',
        minimumVersion: 1,
      ),
      iosParameters: IosParameters(
        bundleId: 'br.com.cristiandemellos.scrumpoker',
        minimumVersion: '1',
        appStoreId: '',
      ),
    );
    final link = await parameters.buildUrl();
    // Gera uma URL curta para
    final ShortDynamicLink shortenedLink =
        await DynamicLinkParameters.shortenUrl(
      link,
      DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable,
      ),
    );
    return shortenedLink.shortUrl;
  }
}
