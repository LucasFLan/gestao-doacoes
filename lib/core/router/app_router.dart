import 'package:go_router/go_router.dart';

import '../../models/item_doacao.dart';
import '../../screens/home_screen.dart';
import '../../screens/item_detail_screen.dart';

final class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String itemDetail = '/item';
  static const String login = '/login';
  static const String cadastroItem = '/cadastro-item';
  static const String perfil = '/perfil';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: itemDetail,
        name: 'itemDetail',
        builder: (context, state) {
          final item = state.extra as ItemDoacao;
          return ItemDetailScreen(item: item);
        },
      ),
    ],
  );
}
