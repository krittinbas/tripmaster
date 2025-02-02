import 'package:tripmaster/auth/auth_service_forget.dart';

class ForgetPasswordController {
  final AuthService _authService = AuthService();

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }
}
