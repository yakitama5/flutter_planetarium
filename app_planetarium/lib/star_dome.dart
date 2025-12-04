import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/resource_cache.dart';
import 'package:flutter_scene/scene.dart';

/// 星座ドームを表すクラス
class StarDome {
  StarDome();

  final Node node = ResourceCache.getModel(Models.starDome);
}
