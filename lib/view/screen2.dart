import 'dart:convert';

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

  // Photos? _currentPhotos;
  Frame? _currentFrame;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
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
      ),
      body: (_projectDetails == null)
          ? const Center(child: CircularProgressIndicator())
          : Container(
        // onTapDown: _onTapDown,
        // onTapUp: _onTapUp,
        // onScaleStart: _onScaleStart,
        // onScaleUpdate: _onScaleUpdate,
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
                    onScaleUpdate:
                    (details ){
                      _onScaleUpdate(details,index);
                    },
                    onScaleStart: (details){
                      _onScaleStart(details,index);
                    },
                    onTap: () => _onImageTap(index),
                    child: Image.network(
                      imageUrl,
                      width: imageFrame.width!.toDouble(),
                      height: imageFrame.height!.toDouble(),
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (isSelected)
                    IgnorePointer(
                      child: Container(
                        width: imageFrame.width!.toDouble(),
                        height: imageFrame.height!.toDouble(),
                        decoration: BoxDecoration(
                          // color: Colors.red
                          border: Border.all(
                            color: Colors.blue,
                            width: 4.0,
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
    );
  }

  // void _onScaleStart(ScaleStartDetails details, int index) {
  //   _previousScale = _scale;
  //   _previousRotation = _rotation;
  // }
  void _onScaleStart(ScaleStartDetails details, int index){
    _currentFrame = Frame(x: _projectDetails!.photos![index].frame!.x!,
        y: _projectDetails!.photos![index].frame!.y!,
        width: _projectDetails!.photos![index].frame!.width!,
        height: _projectDetails!.photos![index].frame!.height!);
    setState(() {

    });
  }

  void _onScaleUpdate(ScaleUpdateDetails details, int index) {
    print("_currentPhotos!.frame!.width! ${_currentFrame!.width}");
    if (details.pointerCount ==1){
      // di chuyen
      _projectDetails!.photos![index].frame!.x = _projectDetails!.photos![index].frame!.x! + details.focalPointDelta.dx;
      _projectDetails!.photos![index].frame!.y =_projectDetails!.photos![index].frame!.y! +  details.focalPointDelta.dy;
    }else if(details.pointerCount == 2) {
      _projectDetails!.photos![index].frame!.width =  _currentFrame!.width! * details.scale;
      _projectDetails!.photos![index].frame!.height = _currentFrame!.height! * details.scale;
      _projectDetails!.photos![index].frame!.x =  _currentFrame!.x!  +  (_currentFrame!.width! -  _projectDetails!.photos![index].frame!.width!)/2;
      _projectDetails!.photos![index].frame!.y =  _currentFrame!.y!  +  (_currentFrame!.height! -  _projectDetails!.photos![index].frame!.height!)/2;

    }
    setState(() {
    });
      // _scale = _previousScale * details.scale;
      // _rotation = _previousRotation + details.rotation;

  }
  void _onTapDown(TapDownDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      _selectedImageIndex = _getTappedImageIndex(localOffset);
    });
  }
  void _onTapUp(TapUpDetails details) {
    setState(() {
      _selectedImageIndex = null;
    });
  }

  int? _getTappedImageIndex(Offset localOffset) {
    for (int i = 0; i < _projectDetails!.photos!.length; i++) {
      final imageFrame = _projectDetails!.photos![i].frame!;
      if (localOffset.dx >= imageFrame.x! &&
          localOffset.dx <= imageFrame.x! + imageFrame.width! &&
          localOffset.dy >= imageFrame.y! &&
          localOffset.dy <= imageFrame.y! + imageFrame.height!) {
        return i;
      }
    }
    return null;
  }
  void _onImageTap(int index) {
    setState(() {
      _selectedImageIndex = index;
    });
  }
}