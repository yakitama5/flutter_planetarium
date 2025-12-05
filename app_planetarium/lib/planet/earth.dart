import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// 地球を表すクラス
class Earth extends Planet {
  Earth({required vm.Vector3 position})
      : super(
          position: position,
          node: ResourceCache.getModel(Models.earth),
        );
}
