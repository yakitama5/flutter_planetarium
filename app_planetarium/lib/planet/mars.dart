import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 火星を表すクラス
class Mars extends Planet {
  Mars({required super.position})
    : super(node: ResourceCache.getModel(Models.mars));
}
