import 'package:flutter/material.dart';
import 'package:pod_router/pod_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth.dart';

void main() {
  runApp(const ProviderScope(child: PodRouterExemple()));
}

class PodRouterExemple extends ConsumerWidget {
  const PodRouterExemple({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      title: 'Pod Router Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
