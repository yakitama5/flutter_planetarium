import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 海王星を表すクラス
class Neptune extends Planet {
  Neptune({required super.position})
      : super(node: ResourceCache.getModel(Models.neptune), radius: 4.5);
}
