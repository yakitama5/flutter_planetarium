import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 土星を表すクラス
class Saturn extends Planet {
  Saturn({required super.position})
    : super(node: ResourceCache.getModel(Models.saturn));
}
