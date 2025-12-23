import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jt291_flutter_mobile/core/core.dart';
import 'package:jt291_flutter_mobile/presentation/auth/controllers/auth_controller.dart';
import 'package:jt291_flutter_mobile/presentation/auth/screens/splash_screen.dart';
import 'package:jt291_flutter_mobile/routers/app_router.dart';

class AppInitializer extends ConsumerStatefulWidget {
  final Widget child;
  const AppInitializer({super.key, required this.child});

  @override
  AppInitializerState createState() => AppInitializerState();
}

class AppInitializerState extends ConsumerState<AppInitializer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider);
    final router = ref.read(routerProvider);

    if (user != null) {
      return widget.child;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.go(RouteConstants.login);
      });
      return const SizedBox.shrink();
    }
  }
}
