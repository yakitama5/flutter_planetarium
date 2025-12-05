import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/orbiting_planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 土星を表すクラス
class Saturn extends OrbitingPlanet {
  Saturn()
      : super(
          rotationSpeed: 0.09,
          node: ResourceCache.getModel(Models.saturn),
          distance: 90,
          orbitalSpeed: 0.05,
        );
}
