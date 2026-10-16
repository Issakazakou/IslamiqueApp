import 'package:flutter/widgets.dart';

import 'app_strings.dart';
import 'services/auth_service.dart';

/// Texte d'erreur affiché à l'utilisateur pour une erreur de compte ou de synchronisation.
String authErrorText(BuildContext context, Object error) {
  if (error is AuthException) {
    return error.network ? context.tr('auth_err_network') : error.message;
  }
  return error.toString();
}
