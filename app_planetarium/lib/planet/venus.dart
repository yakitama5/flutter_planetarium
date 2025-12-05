import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 金星を表すクラス
class Venus extends Planet {
  Venus({required super.position})
      : super(node: ResourceCache.getModel(Models.venus), radius: 3.0);
}
