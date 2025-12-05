import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/orbiting_planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 火星を表すクラス
class Mars extends OrbitingPlanet {
  Mars()
      : super(
          rotationSpeed: 0.04,
          node: ResourceCache.getModel(Models.mars),
          distance: 50,
          orbitalSpeed: 0.15,
        );
}
