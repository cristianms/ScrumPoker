import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrumpoker/models/provider_app.dart';
import 'package:scrumpoker/models/sala.dart';
import 'package:scrumpoker/models/usuario.dart';
import 'package:scrumpoker/models/votacao.dart';
import 'package:scrumpoker/pages/home/cadastro_sala_page.dart';
import 'package:scrumpoker/services/firebase_service.dart';
import 'package:scrumpoker/utils/nav.dart';
import 'package:scrumpoker/widgets/app_button.dart';
import 'package:scrumpoker/widgets/text_error.dart';
import 'package:share_plus/share_plus.dart';

/// Widget que representa a tela de votação
///
/// Recebe por parâmetro o [DocumentSnapshot] da sala atual, foi feito dessa forma para termos
/// acesso ao id que vai possibilitar a alteração da sala
class VotacaoPage extends StatefulWidget {
  /// Snapshot da sala
  final DocumentSnapshot<Map<String, dynamic>> snapshotSala;

  /// Construtor que recebe o snapshot
  const VotacaoPage({super.key, required this.snapshotSala});

  @override
  State<VotacaoPage> createState() => _VotacaoPageState();
}

enum StatusStream { carregando, conectado, semDados, erro, salaExcluida }

class _VotacaoPageState extends State<VotacaoPage> with WidgetsBindingObserver {
  /// Objeto Sala para a conversão de snashot
  late Sala sala;

  /// Objeto Sala para a conversão de snashot
  late Sala salaProvider;

  /// Usuario logado
  late Usuario usuario;

  late ScaffoldMessengerState messenger;
  late NavigatorState navigator;

  /// Usuario logado
  var statusStream = StatusStream.carregando;

