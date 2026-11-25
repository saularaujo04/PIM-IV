import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda o token JWT no armazenamento seguro do sistema
/// (Keystore no Android, Keychain no iOS).
class AuthService {
  static const _chave = 'jwt';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> lerToken() => _storage.read(key: _chave);
  Future<void> salvar(String token) => _storage.write(key: _chave, value: token);
  Future<void> limpar() => _storage.delete(key: _chave);
}
