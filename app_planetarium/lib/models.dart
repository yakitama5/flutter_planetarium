/// 利用可能な3Dモデルの一覧
enum Models {
  earth('build/models/earth.glb.model'),
  fourPointedStar('build/models/four_pointed_star.glb.model'),
  jupiter('build/models/jupiter.glb.model'),
  mars('build/models/mars.glb.model'),
  mercury('build/models/mercury.glb.model'),
  moon('build/models/moon.glb.model'),
  neptune('build/models/neptune.glb.model'),
  pentagram('build/models/pentagram.glb.model'),
  polygonalStar('build/models/polygonal_star.glb.model'),
  saturn('build/models/saturn.glb.model'),
  starDome('build/models/star_dome.glb.model'),
  sun('build/models/sun.glb.model'),
  uranus('build/models/uranus.glb.model'),
  venus('build/models/venus.glb.model');

  final String path;
  final bool unlit;
  const Models(this.path, {this.unlit = false});
}
