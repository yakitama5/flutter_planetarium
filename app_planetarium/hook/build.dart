import 'package:flutter_scene_importer/build_hooks.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) {
  build(args, (config, output) async {
    buildModels(
      buildInput: config,
      inputFilePaths: [
        'assets/src/saturn.glb',
        'assets/src/sphere.glb',
        'assets/src/sun.glb',
        'assets/src/earth.glb',
      ],
    );
  });
}
