import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pod_router/src/router/routes_manager.dart';
import 'package:pod_router/src/utils/package_logger.dart';

/// Extension method to register a routes manager
extension RoutesManagerRegistryExtension on Ref {
  void registerRoutesManager(RoutesManager manager) {
    final registry = read(routesManagerRegistry.notifier);
    registry.update((state) => [...state, manager]);

    // Log the registration
    PackageLogger.debug('Registered routes manager: ${manager.runtimeType}',
        featureType: FeaturesType.routing);
  }
}
