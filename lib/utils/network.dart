import 'package:connectivity/connectivity.dart';

/// Método responsável por verificar a conexão com a internet
Future<bool> isNetworkOn() async {
  var conectividade = await (Connectivity().checkConnectivity());
  // Se não existir conexão alguma
  if (conectividade == ConnectivityResult.none) {
    return false;
  } else {
    // Caso esteja conectado
    return true;
  }
}