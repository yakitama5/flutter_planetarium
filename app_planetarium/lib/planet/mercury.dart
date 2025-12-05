import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';

/// 水星を表すクラス
class Mercury extends Planet {
  Mercury({required super.position})
    : super(node: ResourceCache.getModel(Models.mercury));
}