  var isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // Converte map de dados do snapshot para objeto Sala
    sala = Sala.fromMap(widget.snapshotSala.data() ?? {});
    // Obtém usuário logado
    usuario = Provider.of<ProviderApp>(context, listen: false).usuario!;
    // Obtém sala atual
    salaProvider = Provider.of<ProviderApp>(context, listen: false).sala!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    messenger = ScaffoldMessenger.of(context);
    navigator = Navigator.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(sala),
      body: StreamBuilder(
        stream: FirebaseService().salasStream.doc(widget.snapshotSala.id).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Sala salaStream = Sala(descricao: '...');
          // Se não tiver dados ou ocorrer erro
          statusStream = StatusStream.carregando;
          if (!snapshot.hasData) {
            statusStream = StatusStream.semDados;
          } else if (snapshot.hasError) {
            statusStream = StatusStream.erro;
          } else if (snapshot.data != null && snapshot.data.data() == null) {
            statusStream = StatusStream.salaExcluida;
          } else {
            // Obtém a snapshot da sala
            salaStream = Sala.fromMap(snapshot.data.data());
            statusStream = StatusStream.conectado;
          }

          return Padding(padding: const EdgeInsets.all(8), child: _body(context, salaStream));
        },
      ),
    );
  }

  /// Monta a AppBar
  AppBar _appBar(Sala salaStream) {
    return AppBar(
      title: Text('Votação - ${salaStream.descricao}'),
      // Botões de actions no cabeçalho da tela
      actions: <Widget>[
        // Ação de compartilhar o identificador/código da sala
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: GestureDetector(
            onTap: () async {
              // var dynamicLink = await criaDynamicLink(hash: snapshotSala.id);
              SharePlus.instance.share(ShareParams(text: 'Código de participação de sala Scrum:\n${widget.snapshotSala.id}', subject: 'Código de sala - ScrumPoker'));
            },
            child: const Icon(Icons.share, size: 26.0),
          ),
        ),
        // Ações diversas
        PopupMenuButton<String>(
          onSelected: _onSelect,
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(value: 'copiarCodigoSala', child: Text('Copiar código da sala')),
              const PopupMenuItem<String>(value: 'editarSala', child: Text('Editar sala')),
              const PopupMenuItem<String>(value: 'apagarSala', child: Text('Excluir sala')),
            ];
          },
        ),
      ],
    );
  }

  Future<void> _onSelect(String value) async {
    switch (value) {
      case 'copiarCodigoSala':
        await FlutterClipboard.copy(widget.snapshotSala.id);
        if (mounted) {
          messenger.showSnackBar(const SnackBar(content: Text('Código da sala copiado!')));
        }
      case 'editarSala':
        var navigator = Navigator.of(context);
        push(navigator, CadastroSalaPage(snapshotSala: widget.snapshotSala));
      case 'apagarSala':
        final response = await FirebaseService().deletar(context, widget.snapshotSala.id);
        if (response.ok ?? false) {
          if (mounted) {
            navigator.pop();
            messenger.showSnackBar(const SnackBar(content: Text('Sala excluída')));
          }
        }
    }
  }

  /// Monta esqueleto da tela (3 grids)
  Widget _body(BuildContext context, Sala salaStream) {
    if (statusStream == StatusStream.carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (statusStream == StatusStream.erro) {
      return const Center(child: Text('Ocorreu algum erro no carregamento dos dados'));
    }
    if (statusStream == StatusStream.semDados) {
      return const Center(child: Text('Nã há dados para apresentar'));
    }
    if (statusStream == StatusStream.salaExcluida) {
      return const Center(child: Text('A sala pode ter sido excluída'));
    }
    // return Center(child: Text('A sala pode ter sido excluída'));
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        var navigator = Navigator.of(context);
        if (didPop) {
          return;
        }
        await _sairVotacao(context, widget.snapshotSala.id, usuario.hash!);
        navigator.pop();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Grid de notas
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Column(children: [_tituloCard('Selecione a nota'), const SizedBox(height: 6), _gridNotas()]),
            ),
          ),

          const SizedBox(height: 8),

          // Grid de participantes
          Expanded(
            child: Card(child: Column(children: [_tituloCard('Participantes em votação'), _gridParticipantesENotas(salaStream)])),
          ),

          const SizedBox(height: 8),

          // Status da votação
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(salaStream.votacaoConcluida == false ? 'Aguardando todos votarem...' : 'Votação encerrada!', style: const TextStyle(fontSize: 15), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppButton(
                        'Finalizar',
                        disabled: salaStream.votacaoConcluida == true,
                        onPressed: () {
                          FirebaseService().toggleVotacaoEncerrada(widget.snapshotSala.id, true);
                        },
                      ),
                      const SizedBox(width: 10),
                      AppButton(
                        'Reiniciar',
                        disabled: !(salaStream.votacaoConcluida ?? false),
                        onPressed: () {
                          FirebaseService().resetarVotacoes(widget.snapshotSala.id);
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
    );
  }

  Center _tituloCard(String titulo) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(titulo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ),
    );
  }

  /// Montagem do grid de usuários
  Widget _gridParticipantesENotas(Sala salaStream) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseService().votacoesStream.where('hashSala', isEqualTo: widget.snapshotSala.id).snapshots().cast(),
          builder: (context, snapshot) {
            // Se não tiver dados ou ocorrer erro
            if (!snapshot.hasData) {
              return const Padding(padding: EdgeInsets.all(16.0), child: TextError('Nenhum registro encontrado até o momento'));
            }
            if (snapshot.hasError) {
              return const Padding(padding: EdgeInsets.all(16.0), child: TextError('Não foi possível buscar os dados'));
            }
            // Obtém a lista de snapshots de votacões
            List<DocumentSnapshot<Map<String, dynamic>>> listaSnapsVotacoes = snapshot.data!.docs;
            // Converte para lista de votações
            List<dynamic> votacoes = listaSnapsVotacoes.map((snapshot) => Votacao.fromMap(snapshot.data() ?? {})).toList();

            return GridView.count(
              primary: false,
              padding: const EdgeInsets.all(8.0),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              crossAxisCount: 3,
              children: votacoes.map((votacao) => _itemGridUsuarios(votacao, salaStream)).toList(),
            );
          },
        ),
      ),
    );
  }

  /// Montagem do item do grid de usuários
  Widget _itemGridUsuarios(Votacao votacao, Sala salaStream) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseService().usuariosStream.doc(votacao.hashUsuario).get().then((v) => v as DocumentSnapshot<Map<String, dynamic>>),
      builder: (context, snapshot) {
        // Se não tiver dados ou ocorrer erro
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Padding(padding: EdgeInsets.all(16.0), child: TextError('Não foi possível buscar os dados'));
        }
        Usuario usuario = Usuario.fromMap(snapshot.data?.data() ?? {});
        return GestureDetector(
          onLongPress: () => _dialogRemoverParticipante(context, usuario),
          child: SizedBox(
            height: 10,
            child: Column(
              children: [
                Text(_cortarNome(usuario.nome ?? ''), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      CircleAvatar(backgroundImage: NetworkImage(usuario.urlFoto ?? ''), backgroundColor: Colors.transparent),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 0.1),
                            color: votacao.nota != null ? Colors.lightGreen : Colors.redAccent,
                          ),
                          child: Center(child: _nota(votacao, salaStream)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _dialogRemoverParticipante(BuildContext context, Usuario usuario) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remover participante'),
          content: SingleChildScrollView(child: Text('Tem certeza que deseja remover ${usuario.nome} da sala?')),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                navigator.pop();
              },
            ),
            TextButton(
              child: const Text('Remover da sala'),
              onPressed: () {
                FirebaseService().excluirVotacao(widget.snapshotSala.id, usuario.hash!);
                navigator.pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Sair da votação
  Future<void> _sairVotacao(BuildContext context, String hashSala, String hashUsuario) async {
    // Remove participante da sala
    await FirebaseService().excluirVotacao(hashSala, hashUsuario);
  }

  String _cortarNome(String s) {
    if (s.length > 8) {
      return '${s.substring(0, 8)}...';
    }
    return s;
  }

  /// Montagem do grid de notas para votação
  Widget _gridNotas() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [_circularButton(0), _circularButton(1), _circularButton(2), _circularButton(3), _circularButton(5), _circularButton(8), _circularButton(13), _circularButton(21), _circularButton(34)],
    );
  }

  /// Montagem do componente de nota
  Widget _circularButton(int nota) {
    return SizedBox(
      height: 60,
      width: 60,
      child: GestureDetector(
        onTap: () => FirebaseService().votar(context, widget.snapshotSala.id, usuario.hash!, nota),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          elevation: 10,
          child: Center(
            child: Text(
              nota.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, color: isDarkMode ? Colors.white : Colors.black54, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  /// Text da nota
  Widget _nota(Votacao votacao, Sala salaStream) {
    if (votacao.nota == null) {
      return const Text('', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold));
    }
    if (salaStream.votacaoConcluida == true) {
      return Text(votacao.nota.toString(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold));
    }
    if (votacao.hashUsuario == usuario.hash) {
      return Text(votacao.nota.toString(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold));
    }
    return const Icon(Icons.done);
  }

  // /// Gera o DynamicLink com o código de convite da sala
  // Future<Uri> criaDynamicLink({@required String hash}) async {
  //   // Monta parâmetros para a criação da URL
  //   final DynamicLinkParameters parameters = DynamicLinkParameters(
  //     uriPrefix: 'https://mlls.page.link/',
  //     link: Uri.parse('https://mlls.page.link/?hash=$hash'),
  //     androidParameters: AndroidParameters(
  //       packageName: 'br.com.cristiandemellos.scrumpoker',
  //       minimumVersion: 1,
  //     ),
  //     iosParameters: IosParameters(
  //       bundleId: 'br.com.cristiandemellos.scrumpoker',
  //       minimumVersion: '1',
  //       appStoreId: '',
  //     ),
  //   );
  //   final link = await parameters.buildUrl();
  //   // Gera uma URL curta para
  //   final ShortDynamicLink shortenedLink =
  //       await DynamicLinkParameters.shortenUrl(
  //     link,
  //     DynamicLinkParametersOptions(
  //       shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable,
  //     ),
  //   );
  //   return shortenedLink.shortUrl;
  // }
}
