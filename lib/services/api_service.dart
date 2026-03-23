import 'package:dio/dio.dart';

import '../core/exceptions/app_exceptions.dart';
import '../models/item_doacao.dart';

final class ApiService {
  ApiService({String? baseUrl, this.simularRede = true}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? 'https://api.ecoshare.example.com',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  late final Dio _dio;
  final bool simularRede;

  Dio get dio => _dio;

  static const Duration _latenciaSimulada = Duration(milliseconds: 800);

  Future<List<ItemDoacao>> buscarFeedDoacoes() async {
    if (simularRede) {
      return _buscarFeedSimulado();
    }
    return _buscarFeedReal();
  }

  Future<List<ItemDoacao>> _buscarFeedSimulado() async {
    await Future.delayed(_latenciaSimulada);
    return [
      ItemDoacao(
        id: '1',
        titulo: 'Bicicleta Infantil',
        descricao: 'Bicicleta em ótimo estado para criança de 5 a 8 anos.',
        categoria: 'Esportes',
        estadoConservacao: 'Bom',
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
        isLocalSync: false,
      ),
      ItemDoacao(
        id: '2',
        titulo: 'Livros Didáticos',
        descricao: 'Coleção de livros de ensino fundamental.',
        categoria: 'Livros',
        estadoConservacao: 'Novo',
        imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=800',
        isLocalSync: false,
      ),
      ItemDoacao(
        id: '3',
        titulo: 'Sofá 3 Lugares',
        descricao: 'Sofá retrátil, tecido azul, pouco uso.',
        categoria: 'Móveis',
        estadoConservacao: 'Regular',
        imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
        isLocalSync: false,
      ),
    ];
  }

  Future<List<ItemDoacao>> _buscarFeedReal() async {
    try {
      final response = await _dio.get<dynamic>('/feed');
      if (response.data is! List) {
        throw ApiException('Resposta inválida da API: formato esperado é uma lista');
      }
      return (response.data as List)
          .map((e) => ItemDoacao.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.withStatus(
        _mensagemErroDio(e),
        e.response?.statusCode,
        e,
      );
    }
  }

  Future<void> enviarDoacao(ItemDoacao item) async {
    if (simularRede) {
      return _enviarDoacaoSimulado(item);
    }
    return _enviarDoacaoReal(item);
  }

  Future<void> _enviarDoacaoSimulado(ItemDoacao item) async {
    await Future.delayed(_latenciaSimulada);
  }

  Future<void> _enviarDoacaoReal(ItemDoacao item) async {
    try {
      final response = await _dio.post<dynamic>(
        '/doacoes',
        data: item.toJson(),
      );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return;
      }
      throw ApiException.withStatus(
        'Falha ao enviar doação: ${response.statusMessage ?? "Erro desconhecido"}',
        response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException.withStatus(
        _mensagemErroDio(e),
        e.response?.statusCode,
        e,
      );
    }
  }

  String _mensagemErroDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tempo esgotado. Verifique sua conexão.';
      case DioExceptionType.connectionError:
        return 'Sem conexão com a internet.';
      case DioExceptionType.badResponse:
        return 'Erro do servidor: ${e.response?.statusCode ?? "desconhecido"}';
      default:
        return e.message ?? 'Erro ao comunicar com o servidor.';
    }
  }
}
