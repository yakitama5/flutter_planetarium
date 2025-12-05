import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 天王星を表すクラス
class Uranus extends Planet {
  Uranus({required super.position})
    : super(node: ResourceCache.getModel(Models.uranus));
}
