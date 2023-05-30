import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scrumpoker/models/provider_app.dart';
import 'package:scrumpoker/models/usuario.dart';
import 'package:scrumpoker/services/firebase_service.dart';
import 'package:scrumpoker/utils/api_response.dart';
import 'package:scrumpoker/utils/simple_bloc.dart';

/// Classe bloc para tela de login
class LoginBloc extends SimpleBloc<bool> {
  /// Login normal via e-mail e senha
  Future<ApiResponse> login(BuildContext context, Usuario usuarioLogin, ProviderApp providerApp) async {
    add(true);
    ApiResponse response = await FirebaseService().login(context, usuarioLogin, providerApp);
    add(false);
    return response;
  }

  /// Login via e-mail Google Auth
  Future<ApiResponse> loginGoogle(BuildContext context, ProviderApp providerApp) async {
    ApiResponse response = await FirebaseService().loginGoogle(context, providerApp);
    return response;
  }
}
