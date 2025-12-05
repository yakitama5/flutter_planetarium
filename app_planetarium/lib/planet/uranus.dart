import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/orbiting_planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 天王星を表すクラス
class Uranus extends OrbitingPlanet {
  Uranus()
      : super(
          rotationSpeed: 0.06,
          node: ResourceCache.getModel(Models.uranus),
          distance: 110,
          orbitalSpeed: 0.03,
        );
}
