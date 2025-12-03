/// 利用可能な3Dモデルの一覧
enum Models {
  sun('build/models/sun.model'),
  earth('build/models/earth.model', unlit: true),
  star('build/models/star.model'),
  cubit('build/models/cubit.model');

  final String path;
  final bool unlit;
  const Models(this.path, {this.unlit = false});
}
