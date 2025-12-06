import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';
import 'package:flutter_scene/scene.dart';

enum DashAnimation { idle, run }

class Dash extends Planet {
  Dash({required super.position})
      : super(
          node: ResourceCache.getModel(Models.dash),
          radius: 1.0, // 当たり判定は使わないが必須なので設定
        ) {
    _setupAnimations();
  }

  AnimationClip? _idleClip;
  AnimationClip? _runClip;
  DashAnimation _currentAnimation = DashAnimation.idle;

  void _setupAnimations() {
    // アニメーションクリップを作成して初期化
    final idleAnimation = node.findAnimationByName('Idle');
    if (idleAnimation != null) {
      _idleClip = node.createAnimationClip(idleAnimation)
        ..loop = true
        ..weight = 1.0 // 最初はidle
        ..play();
    }
    final runAnimation = node.findAnimationByName('Run');
    if (runAnimation != null) {
      _runClip = node.createAnimationClip(runAnimation)
        ..loop = true
        ..weight = 0.0 // 最初は再生しない
        ..play();
    }
  }

  void playAnimation(DashAnimation animation) {
    if (_currentAnimation == animation) return;

    _currentAnimation = animation;
    switch (animation) {
      case DashAnimation.idle:
        _idleClip?.weight = 1.0;
        _runClip?.weight = 0.0;
        break;
      case DashAnimation.run:
        _idleClip?.weight = 0.0;
        _runClip?.weight = 1.0;
        break;
    }
  }
}
