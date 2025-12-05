import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// 火星を表すクラス
class Mars extends Planet {
  Mars({required vm.Vector3 position})
      : super(
          position: position,
          node: ResourceCache.getModel(Models.mars),
        );
}
