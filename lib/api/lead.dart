import 'dart:convert';
import 'dart:developer';

import 'package:coka/api/api_url.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import 'api_config.dart';

class LeadApi {
  final dio = ApiConfig().dio;
  Future getList(workspaceId, {String? provider = ""}) async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.get("/api/v1/integration/getlistpaging?Provider=$provider",
              options: Options(headers: {
                "workspaceId": workspaceId,
                "organizationId": jsonDecode(await getOData())["id"],
                "Content-Type": "application/json",
                "Authorization": "Bearer $apiToken",
              }));
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return response.data;
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future getFbMessageList(
      {String? provider = "",
      String? subscribed = "messages",
      String? searchText = ""}) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "/api/v1/integration/omnichannel/getlistpaging?Provider=$provider&Subscribed=$subscribed&searchText=$searchText&Fields=Name",
          options: Options(headers: {
            "organizationId": jsonDecode(await getOData())["id"],
            "Content-Type": "application/json",
            "Authorization": "Bearer $apiToken",
          }));
      log("response: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        log("response: ${response.data}");
        return response.data;
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future getFbLeadList(workspaceId,
      {String? provider = "", String? searchText = ""}) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "/api/v1/integration/lead/getlistpaging?Provider=$provider&searchText=$searchText&Fields=Name",
          options: Options(headers: {
            "workspaceId": workspaceId,
            "organizationId": jsonDecode(await getOData())["id"],
            "Content-Type": "application/json",
            "Authorization": "Bearer $apiToken",
          }));
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return response.data;
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future getZaloFormList(workspaceId) async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.get("/api/v1/integration/zalo/form/getlistpaging",
              options: Options(headers: {
                "workspaceId": workspaceId,
                "organizationId": jsonDecode(await getOData())["id"],
                "Content-Type": "application/json",
                "Authorization": "Bearer $apiToken",
              }));
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return response.data;
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future updateStatus(workspaceId, id, status) async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.patch("/api/v1/integration/updatestatus/$id?Status=$status",
              options: Options(headers: {
                "workspaceId": workspaceId,
                "organizationId": jsonDecode(await getOData())["id"],
                "Content-Type": "application/json",
                "Authorization": "Bearer $apiToken",
              }));
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return response.data;
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future updateZaloStatus(workspaceId, id, status) async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.patch("/api/v1/integration/zalo/form/updatestatus/$id",
              data: {"status": status},
              options: Options(headers: {
                "workspaceId": workspaceId,
                "organizationId": jsonDecode(await getOData())["id"],
                "Content-Type": "application/json",
                "Authorization": "Bearer $apiToken",
              }));
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return response.data;
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future updateFbFormStatus(workspaceId, id, status) async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.post("/api/v1/integration/facebook/form/subscribed",
              data: {"integrationAuthId": id, "status": status},
              options: Options(headers: {
                "workspaceId": workspaceId,
                "organizationId": jsonDecode(await getOData())["id"],
                "Content-Type": "application/json",
                "Authorization": "Bearer $apiToken",
              }));
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return response.data;
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future updateZaloLeadStatus(workspaceId, id, status) async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.patch("/api/v1/integration/zalo/form/updatestatus/$id",
              data: {"status": status},
              options: Options(headers: {
                "workspaceId": workspaceId,
                "organizationId": jsonDecode(await getOData())["id"],
                "Content-Type": "application/json",
                "Authorization": "Bearer $apiToken",
              }));
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return response.data;
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future updateLeadStatus(workspaceId, id, status) async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.patch("/api/v1/integration/lead/updatestatus/$id",
              data: {"status": status},
              options: Options(headers: {
                "workspaceId": workspaceId,
                "organizationId": jsonDecode(await getOData())["id"],
                "Content-Type": "application/json",
                "Authorization": "Bearer $apiToken",
              }));
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return response.data;
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future updateMessageStatus(id, status) async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.patch("/api/v1/integration/omnichannel/updatestatus/$id",
              data: {"status": status},
              options: Options(headers: {
                "organizationId": jsonDecode(await getOData())["id"],
                "Content-Type": "application/json",
                "Authorization": "Bearer $apiToken",
              }));
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return response.data;
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future zaloAutoMapping(workspaceId, formUrl) async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.post("/api/v1/integration/zalo/form/mappinggenerator",
              data: {"formUrl": formUrl},
              options: Options(headers: {
                "workspaceId": workspaceId,
                "organizationId": jsonDecode(await getOData())["id"],
                "Content-Type": "application/json",
                "Authorization": "Bearer $apiToken",
              }));
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return response.data;
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future zaloFormConnect(workspaceId, data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post("/api/v1/integration/zalo/form/connect",
          data: data,
          options: Options(headers: {
            "workspaceId": workspaceId,
            "organizationId": jsonDecode(await getOData())["id"],
            "Content-Type": "application/json",
            "Authorization": "Bearer $apiToken",
          }));
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return response.data;
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future facebookLeadConnect(workspaceId, data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post("/api/v1/auth/facebook/lead",
          data: data,
          options: Options(headers: {
            "workspaceId": workspaceId,
            "organizationId": jsonDecode(await getOData())["id"],
            "Content-Type": "application/json",
            "Authorization": "Bearer $apiToken",
          }));
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return response.data;
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future facebookMessageConnect(data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post("/api/v1/auth/facebook/message",
          data: data,
          options: Options(headers: {
            "organizationId": jsonDecode(await getOData())["id"],
            "Content-Type": "application/json",
            "Authorization": "Bearer $apiToken",
          }));
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return response.data;
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  void connectZaloPage() async {
    // TODO: Navigate to Zalo connection page
    print('Connect Zalo page');
    String token = await getAccessToken();

    String organizationId = jsonDecode(await getOData())["id"];
    String url =
        '$apiBaseUrl/api/v1/auth/zalo/message?accessToken=$token&organizationId=$organizationId';

    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault)) {
      throw Exception("Could not launch $url");
    }
  }

  Future facebookLeadManualConnect(data) async {
    final apiToken = await getAccessToken();
    // try {

    // HomeController homeController = Get.put(HomeController());
    // String workspaceId = homeController.workGroupCardDataValue['id'];

    final response = await dio.post("/api/v1/auth/facebook/message/manual",
        data: data,
        options: Options(headers: {
          "organizationId": jsonDecode(await getOData())["id"],
          // "workspaceId": workspaceId,
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiToken",
        }));
    return response.data;
    // } on DioException catch (e) {
    //   final response = e.response;
    //   if (response != null) {
    //     return response.data;
    //   } else {
    //     print(e.requestOptions);
    //     print(e.message);
    //   }
    // }
  }
}
