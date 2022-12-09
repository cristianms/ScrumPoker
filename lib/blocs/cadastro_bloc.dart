// @dart=2.9
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scrumpoker/models/provider_app.dart';
import 'package:scrumpoker/models/usuario.dart';
import 'package:scrumpoker/services/firebase_service.dart';
import 'package:scrumpoker/utils/api_response.dart';
import 'package:scrumpoker/utils/simple_bloc.dart';

class CadastroBloc extends SimpleBloc<bool> {
  Future<ApiResponse> inserir(BuildContext context, Usuario usuario, ProviderApp providerApp, {File file}) async {
    add(true);
    ApiResponse response = await FirebaseService().inserir(context, usuario, providerApp, file: file);
    add(false);
    return response;
  }

  Future<ApiResponse> cadastrar(BuildContext context, Usuario usuario, ProviderApp providerApp, {File file}) async {
    add(true);
    ApiResponse response = await FirebaseService().cadastrar(context, usuario, providerApp, file: file);
    add(false);
    return response;
  }
}
