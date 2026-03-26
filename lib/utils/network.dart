import 'package:connectivity_plus/connectivity_plus.dart';

/// MÃ©todo responsÃ¡vel por verificar a conexÃ£o com a internet
Future<bool> isNetworkOn() async {
  var conectividade = await (Connectivity().checkConnectivity());
  // Se nÃ£o existir conexÃ£o alguma
  if (conectividade.contains(ConnectivityResult.none)) {
    return false;
  } else {
    // Caso esteja conectado
    return true;
  }
}
