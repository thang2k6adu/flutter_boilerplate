import 'package:go_router/go_router.dart';
import '../../presentation/main/screens/main_screen.dart';
import '../core/core.dart';

final homeRoutes = <GoRoute>[
  GoRoute(
    path: RouteConstants.main,
    builder: (context, state) => const MainScreen(),
  ),
];
