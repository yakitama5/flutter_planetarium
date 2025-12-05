import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 月を表すクラス
class Moon extends Planet {
  Moon({required super.position})
      : super(node: ResourceCache.getModel(Models.moon), radius: 1.0);
}
