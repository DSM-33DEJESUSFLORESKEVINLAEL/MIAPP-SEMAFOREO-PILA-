// © 2025 Kevin Lael de Jesús Flores
// Todos los derechos reservados.
// Este código es parte de la aplicación [Mi app].
// Prohibida su reproducción o distribución sin autorización.

import 'package:go_router/go_router.dart';
import 'package:miapp/screens/home_screen.dart';
import 'package:miapp/screens/piladesecho/piladesecho_desdet_list_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    // initialLocation: '/loading',
        initialLocation: '/login',

    routes: [
       GoRoute(
        path: '/', // 🔹 Ruta principal debe existir
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
     GoRoute(
        path: '/piladesechodesdet/:folio', // 👈 Se añade un parámetro a la ruta
        builder: (context, state) {
          final folio = state.pathParameters['folio']!;
          return PiladesechoListadesdetScreen(folio: folio);
        },
      ),
    ],
  );
}
