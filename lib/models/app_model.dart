// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:scrumpoker/models/sala.dart';
import 'package:scrumpoker/models/usuario.dart';

/// Classe que representa um modelo de dados que poderá ser acessado em toda a aplicação através do Provider
class AppModel with ChangeNotifier {
  /// Instância de usuário logado
  Usuario _usuario;
  /// Instância de sala
  Sala _sala;

  /// Obtém o usuário do Provider
  Usuario get usuario => _usuario;
  /// Obtém a sala do Provider
  Sala get sala => _sala;

  /// Atualiza o usuário persistido no Prodiver
  set usuario(Usuario value) {
    _usuario = value;
    // Notifica ouvintes
    notifyListeners();
  }
  /// Atualiza a sala persistido no Prodiver
  set sala(Sala value) {
    _sala = value;
    // Notifica ouvintes
    notifyListeners();
  }
}
