import 'package:flutter/cupertino.dart';
import 'package:scrumpoker/models/sala.dart';
import 'package:scrumpoker/models/usuario.dart';

/// Classe que representa um modelo de dados que poderá ser acessado em toda a aplicação através do Provider
class ProviderApp with ChangeNotifier {
  /// Instância de usuário logado
  late Usuario _usuario;

  /// Instância de sala
  late Sala _sala;

  /// Obtém o usuário do Provider
  Usuario get usuario => _usuario;

  /// Obtém a sala do Provider
  Sala get sala => _sala;

  /// Atualiza o usuário persistido no Provider
  set usuario(Usuario value) {
    _usuario = value;
    // Notifica ouvintes
    notifyListeners();
  }

  /// Atualiza a sala persistido no Provider
  set sala(Sala value) {
    _sala = value;
    // Notifica ouvintes
    notifyListeners();
  }
}
