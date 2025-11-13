import 'dart:convert';

import 'package:coka/constants.dart';
import 'package:get/get.dart';

class TriggerSelectorController extends GetxController {
  final formatData = {}.obs;
  final testData = {}.obs;

  testRun() {
    final String data = jsonEncode({
      "Id": '2d03d888-e51e-4211-ad13-e024bd01d466',
      "WorkspaceId": 'a3773e4e-3be9-4def-9504-a3c9353f8917',
      "TeamId": null,
      "Team": null,
      "FullName": 'Demo Coka',
      "Email": "Demo@coka.ai",
      "Phone": '84909719475',
      "Gender": "1 là nam, 0 là nữ",
      "Dob": null,
      "WorkspaceName":"KH_Nhóm làm việc",
      "Source.SourceName": "KH_Phân loại khách hàng",
      "Source.UtmSource": "KH_Nguồn khách hàng",
      "MaritalStatus": "1 là kết hôn, 0 là độc thân",
      "PhysicalId": null,
      "DateOfIssue": null,
      "PlaceOfIssue": null,
      "Address": null,
      "Rating": 0,
      "Avatar": null,
      "Work": null,
      "Status": 1,
      "Scope": 'PUBLIC',
      "StageId": '54032f73-108e-41a2-8ba6-aa9de96ab47b',
      "Stage": null,
      "Additional": [],
      "Social": [],
      "Source": [
        {
          "Id": 'd36c4e31-40c6-4fe3-81b9-0bee4c4a4b75',
          "SourceId": 'ce7f42cf-f10f-49d2-b57e-0c75f8463c82',
          "SourceName": 'Nhập vào | AIDC | Form',
          "ContactId": '2d03d888-e51e-4211-ad13-e024bd01d466',
          "FullName": 'Bánh Mì Tuấn Mập',
          "Email": null,
          "Phone": '84909719475',
          "Gender": null,
          "Dob": null,
          "Address": null,
          "Website": null,
          "UtmContent": null,
          "UtmCampaign": null,
          "UtmMedium": null,
          "UtmSource": "Google | Facebook | Zalo |...",
          "PageId": null,
          "FormId": null,
          "Note": null,
          "IpAddress": null,
          "OrganizatonName": '',
          "AutonomousSystemOrganization": 'AS-CHOOPA',
          "ConnectType": 'Cable/DSL',
          "City": 'Singapore (Queenstown Estate)',
          "Region": '',
          "Country": 'Singapore',
          "UserAgent": null,
          "Browser": null,
          "Device": null,
          "Os": null,
          "Brand": null,
          "Model": null,
          "Status": 1,
          "CreatedBy": '6ff09e5e-f2ae-49b3-8473-8b7f2c78b2ac',
          "CreatedDate": '2023-08-22T13:53:00.5257191Z',
          "LastModifiedBy": '6ff09e5e-f2ae-49b3-8473-8b7f2c78b2ac',
          "LastModifiedDate": '2023-08-22T13:53:00.5257194Z'
        }
      ],
      "CreatedBy": '6ff09e5e-f2ae-49b3-8473-8b7f2c78b2ac',
      "CreatedDate": '2023-08-22T13:53:00.5320667Z',
      "LastModifiedBy": '6ff09e5e-f2ae-49b3-8473-8b7f2c78b2ac',
      "LastModifiedDate": '2023-08-22T13:53:00.5320801Z'
    });
    testData.value = minimizeData(data);
    formatData.value = {
      "Email": "KH_Email",
      "FullName": "KH_Họ và Tên",
      "Phone": "KH_Số điện thoại",
      "Gender": "KH_Giới tính",
      "MaritalStatus": "KH_Tình trạng hôn nhân",
      "Rating": "KH_Điểm đánh giá",
      "WorkspaceName": "KH_Nhóm làm việc",
      "Source.SourceName": "KH_Phân loại khách hàng",
      "Source.UtmSource": "KH_Nguồn khách hàng",
    };

    update();
  }

  onSearchChanged(String query) {}
}
