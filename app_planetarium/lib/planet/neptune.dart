import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/orbiting_planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 海王星を表すクラス
class Neptune extends OrbitingPlanet {
  Neptune()
      : super(
          rotationSpeed: 0.05,
          node: ResourceCache.getModel(Models.neptune),
          distance: 130,
          orbitalSpeed: 0.02,
        );
}
