import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/project_model.dart';



class ProjectDetailsScreen extends StatefulWidget {
  final int projectId;
  ProjectDetailsScreen({super.key, required this.projectId});

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  ProjectModel? _projectDetails;
  double _scale = 1.0;
  double _previousScale = 1.0;
  double _rotation = 0.0;
  double _previousRotation = 0.0;
  int? _selectedImageIndex;
  var _addImage;

  // Photos? _currentPhotos;
  Frame? _currentFrame;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _projectDetails = await _fetchProjectDetails(widget.projectId);
      setState(() {});
    });
  }

  Future<ProjectModel> _fetchProjectDetails(int projectId) async {
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
      appBar: AppBar(
        title: const Text('Project Details'),

        actions: [
          // IconButton(
          //   icon: Icon(Icons.delete),
          //   onPressed: _deleteSelectedImage,
          // ),
          // IconButton(
          //   icon: (Icons.add),
          //   onPressed: _addImage,
          // ),
        ],
      ),
      backgroundColor : Color(0xffE9EBFF),
      body: (_projectDetails == null)
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
                    onScaleUpdate: (details )
                    {
                      if(isSelected)
                     { _onScaleUpdate(details,index);}
                    },

                    onScaleStart: (details){
                      if(isSelected) {
                              _onScaleStart(details, index);
                            }
                          },
                    onTap: () => _onImageTap(index),
                    child: Transform.rotate(
                      angle: imageFrame.rotation!,
                      child: Transform.scale(scale: _scale,

                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ?Colors.blue: Colors.transparent,
                                  width: 4.0,)),
                              child: Image.network(
                                imageUrl,
                                width: imageFrame.width!.toDouble(),
                                height: imageFrame.height!.toDouble(),
                                fit: BoxFit.cover,
                              ),
                            ),

                            Container(
                               height: imageFrame.height! + 50,
                              width: imageFrame.width,
                              alignment: Alignment.topCenter,
                              child:
                                (isSelected
                            )
                             ? GestureDetector(
                                onTap: _deleteSelectedImage,

                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(999)


                                  ),
                                  child: Center(
                                    child:  Icon(Icons.remove,
                                    color: Colors.white),

                                  ),
                                ),
                              ):SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // if (isSelected)
                  //   IgnorePointer(
                  //     child: Container(
                  //       width: imageFrame.width!.toDouble(),
                  //       height: imageFrame.height!.toDouble(),
                  //       decoration: BoxDecoration(
                  //         border: Border.all(
                  //           color: Colors.blue,
                  //           width: 4.0,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  //
                ],
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addImage,
        tooltip: 'Add photo',
        child: Icon(Icons.add),
      ),
    );
  }
  // oid _addImage(){
  //
  // }v


  void _deleteSelectedImage() {
    if (_selectedImageIndex != null) {
      setState(() {
        _projectDetails!.photos!.removeAt(_selectedImageIndex!);
        _selectedImageIndex = null;
      });
    }
  }

  void _onScaleStart(ScaleStartDetails details, int index){
    _currentFrame = Frame(x: _projectDetails!.photos![index].frame!.x!,
        y: _projectDetails!.photos![index].frame!.y!,
        width: _projectDetails!.photos![index].frame!.width!,
        height: _projectDetails!.photos![index].frame!.height!);
    _previousRotation = _projectDetails!.photos![index].frame!.rotation!;
    setState(() {

    });
  }

  void _onScaleUpdate(ScaleUpdateDetails details, int index) {
    print("_currentPhotos!.frame!.width! ${_currentFrame!.width}");
    if (details.pointerCount == 1) {
      // di chuyen
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
    setState(() {
      // _rotation = details.rotation;
      // _scale = details.scale;
      //
    });
    // _scale = _previousScale * details.scale;
    // _rotation = _previousRotation + details.rotation;

  }

  void _onImageTap(int index) {
    setState(() {
      _selectedImageIndex = index;
    });
  }
}