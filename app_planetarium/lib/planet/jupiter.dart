import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/orbiting_planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 木星を表すクラス
class Jupiter extends OrbitingPlanet {
  Jupiter()
      : super(
          rotationSpeed: 0.1,
          node: ResourceCache.getModel(Models.jupiter),
          distance: 70,
          orbitalSpeed: 0.08,
        );
}
