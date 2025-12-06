import 'dart:async';

import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/dash.dart';
import 'package:app_planetarium/planet/earth.dart';
import 'package:app_planetarium/planet/jupiter.dart';
import 'package:app_planetarium/planet/mars.dart';
import 'package:app_planetarium/planet/mercury.dart';
import 'package:app_planetarium/planet/moon.dart';
import 'package:app_planetarium/planet/neptune.dart';
import 'package:app_planetarium/planet/saturn.dart';
import 'package:app_planetarium/planet/star.dart';
import 'package:app_planetarium/planet/sun.dart';
import 'package:app_planetarium/planet/uranus.dart';
import 'package:app_planetarium/planet/venus.dart';
import 'package:app_planetarium/resource_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

class ModelCheck extends StatefulWidget {
  const ModelCheck({super.key});

  @override
  State<ModelCheck> createState() => _ModelCheckState();
}

class _ModelCheckState extends State<ModelCheck> {
  final Scene _scene = Scene();
  Node? _modelNode;
  double _rotationX = 0;
  Timer? _timer;
  double _cameraZ = 10.0;
  Models _selectedModel = Models.earth;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // ResourceCacheのpreloadが終わってからモデルの読み込みと回転を開始
    ResourceCache.preloadAll().then((_) {
      setState(() {
        _isLoaded = true;
        _loadModel();
        _startRotation();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scene.removeAll();
    super.dispose();
  }

  void _loadModel() {
    if (_modelNode != null) {
      _scene.remove(_modelNode!);
      _modelNode = null;
    }

    Node newNode;
    switch (_selectedModel) {
      case Models.sun:
        newNode = Sun(position: vm.Vector3.zero()).node;
        break;
      case Models.mercury:
        newNode = Mercury(position: vm.Vector3.zero()).node;
        break;
      case Models.venus:
        newNode = Venus(position: vm.Vector3.zero()).node;
        break;
      case Models.earth:
        newNode = Earth(position: vm.Vector3.zero()).node;
        break;
      case Models.mars:
        newNode = Mars(position: vm.Vector3.zero()).node;
        break;
      case Models.jupiter:
        newNode = Jupiter(position: vm.Vector3.zero()).node;
        break;
      case Models.saturn:
        newNode = Saturn(position: vm.Vector3.zero()).node;
        break;
      case Models.uranus:
        newNode = Uranus(position: vm.Vector3.zero()).node;
        break;
      case Models.neptune:
        newNode = Neptune(position: vm.Vector3.zero()).node;
        break;
      case Models.moon:
        newNode = Moon(position: vm.Vector3.zero()).node;
        break;
      case Models.dash:
        final dash = Dash(position: vm.Vector3.zero());
        dash.playAnimation(DashAnimation.idle);
        newNode = dash.node;
        break;
      case Models.fourPointedStar:
      case Models.pentagram:
      case Models.polygonalStar:
        newNode = ShiningStar(
          position: vm.Vector3.zero(),
          model: _selectedModel,
        ).node;
        break;
      default:
        newNode = Earth(position: vm.Vector3.zero()).node;
    }
    _modelNode = newNode;
    _scene.add(_modelNode!);
    _updateModelTransform();
  }

  void _updateModelTransform() {
    if (_modelNode == null) return;
    final rotationMatrix = vm.Matrix4.rotationX(_rotationX);
    _modelNode!.globalTransform = rotationMatrix;
  }

  void _startRotation() {
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        _rotationX += 0.01;
        _updateModelTransform();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: SizedBox(
                      width: constraints.maxWidth * 0.7,
                      height: constraints.maxHeight * 0.7,
                      child: CustomPaint(
                        painter: _ModelPainter(
                          scene: _scene,
                          cameraZ: _cameraZ,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: DropdownButton<Models>(
                value: _selectedModel,
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                iconEnabledColor: Colors.white,
                underline: const SizedBox.shrink(),
                items: Models.values.map((model) {
                  return DropdownMenuItem(
                    value: model,
                    child: Text(model.name),
                  );
                }).toList(),
                onChanged: (Models? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedModel = newValue;
                      _loadModel();
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'Camera Z: ${_cameraZ.toStringAsFixed(1)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Slider(
                    value: _cameraZ,
                    min: 1.0,
                    max: 200.0,
                    onChanged: (value) {
                      setState(() {
                        _cameraZ = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelPainter extends CustomPainter {
  _ModelPainter({required this.scene, required this.cameraZ});

  final Scene scene;
  final double cameraZ;

  @override
  void paint(Canvas canvas, Size size) {
    final camera = PerspectiveCamera(
      position: vm.Vector3(0, 0, cameraZ),
      target: vm.Vector3(0, 0, 0),
      up: vm.Vector3(0, 1, 0),
    );
    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
