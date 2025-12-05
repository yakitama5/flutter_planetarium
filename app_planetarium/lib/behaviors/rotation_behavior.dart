import 'package:app_planetarium/behaviors/behavior.dart';
import 'package:app_planetarium/planet/planet.dart';

/// 惑星の自転を制御する振る舞い
class RotationBehavior implements Behavior {
  RotationBehavior({required this.rotationSpeed});

  final double rotationSpeed;

  @override
  void update(Planet planet, double elapsedSeconds) {
    planet.rotation += rotationSpeed;
  }
}
