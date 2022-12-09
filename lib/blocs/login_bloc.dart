// @dart=2.9
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scrumpoker/models/provider_app.dart';
import 'package:scrumpoker/models/usuario.dart';
import 'package:scrumpoker/services/firebase_service.dart';
import 'package:scrumpoker/utils/api_response.dart';
import 'package:scrumpoker/utils/simple_bloc.dart';

class LoginBloc extends SimpleBloc<bool> {

  Future<ApiResponse> login(BuildContext context, Usuario usuarioLogin, ProviderApp providerApp) async {
    add(true);
    ApiResponse response = await FirebaseService().login(context, usuarioLogin, providerApp);
    add(false);
    return response;
  }

  Future<ApiResponse> loginGoogle(BuildContext context, ProviderApp providerApp) async {
    ApiResponse response = await FirebaseService().loginGoogle(context, providerApp);
    return response;
  }

}
