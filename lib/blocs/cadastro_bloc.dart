// @dart=2.9
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scrumpoker/models/usuario.dart';
import 'package:scrumpoker/services/firebase_service.dart';
import 'package:scrumpoker/utils/api_response.dart';
import 'package:scrumpoker/utils/simple_bloc.dart';

class CadastroBloc extends SimpleBloc<bool> {

//  Future<ApiResponse> autenticar() async {
//    add(null);
//    FirebaseUser usuario = await FirebaseAuth.instance.currentUser();
//    add(false);
//    return response;
//  }

  Future<ApiResponse> inserir(BuildContext context, Usuario usuario, {File file}) async {
    add(true);
    ApiResponse response = await FirebaseService().inserir(context, usuario, file: file);
    add(false);
    return response;
  }

  Future<ApiResponse> cadastrar(BuildContext context, Usuario usuario, {File file}) async {
    add(true);
    ApiResponse response = await FirebaseService().cadastrar(context, usuario, file: file);
    add(false);
    return response;
  }

}
