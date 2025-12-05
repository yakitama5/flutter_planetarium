import 'package:app_planetarium/behaviors/behavior.dart';
import 'package:app_planetarium/planet/planet.dart';

/// 複数の振る舞いを組み合わせるためのコンテナ
class CompositeBehavior implements Behavior {
  CompositeBehavior({required this.behaviors});

  final List<Behavior> behaviors;

  @override
  void update(Planet planet, double elapsedSeconds) {
    for (final behavior in behaviors) {
      behavior.update(planet, elapsedSeconds);
    }
  }
}
