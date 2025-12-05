import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// 水星を表すクラス
class Mercury extends Planet {
  Mercury({required vm.Vector3 position})
      : super(
          position: position,
          node: ResourceCache.getModel(Models.mercury),
        );
}
