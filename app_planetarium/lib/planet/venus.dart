import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/orbiting_planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 金星を表すクラス
class Venus extends OrbitingPlanet {
  Venus()
      : super(
          rotationSpeed: 0.005,
          node: ResourceCache.getModel(Models.venus),
          distance: 30,
          orbitalSpeed: 0.5,
        );
}
