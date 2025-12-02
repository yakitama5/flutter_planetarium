import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 地球を表すクラス
class Earth extends Planet {
  Earth({required super.position})
    : super(rotationSpeed: 0.005, node: ResourceCache.getModel(Models.earth));
}
