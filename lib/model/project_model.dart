class ProjectModel {
  String? name;
  int? id;
  List<Photos>? photos;

  ProjectModel({this.name, this.id, this.photos});
  bool isCheckProject = false;

  ProjectModel.fromJson(Map<String, dynamic> json) {
    print(json);
    name = json['name'];
    id = json['id'];
    if (json['photos'] != null) {
      photos = <Photos>[];
      json['photos'].forEach((v) {
        photos!.add(new Photos.fromJson(v));
      });
    }
    else {
      photos = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    if (this.photos != null) {
      data['photos'] = this.photos!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Photos {
  String? url;
  Frame? frame;

  Photos({this.url, this.frame});

  Photos.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    frame = json['frame'] != null ? new Frame.fromJson(json['frame']) : null;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    if (this.frame != null) {
      data['frame'] = this.frame!.toJson();
    }
    return data;
  }
}

class Frame {
  double? x;
  double? y;
  double? width;
  double? height;
  double? scale;
  double? rotation;

  Frame({this.x, this.y, this.width, this.height, this.rotation, this.scale});

  Frame.fromJson(Map<String, dynamic> json) {
    x =( json['x']).toDouble();
    y = (json['y']).toDouble();
    width = (json['width']).toDouble();
    height = (json['height']).toDouble();
    scale = 1;
   rotation = 0;

  }



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['x'] = this.x;
    data['y'] = this.y;
    data['width'] = this.width;
    data['height'] = this.height;
    return data;
  }
}