import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// 天王星を表すクラス
class Uranus extends Planet {
  Uranus({required vm.Vector3 position})
      : super(
          position: position,
          node: ResourceCache.getModel(Models.uranus),
        );
}
