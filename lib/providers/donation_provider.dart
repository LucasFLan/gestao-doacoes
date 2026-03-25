import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/exceptions/app_exceptions.dart';
import '../models/item_doacao.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import 'app_providers.dart';

sealed class DonationFeedState {
  const DonationFeedState();
}

final class DonationFeedLoading extends DonationFeedState {
  const DonationFeedLoading();
}

final class DonationFeedLoaded extends DonationFeedState {
  const DonationFeedLoaded(this.itens, {this.veioDoCache = false});

  final List<ItemDoacao> itens;
  final bool veioDoCache;
}

final class DonationFeedError extends DonationFeedState {
  const DonationFeedError(this.mensagem);

  final String mensagem;
}

final donationFeedProvider =
    StateNotifierProvider<DonationFeedNotifier, DonationFeedState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return DonationFeedNotifier(api);
});

class DonationFeedNotifier extends StateNotifier<DonationFeedState> {
  DonationFeedNotifier(this._apiService)
      : super(const DonationFeedLoading());

  final ApiService _apiService;

  Future<void> carregarFeed() async {
    state = const DonationFeedLoading();

    try {
      final itens = await _apiService.buscarFeedDoacoes();
      state = DonationFeedLoaded(itens, veioDoCache: false);
    } on ApiException catch (e) {
      try {
        final itens = await DatabaseHelper.getItensSalvosLocalmente();
        state = DonationFeedLoaded(itens, veioDoCache: true);
      } on DatabaseException catch (dbEx) {
        state = DonationFeedError(
          'Não foi possível carregar: ${e.message}. Cache local: ${dbEx.message}',
        );
      }
    } catch (e) {
      state = DonationFeedError(
        e is AppException ? e.message : 'Erro inesperado: $e',
      );
    }
  }

  static const String _usuarioPadraoId = 'default';

  Future<void> cadastrarItem(ItemDoacao item) async {
    try {
      final itemLocal = item.copyWith(isLocalSync: true);
      await DatabaseHelper.insertItem(itemLocal);

      var usuario = await DatabaseHelper.getUsuario(_usuarioPadraoId);
      if (usuario == null) {
        usuario = Usuario(id: _usuarioPadraoId, nome: 'Usuário');
        await DatabaseHelper.insertOuAtualizarUsuario(usuario);
      }
      await DatabaseHelper.atualizarEstatisticasUsuario(
        usuarioId: _usuarioPadraoId,
        doacoesFeitas: usuario.doacoesFeitas + 1,
        vidasSalvas: usuario.vidasSalvas + 2,
      );

      try {
        await _apiService.enviarDoacao(item);
        await DatabaseHelper.marcarItemSincronizado(item.id);
      } on ApiException {}

      await carregarFeed();
    } on DatabaseException catch (e) {
      state = DonationFeedError('Erro ao salvar localmente: ${e.message}');
    } catch (e) {
      state = DonationFeedError(
        e is AppException ? e.message : 'Erro ao cadastrar: $e',
      );
    }
  }

  Future<void> atualizarEstatisticasUsuario({
    required String usuarioId,
    int? doacoesFeitas,
    int? vidasSalvas,
  }) async {
    try {
      await DatabaseHelper.atualizarEstatisticasUsuario(
        usuarioId: usuarioId,
        doacoesFeitas: doacoesFeitas,
        vidasSalvas: vidasSalvas,
      );
    } on DatabaseException catch (e) {
      state = DonationFeedError('Erro ao atualizar estatísticas: ${e.message}');
    }
  }
}
