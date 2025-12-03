/// 利用可能な3Dモデルの一覧
enum Models {
  sun('build/models/sun.model'),
  earth('build/models/earth.model'),
  star('build/models/star.model');

  final String path;
  const Models(this.path);
}
