import 'package:flutter_scene_importer/build_hooks.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) {
  build(args, (config, output) async {
    buildModels(
      buildInput: config,
      inputFilePaths: [
        'assets/glb/cubit.glb',
        'assets/glb/earth.glb',
        'assets/glb/four_pointed_star_yellow.glb',
        'assets/glb/pentagram.glb',
        'assets/glb/polygonal_star.glb',
        'assets/glb/star_dome.glb',
        'assets/glb/sun.glb',
      ],
    );
  });
}
