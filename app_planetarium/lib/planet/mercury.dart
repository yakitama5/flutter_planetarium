import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/orbiting_planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 水星を表すクラス
class Mercury extends OrbitingPlanet {
  Mercury()
      : super(
          rotationSpeed: 0.01,
          node: ResourceCache.getModel(Models.mercury),
          distance: 20,
          orbitalSpeed: 0.8,
        );
}
