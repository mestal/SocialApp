import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:falci/PagerSingleton.dart';
import 'package:falci/ColorLoader.dart';

class NewCoffeeFal extends StatefulWidget  {

  PageController pageController;
  NewCoffeeFal({this.pageController});

  @override
  _NewCoffeeFalState createState()  {
    
    return _NewCoffeeFalState(pageController: pageController);
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _NewCoffeeFalState extends State<NewCoffeeFal> {
  CameraController controller;
  bool _pictureBeingTaken = false;

  PageController pageController;
  _NewCoffeeFalState({this.pageController});

  List<String> imagePaths = List<String>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    @override
    void initState() {
        // This is the proper place to make the async calls
        // This way they only get called once

        // During development, if you change this code,
        // you will need to do a full restart instead of just a hot reload
        
        // You can't use async/await here,
        // We can't mark this method as async because of the @override
        availableCameras().then((result) {
            // If we need to rebuild the widget with the resulting data,
            // make sure to use `setState`
            setState(() {
                cameras = result;
                onNewCameraSelected(cameras[0]);
            });
        });
    }

  gotoFalciSelection() {
    PagerSingleton.instance.router.navigateTo(context, "/newfalselectfalci");
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Kahve falını çek'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        tooltip: 'Add',
        child: Icon(Icons.arrow_right),
        onPressed: () {
          gotoFalciSelection();
        }
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          _captureControlRowWidget(),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _cameraTogglesRowWidget(),
                _thumbnailWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (//1 == 1 || 
      controller == null || !controller.value.isInitialized) {
      return const Text(
        '',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    return Row(
      children: <Widget>[
        SizedBox(
          height: 64,
          width: 350,
          child: 
            ListView.builder(
              //shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: ScrollPhysics(),
                //controller: _scrollController,
              itemCount: imagePaths.length,
              itemBuilder: (BuildContext ctx, int index) {
                return 
                Padding(
                  padding: EdgeInsets.only(left: 2, right: 2.0, top: 2.0),
                  child: 
                  Row(children: <Widget>[
                    new 
                      // FlatButton(
                      // child: 
                      Container(
                        height: 64,
                        width: 64,
                        //alignment: Alignment.topRight,
                        decoration: new BoxDecoration(
                          image: new DecorationImage(
                            image: FileImage(File(imagePaths[index])),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: FlatButton(
                          child: Align(alignment: Alignment.topCenter, child: Icon(Icons.cancel), ) ,
                          onPressed: () {
                            setState(() {
                              imagePaths.removeAt(index);
                            });
                          },
                        )
                      ),
                      // onPressed: () {
                      //   showDialog(
                      //     context: context,
                      //     builder: (BuildContext context) {
                      //       return AlertDialog(
                      //         //title: Text(""),
                      //         content: Text('Deneme'),
                      //         actions: <Widget>[
                      //           new FlatButton(
                      //             child: new Text("Kapat"),
                      //             onPressed: () {
                      //               //Navigator.of(context).pop();
                      //             },
                      //           )
                      //         ]
                      //       );
                      //     }
                      //   );
                      // },
                    //),
                    _pictureBeingTaken && index == imagePaths.length - 1 ? 
                      SizedBox(
                        child: ColorLoader(
                          radius: 20.0,
                          dotRadius: 5.0,
                        ),
                        width: 64.0,
                        height: 64.0,
                      ) : Container(),
                  ],
                )
              );
            }
          )
        ),
      ]
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: imagePaths.length < 3 ? Icon(Icons.camera_alt) : Icon(Icons.camera_alt, color: Colors.grey,),
          color: _pictureBeingTaken ? Colors.grey : Colors.blue,
          onPressed: controller != null &&
                  controller.value.isInitialized && imagePaths.length < 3
              ? onTakePictureButtonPressed
              : null,
        ),
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];
    
    if (cameras == null || cameras.isEmpty) {
      return const Text('No camera foundd');
    } else {
      // for (CameraDescription cameraDescription in cameras) {
      //   toggles.add(
      //     SizedBox(
      //       width: 90.0,
      //       child: Text("Dene1")
            
      //       // RadioListTile<CameraDescription>(
      //       //   title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
      //       //   groupValue: controller?.description,
      //       //   value: cameraDescription,
      //       //   onChanged: controller != null && controller.value.isRecordingVideo
      //       //       ? null
      //       //       : onNewCameraSelected,
      //       // ),
      //     ),
      //   );
      // }
    }

    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    if(_pictureBeingTaken)
      return;
    setState(() {
      _pictureBeingTaken = true;  
    });
    
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          //imagePath = filePath;
          imagePaths.add(filePath);
          PagerSingleton.instance.newFal.images.add(filePath);
          _pictureBeingTaken = false;  
        });
        //if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

// class CameraApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: CameraExampleHome(),
//     );
//   }
// }

List<CameraDescription> cameras;
