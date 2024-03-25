import 'dart:convert';

import 'package:chinhanh/model/project_model.dart';
import 'package:chinhanh/view/screen2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProjectListWidget extends StatefulWidget {
  const ProjectListWidget({Key? key}) : super(key: key);
  @override
  _ProjectListWidgetState createState() => _ProjectListWidgetState();
}

class _ProjectListWidgetState extends State<ProjectListWidget> {
  List<ProjectModel> projects = [];

  Future<void> fetchProjects() async {

    final response =
    await http.get(Uri.parse('https://tapuniverse.com/xproject'));
    if (response.statusCode == 200) {
      List abc = json.decode(response.body)['projects'];

      for (int i =0 ;i <abc.length ; i++) {
        projects.add(ProjectModel.fromJson(abc[i]));
      }
      print(projects[0].photos);
      setState(() {
      });
    } else {
      throw Exception('Failed to load projects');
    }
    print('===');
  }

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  void addProject(String projectName) {
    setState(() {
      projects.add(ProjectModel(name: projectName ,id: projects.length +1, photos: []));
    });
  }

  void removeProject(int index) {
    setState(() {
      projects.removeAt(index);
    });
  }

  void editProject(int index, String newName) {
    setState(() {
      projects[index].name = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: Key(projects[index].id.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    removeProject(index);

                  },
                  background: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.remove,
                      color: Colors.black,
                    ),
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text(projects[index].name!),
                      subtitle: Text('ID: ${projects[index].id}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectDetailsScreen(
                              projectId: projects[index].id!, projects: projects,

                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Add Project'),
                      content: TextField(
                        autofocus: true,
                        decoration: const InputDecoration(
                            labelText: 'Project Name'),
                        onSubmitted: (String value) {
                          addProject(value);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                );
              },
              child: const Text('Add Project'),
            ),
          ),
        ],
      ),
    );
  }
}