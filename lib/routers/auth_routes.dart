import 'package:go_router/go_router.dart';
import '../../presentation/auth/screens/login_screen.dart';
import '../core/core.dart';

final authRoutes = <GoRoute>[
  GoRoute(
    path: RouteConstants.login,
    builder: (context, state) => const LoginScreen(),
  ),
];
