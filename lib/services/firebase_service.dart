// @dart=2.9
// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as path;
import 'package:scrumpoker/models/provider_app.dart';
import 'package:scrumpoker/models/sala.dart';
import 'package:scrumpoker/models/usuario.dart';
import 'package:scrumpoker/models/votacao.dart';
import 'package:scrumpoker/utils/api_response.dart';

class FirebaseService {
  /// Inicializa Google SignIn
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  /// Inicializa FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obtém as salas
  CollectionReference get salasStream => FirebaseFirestore.instance.collection('salas');

  /// Obtém as salas
  CollectionReference get votacoesStream => FirebaseFirestore.instance.collection('votacoes');

  /// Obtém os usuários
  CollectionReference get usuariosStream => FirebaseFirestore.instance.collection('usuarios');

  /// Obtém o usuário da collection/banco de dados através do uid
  Future<Usuario> getUsuarioCollectionByHash(uid) async {
    // Obtém o usuário encontrado relacionado ao uid da autenticação
    DocumentSnapshot snapshot = await usuariosStream.doc(uid).snapshots().first;
    // Converte snapshot recebida para tipo usuario
    return Usuario.fromMap(snapshot.data());
  }

  /// Obtém a sala da collection/banco de dados através do hash
  Future<Sala> getSalaCollectionByHash(String hashSala) async {
    // Obtém o snapshot da sala encontrada relacionada ao hash recebido
    DocumentSnapshot snapshot = await salasStream.doc(hashSala).snapshots().first;
    // Converte snapshot recebida para tipo sala
    return Sala.fromMap(snapshot.data());
  }

  /// Obtém a sala da collection/banco de dados através do hash
  Future<Votacao> getVotacaoCollectionByHash(String hashVotacao) async {
    // Obtém o snapshot da Votacao encontrada relacionada ao hash recebido
    DocumentSnapshot snapshot = await votacoesStream.doc(hashVotacao).snapshots().first;
    // Converte snapshot recebida para tipo Votacao
    return Votacao.fromMap(snapshot.data());
  }

  /// Obtém as salas da collection/banco de dados através do hash
  Future<List<Votacao>> getVotacaoCollectionByHashPart(String hashSala) async {
    QuerySnapshot qn = await votacoesStream.where('hashSala', isEqualTo: hashSala).snapshots().first;
    return qn.docs.map((item) => Votacao.fromMap(item.data())).toList();
  }

  /// Obtém as salas da collection/banco de dados através do hash
  Future<List<DocumentSnapshot>> getVotacaoDocumentsByHashPart(String hashSala) async {
    QuerySnapshot qn = await votacoesStream.where('hashSala', isEqualTo: hashSala).snapshots().first;
    return qn.docs.toList();
  }

  /// Método responsável pelo login padrão do app
  Future<ApiResponse> login(BuildContext context, Usuario usuarioLogin, ProviderApp providerApp) async {
    try {
      // Login no Firebase com login e senha
      UserCredential authResult = await _auth.signInWithEmailAndPassword(email: usuarioLogin.email, password: usuarioLogin.senha);
      // Obtém pbbjeto usuário do banco de dados
      Usuario usuario = await getUsuarioCollectionByHash(authResult.user.uid);
      // Notifica ouvintes
      providerApp.usuario = usuario;
      // Resposta genérica
      return ApiResponse.ok();
    } catch (error) {
      return ApiResponse.error(msg: 'Não foi possível fazer o login');
    }
  }

  /// Método responsável pelo login via GoogleSignIn
  Future<ApiResponse> loginGoogle(BuildContext context, ProviderApp providerApp) async {
    try {
      // Login com o Google - Abre janela para login no Google
      final GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      // Tendo o googleSignInAccount completamos a autenticação
      final GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;
      // Credenciais para o Firebase
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Login no Firebase
      UserCredential authResult = await _auth.signInWithCredential(authCredential);
      // Obtém objeto usuário do banco de dados
      Usuario usuario = await getUsuarioCollectionByHash(authResult.user.uid);
      // Se o usuário ainda não tiver registro na base, insere
      if (usuario == null) {
        // FirebaseUser retornado
        final User firebaseUser = authResult.user;
        // Inicializa objeto Usuario para persistir na base
        usuario = Usuario();
        usuario.hash = firebaseUser.uid;
        usuario.nome = firebaseUser.displayName;
        usuario.email = firebaseUser.email;
        usuario.urlFoto = firebaseUser.photoURL;
        // Insere um novo usuário na coleção de usuários
        FirebaseFirestore.instance.collection('usuarios').doc(usuario.hash).set(usuario.toMapWithoutPass());
      }
      // Notifica ouvintes
      providerApp.usuario = usuario;
      // Resposta genérica
      return ApiResponse.ok();
    } catch (error) {
      return ApiResponse.error(msg: 'Não foi possível fazer o login\n${error.toString()}');
    }
  }

