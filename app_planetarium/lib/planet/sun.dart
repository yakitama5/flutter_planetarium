import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 太陽を表すクラス
class Sun extends Planet {
  /// 太陽の半径
  static const double radius = 13.0;

  Sun({required super.position})
    : super(node: ResourceCache.getModel(Models.sun));
}
