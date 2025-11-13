class OrganizationModel {
  String? id;
  String? name;
  String? description;
  String? avatar;
  String? website;
  String? subscription;
  String? type;
  int? status;
  String? createdDate;
  String? address;
  String? fieldOfActivity;
  String? hotline;

  OrganizationModel(
      {this.id,
      this.name,
      this.description,
      this.avatar,
      this.website,
      this.subscription,
      this.type,
      this.status,
      this.createdDate,
      this.address,
      this.fieldOfActivity,
      this.hotline});

  OrganizationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    avatar = json['avatar'];
    website = json['website'];
    subscription = json['subscription'];
    type = json['type'];
    status = json['status'];
    createdDate = json['createdDate'];
    address = json['address'];
    fieldOfActivity = json['fieldOfActivity'];
    hotline = json['hotline'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['avatar'] = avatar;
    data['website'] = website;
    data['subscription'] = subscription;
    data['type'] = type;
    data['status'] = status;
    data['createdDate'] = createdDate;
    data['address'] = address;
    data['fieldOfActivity'] = fieldOfActivity;
    data['hotline'] = hotline;
    return data;
  }
}