  /// Método responsável por inserir um novo usuário
  Future<ApiResponse> inserir(BuildContext context, Usuario usuario, ProviderApp providerApp, {File file}) async {
    try {
      // Realiza o cadastro de um novo usuário no banco de dados
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha,
      );
      // FirebaseUser retornado
      final User firebaseUser = authResult.user;
      usuario.hash = firebaseUser.uid;
      // Não armazenar senha do usuário no db, deixar isso para o FirebaseAuth
      usuario.senha = null;
      // Caso o usuário tenha adicionado uma foto faz o upload e recebe o link
      if (file != null) {
        usuario.urlFoto = await FirebaseService.uploadFirebaseStorage(file);
      }
      // Insere um novo usuário na coleção de usuários
      FirebaseFirestore.instance.collection('usuarios').doc(usuario.hash).set(usuario.toMapWithoutPass());
      // Notifica ouvintes
      providerApp.usuario = usuario;
      // Resposta genérica
      return ApiResponse.ok(msg: 'Usuário criado com sucesso');
    } on PlatformException catch (err) {
      // Exception lançada pelo Firebase
      final mensagem = err.message ?? 'Ocorreu um erro verifique suas credenciais';
      return ApiResponse.error(msg: 'Erro ao criar um usuário.\n\n$mensagem');
    } catch (error) {
      // Exception genérica
      return ApiResponse.error(msg: 'Não foi possível criar um usuário.');
    }
  }

  Future<ApiResponse> cadastrar(BuildContext context, Usuario usuarioCadastro, ProviderApp providerApp, {File file}) async {
    try {
      // Atualiza usuário registrado no FirebaseAuth
      User firebaseUser = FirebaseAuth.instance.currentUser;
      // Atualiza no Firebase
      await firebaseUser.updateDisplayName(usuarioCadastro.nome);
      // Atualiza usuário na collection/banco de dados
      Usuario usuario = providerApp.usuario;
      usuario.nome = usuarioCadastro.nome;
      if (file != null) {
        usuario.urlFoto = await FirebaseService.uploadFirebaseStorage(file);
      }
      // Notifica ouvintes
      providerApp.usuario = usuario;
      // Resposta genérica
      return ApiResponse.ok(msg: 'Usuário criado com sucesso');
    } catch (error) {
      if (error is PlatformException) {
        return ApiResponse.error(msg: 'Erro ao criar um usuário.\n\n${error.message}');
      }
      return ApiResponse.error(msg: 'Não foi possível criar um usuário.');
    }
  }

  /// Realiza o upload do [file]
  static Future<String> uploadFirebaseStorage(File file) async {
    // Obtém path name da foto tirada
    String fileName = path.basename(file.path);
    // Obtém referência do FirebaseStorage
    final storageRef = FirebaseStorage.instance.ref().child(fileName);
    // Insere e obtém referência do objeto persistido no storage
    var task = await storageRef.putFile(file);
    // Obtém a url pública da imagem no servidor Firebase
    final String urlFoto = await task.ref.getDownloadURL();
    return urlFoto;
  }

  /// Realiza logout do usuário logado no app
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  /// Método resopnsável por persistir a sala
  ///
  /// Se a [hash] for null irá inserir uma nova, se não irá editar
  cadastrarSala(BuildContext context, Sala sala, String hash) async {
    try {
      if (hash != null) {
        await salasStream.doc(hash).update(sala.toMap());
      } else {
        await salasStream.doc().set(sala.toMap());
      }
      // Resposta genérica
      return ApiResponse.ok(msg: 'Sala alterada com sucesso');
    } catch (error) {
      if (error is PlatformException) {
        return ApiResponse.error(msg: 'Erro ao alterar a sala.\n\n${error.message}');
      }
      return ApiResponse.error(msg: 'Não foi possível alterar a sala.');
    }
  }

  /// Método responsável por excluir a sala
  deletar(BuildContext context, String hash) async {
    try {
      QuerySnapshot snapshotVotacoes = await votacoesStream.where('hashSala', isEqualTo: hash).get();
      for (DocumentSnapshot ds in snapshotVotacoes.docs) {
        ds.reference.delete();
      }
      // Deleta a collection através da hash recebida
      await salasStream.doc(hash).delete();
      // Resposta genérica
      return ApiResponse.ok(msg: 'Sala excluída com sucesso');
    } catch (error) {
      if (error is PlatformException) {
        return ApiResponse.error(msg: 'Erro ao excluir a sala.\n\n${error.message}');
      }
      return ApiResponse.error(msg: 'Não foi possível excluir a sala.');
    }
  }

  /// Método responsável por excluir a sala
  Future<ApiResponse<dynamic>> excluirVotacao(String hashSala, String hashUsuario) async {
    try {
      // Deleta a collection através das hashes recebidas
      await votacoesStream.doc('${hashSala}_$hashUsuario').delete();
      // Resposta genérica
      return ApiResponse.ok(msg: 'Sala excluída com sucesso');
    } catch (error) {
      if (error is PlatformException) {
        return ApiResponse.error(msg: 'Erro ao excluir a sala.\n\n${error.message}');
      }
      return ApiResponse.error(msg: 'Não foi possível excluir a sala.');
    }
  }

  /// Método responsável por fazer a utilização de um convite
  Future<StatusConvite> utilizarConvite(BuildContext context, String hashSala, String hashUsuario) async {
    assert(context != null);
    assert(hashSala != null);
    assert(hashUsuario != null);
    // Verifica se a sala contida no convite existe
    var isSalaExists = await salaExiste(hashSala);
    if (isSalaExists) {
      // Obtém a referencia da sala
      Sala sala = await getSalaCollectionByHash(hashSala);
      // Verifica se o usuário que está tentando utilizar o convite já está na collection
      bool isParticipanteSala = false;
      for (var hashSalaCorrente in sala.hashsParticipantes) {
        if (hashSalaCorrente == hashUsuario && isParticipanteSala == false) {
          // Usuário já é um participante da sala
          isParticipanteSala = true;
        }
      }
      // Se o usuário ainda não é participante, adiciona e atualiza no DB
      if (!isParticipanteSala) {
        // Adiciona o usuário que recebeu o convite aos participantes da sala
        sala.hashsParticipantes.add(hashUsuario);
        // Atualiza a sala com o novo participante no DB
        await salasStream.doc(hashSala).set(sala.toMap());
        return StatusConvite.conviteAceito;
      } else {
        return StatusConvite.jaPossuiEsteConvite;
      }
    } else {
      return StatusConvite.conviteInvalido;
    }
  }

  /// Verifica se a sala existe no DB
  Future<bool> salaExiste(String docID) async {
    bool exists = false;
    try {
      await salasStream.doc(docID).get().then((doc) {
        if (doc.exists) {
          exists = true;
        }
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

  /// Método responsável por registrar a votação
  Future<void> votar(BuildContext context, String hashSala, String hashUsuario, int nota) async {
    var hashVotacao = '${hashSala}_$hashUsuario';
    // Obtém votação
    Votacao votacao = await getVotacaoCollectionByHash(hashVotacao);
    votacao.nota = nota;
    // Atualiza na base
    await votacoesStream.doc(hashVotacao).update(votacao.toMap());
    // Snack.show(context, Text("Feito!!"));
    // Verifica resultados
    contabilizaVotacoes(hashSala);
  }

  /// Verifica todos os resultados
  Future<void> contabilizaVotacoes(String hashSala) async {
    // Obtém a referencia da sala
    Sala sala = await getSalaCollectionByHash(hashSala);
    List<Votacao> listaVotacoesSala = await getVotacaoCollectionByHashPart(hashSala);
    int qtdVotacoesConcluidas = listaVotacoesSala.where((element) => element.nota != null).length;

    if (sala.hashsParticipantes.length > qtdVotacoesConcluidas) {
      // print(' > Votacoes pendentes');
    } else if (sala.hashsParticipantes.length == qtdVotacoesConcluidas) {
      // print(' > Todos votaram');
      toggleVotacaoEncerrada(hashSala, true);
    }
  }

  /// Encerra votação e exibe notas
  Future<void> toggleVotacaoEncerrada(String hashSala, bool votacaoEncerrada) async {
    // Obtém sala do banco
    var sala = await getSalaCollectionByHash(hashSala);
    // Altera flag de votação encerrada para true
    sala.votacaoConcluida = votacaoEncerrada;
    // Atualiza no DB
    await salasStream.doc(hashSala).set(sala.toMap());
  }

  /// Encerra votação e exibe notas
  Future<void> resetarVotacoes(String hashSala) async {
    await toggleVotacaoEncerrada(hashSala, false);
    List<DocumentSnapshot> listaVotacoesSala = await getVotacaoDocumentsByHashPart(hashSala);
    for (var document in listaVotacoesSala) {
      var votacao = Votacao.fromMap(document.data());
      votacao.nota = null;
      await votacoesStream.doc(document.id).set(votacao.toMap());
    }
  }
}

enum StatusConvite {
  conviteAceito,
  jaPossuiEsteConvite,
  conviteInvalido,
}

extension StatusConviteExtension on StatusConvite {
  String get name => describeEnum(this);
  String get mensagem {
    switch (this) {
      case StatusConvite.conviteAceito:
        return 'Convite aceito com sucesso!';
      case StatusConvite.jaPossuiEsteConvite:
        return 'O usuário já é um participante da sala!';
        break;
      case StatusConvite.conviteInvalido:
        return 'Nenhuma sala relacionada ao convite!';
        break;
    }
    return '';
  }
}
//convite aceito
//ja possui
//não existe