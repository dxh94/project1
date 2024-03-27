import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../model/project_model.dart';


class ProjectDetailsScreen extends StatefulWidget {
  final int projectId;
  List projects;
  ProjectDetailsScreen({Key? key, required this.projectId,required this.projects}) : super(key: key);
  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}
Image _buildImage(String url, bool isInternetImage) {
  if (isInternetImage) {
    return Image.network(url);
  } else {
    return Image.file(File(url));
  }
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  ProjectModel? _projectDetails;
  double _scale = 1.0;
  double _previousRotation = 0.0;
  int? _selectedImageIndex;
  Frame? _currentFrame;
  File? selectedimage;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      ProjectModel? a = null;
      for (int i = 0; i < widget.projects.length; i++) {
        if (widget.projects[i].id == widget.projectId &&
            widget.projects[i].isCheckProject == true) {
          a = widget.projects[i];
        }
      }
      if (a != null) {
        _projectDetails = a;
      } else {
        _projectDetails = await _fetchProjectDetails(widget.projectId);
      }
      setState(() {});
    });
  }
  Future<ProjectModel> _fetchProjectDetails(int projectId) async {
    print({'id': projectId.toString()});
    final response = await http.post(
      Uri.parse('https://tapuniverse.com/xprojectdetail'),
      body: {'id': projectId.toString()},
    );
    if (response.statusCode == 200) {
      final photo = json.decode(response.body);
      if (photo['photos'] != null) {
        return ProjectModel.fromJson(photo);
      } else {
        throw Exception('Invalid data format');
      }
    } else {
      throw Exception('Failed to load project details');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE9EBFF),
      body:
      Container(padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            Align(alignment: Alignment.centerLeft,
                child: TextButton(onPressed: _onback,
                    child: Text(
                      "back", style:
                    TextStyle(
                        color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),))),
            Expanded(
              child: Container(
                child: (_projectDetails == null)
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                  child: Stack(
                    children: _projectDetails!.photos!.map((item) {
                      final index = _projectDetails!.photos!.indexOf(item);
                      final photo = item;
                      final imageUrl = photo.url!;
                      final imageFrame = photo.frame!;
                      final isSelected = index == _selectedImageIndex;
                      return Positioned(
                        top: imageFrame.y!.toDouble(),
                        left: imageFrame.x!.toDouble(),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onScaleUpdate: (details) {
                                if (isSelected) {
                                  _onScaleUpdate(details, index);
                                }
                              },
                              onScaleStart: (details) {
                                if (isSelected) {
                                  _onScaleStart(details, index);
                                }
                              },
                              onTap: () => _onImageTap(index),
                              child: Transform.rotate(
                                angle: imageFrame.rotation!,
                                child: Transform.scale(
                                  scale: _scale,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.transparent,
                                            width: 4.0,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              12.0),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              8.0),
                                          child: Stack(
                                            children: [
                                              Image.network(() {
                                                return imageUrl;
                                              }(),
                                                width: imageFrame.width!
                                                    .toDouble(),
                                                height: imageFrame.height!
                                                    .toDouble(),
                                                fit: BoxFit.cover,
                                              ),
                                              // if (isSelected)_buildCornerCircle(-8, -8),
                                              // // Góc trên bên trái
                                              // if (isSelected)_buildCornerCircle(imageFrame.width!  -6 , -5),
                                              // // Góc trên bên phải
                                              // if (isSelected)_buildCornerCircle(-5, imageFrame.height! - 6),
                                              // // Góc dưới bên trái
                                              // if (isSelected)_buildCornerCircle(imageFrame.width! - 8, imageFrame.height! - 8),
                                              // // Góc dưới bên phải
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: imageFrame.height! + 50,
                                        width: imageFrame.width,
                                        alignment: Alignment.topCenter,
                                        child: (isSelected)
                                            ? GestureDetector(
                                          onTap: _deleteSelectedImage,
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                BorderRadius.circular(
                                                    999)),
                                            child: Center(
                                              child: Icon(Icons.remove,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )
                                            : SizedBox(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 0.0),
        child: FloatingActionButton.extended(
          onPressed: _pickImageFromGallery,
          label: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100.0),
            child: Text(
              'Add Photo',
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: Colors.blue,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  // Widget _buildCornerCircle(double left, double top) {
  //   return Positioned(
  //     left: left,
  //     top: top,
  //     child: Container(
  //       width: 16,
  //       height: 16,
  //       decoration: BoxDecoration(
  //         color: Colors.blue,
  //         shape: BoxShape.circle,
  //       ),
  //     ),
  //   );
  // }
  void _deleteSelectedImage() {
    if (_selectedImageIndex != null) {
      setState(() {
        _projectDetails!.photos!.removeAt(_selectedImageIndex!);
        _selectedImageIndex = null;
      });
    }
  }
  void _onScaleStart(ScaleStartDetails details, int index) {
    _currentFrame = Frame(
        x: _projectDetails!.photos![index].frame!.x!,
        y: _projectDetails!.photos![index].frame!.y!,
        width: _projectDetails!.photos![index].frame!.width!,
        height: _projectDetails!.photos![index].frame!.height!);
    _previousRotation = _projectDetails!.photos![index].frame!.rotation!;
    setState(() {});
  }
  void _onScaleUpdate(ScaleUpdateDetails details, int index) {
    print("_currentPhotos!.frame!.width! ${_currentFrame!.width}");
    if (details.pointerCount == 1) {
      _projectDetails!.photos![index].frame!.x = _projectDetails!.photos![index].frame!.x! + details.focalPointDelta.dx;
      _projectDetails!.photos![index].frame!.y = _projectDetails!.photos![index].frame!.y! + details.focalPointDelta.dy;
    } else if (details.pointerCount == 2) {
      _projectDetails!.photos![index].frame!.width = _currentFrame!.width! * details.scale;
      _projectDetails!.photos![index].frame!.height = _currentFrame!.height! * details.scale;
      _projectDetails!.photos![index].frame!.x = _currentFrame!.x! + (_currentFrame!.width! - _projectDetails!.photos![index].frame!.width!) / 2;
      _projectDetails!.photos![index].frame!.y = _currentFrame!.y! + (_currentFrame!.height! - _projectDetails!.photos![index].frame!.height!) / 2;
      _projectDetails!.photos![index].frame!.rotation = _previousRotation + details.rotation;
      setState(() {});
    }
    setState(() {});
  }
  void _onImageTap(int index) {
    setState(() {
      _selectedImageIndex = index;
    });
  }
  void _onback() {
    for (int i = 0; i < widget.projects.length; i++) {
      if (_projectDetails!.id == widget.projects[i].id) {
        widget.projects[i] = _projectDetails!
          ..isCheckProject = true;
      }
    }
    Navigator.of(context).pop();
  }
  Future _pickImageFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      if (File(pickedImage.path).existsSync()) {
        final newPhoto = Photos(url: pickedImage.path, frame: Frame(x: 100, y: 100, width: 200, height: 200, rotation: 0));
        setState(() {
          _projectDetails?.photos?.add(newPhoto);
        });
      } else {
        print("Invalid image path: ${pickedImage.path}");
      }
    }
  }
}
