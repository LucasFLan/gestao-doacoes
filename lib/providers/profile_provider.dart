import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/exceptions/app_exceptions.dart';
import '../models/item_doacao.dart';
import '../models/usuario.dart';
import '../services/database_helper.dart';

final class ProfileState {
  const ProfileState({
    required this.usuario,
    required this.minhasDoacoes,
    this.erro,
  });

  final Usuario? usuario;
  final List<ItemDoacao> minhasDoacoes;
  final String? erro;

  const ProfileState.empty()
      : usuario = null,
        minhasDoacoes = const [],
        erro = null;
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState.empty()) {
    carregar();
  }

  static const String _usuarioPadraoId = 'default';

  Future<void> carregar() async {
    if (kIsWeb) {
      state = const ProfileState(
        usuario: Usuario(id: 'default', nome: 'Usuário', doacoesFeitas: 0, vidasSalvas: 0),
        minhasDoacoes: [],
      );
      return;
    }

    try {
      var usuario = await DatabaseHelper.getUsuario(_usuarioPadraoId);
      if (usuario == null) {
        usuario = Usuario(id: _usuarioPadraoId, nome: 'Usuário');
      }

      final doacoes = await DatabaseHelper.getItensSalvosLocalmente();

      state = ProfileState(
        usuario: usuario,
        minhasDoacoes: doacoes,
      );
    } on DatabaseException catch (e) {
      state = ProfileState(
        usuario: Usuario(id: _usuarioPadraoId, nome: 'Usuário'),
        minhasDoacoes: [],
        erro: e.message,
      );
    } catch (_) {
      state = const ProfileState(
        usuario: Usuario(id: 'default', nome: 'Usuário'),
        minhasDoacoes: [],
      );
    }
  }
}
