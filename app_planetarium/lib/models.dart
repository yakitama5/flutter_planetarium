/// 利用可能な3Dモデルの一覧
enum Models {
  cubit('build/models/cubit.model'),
  earth('build/models/earth.model', unlit: true),
  fourPointedStarYellow('build/models/four_pointed_star_yellow.model'),
  pentagram('build/models/pentagram.model'),
  polygonalStar('build/models/polygonal_star.model'),
  starDome('build/models/star_dome.model'),
  sun('build/models/sun.model');

  final String path;
  final bool unlit;
  const Models(this.path, {this.unlit = false});
}
