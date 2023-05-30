import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:scrumpoker/models/sala.dart';
import 'package:scrumpoker/services/firebase_service.dart';
import 'package:scrumpoker/utils/api_response.dart';
import 'package:scrumpoker/utils/simple_bloc.dart';

/// Classe bloc para realizar cadastro de Sala
class CadastroSalaBloc extends SimpleBloc<bool> {

  Future<ApiResponse> cadastrar(BuildContext context, Sala sala) async {
    add(true);
    ApiResponse response = await FirebaseService().cadastrarSala(context, sala);
    add(false);
    return response;
  }
}
