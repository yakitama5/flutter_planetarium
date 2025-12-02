import 'package:flutter_scene_importer/build_hooks.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) {
  build(args, (config, output) async {
    buildModels(
      buildInput: config,
      inputFilePaths: [
        'assets/glb/saturn.glb',
        'assets/glb/sphere.glb',
        'assets/glb/sun.glb',
        'assets/glb/earth.glb',
        'assets/glb/earth_large.glb',
      ],
    );
  });
}
