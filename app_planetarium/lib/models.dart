/// 利用可能な3Dモデルの一覧
enum Models {
  sun('build/models/sun.model'),
  saturn('build/models/saturn.model'),
  sphere('build/models/sphere.model'),
  earth('build/models/earth.model');

  final String path;
  const Models(this.path);
}
