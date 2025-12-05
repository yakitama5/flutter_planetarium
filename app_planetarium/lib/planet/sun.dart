import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 太陽を表すクラス
class Sun extends Planet {
  Sun({required super.position})
    : super(node: ResourceCache.getModel(Models.sun), radius: 10.0);
}
