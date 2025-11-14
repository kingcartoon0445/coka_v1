class TagsGetpagingResponse {
  int? code;
  List<TagGetpagingModel>? content;

  TagsGetpagingResponse({
    this.code,
    this.content,
  });

  TagsGetpagingResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['content'] != null) {
      content = <TagGetpagingModel>[];
      json['content'].forEach((v) {
        content!.add(new TagGetpagingModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    if (this.content != null) {
      data['content'] = this.content!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class TagGetpagingModel {
  String? id;
  String? organizationId;
  String? workspaceId;
  String? name;
  int? count;
  int? status;
  String? createdBy;
  String? createdDate;
  String? lastModifiedBy;
  String? lastModifiedDate;

  TagGetpagingModel(
      {this.id,
      this.organizationId,
      this.workspaceId,
      this.name,
      this.count,
      this.status,
      this.createdBy,
      this.createdDate,
      this.lastModifiedBy,
      this.lastModifiedDate});

  TagGetpagingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    organizationId = json['organizationId'];
    workspaceId = json['workspaceId'];
    name = json['name'];
    count = json['count'];
    status = json['status'];
    createdBy = json['createdBy'];
    createdDate = json['createdDate'];
    lastModifiedBy = json['lastModifiedBy'];
    lastModifiedDate = json['lastModifiedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['organizationId'] = this.organizationId;
    data['workspaceId'] = this.workspaceId;
    data['name'] = this.name;
    data['count'] = this.count;
    data['status'] = this.status;
    data['createdBy'] = this.createdBy;
    data['createdDate'] = this.createdDate;
    data['lastModifiedBy'] = this.lastModifiedBy;
    data['lastModifiedDate'] = this.lastModifiedDate;
    return data;
  }
}
