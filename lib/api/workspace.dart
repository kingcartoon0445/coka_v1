import 'dart:convert';

import 'package:coka/screen/home/home_controller.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../constants.dart';
import 'api_url.dart';

class WorkspaceApi {
  final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));

  Future getWorkspaceList(searchText) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getWorkspaceListApi?Limit=100&Offset=0&$sortDesc&searchText=$searchText&Status=1",
          options: Options(headers: {
            "Content-Type": "application/json",
            "organizationId": jsonDecode(await getOData())["id"],
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

  Future getWorkspaceMembersList(workspaceId, searchText) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getWorkspaceMemberListApi?Limit=200&Offset=0&$sortDesc&SearchText=$searchText&Status=1",
          options: Options(headers: {
            "Content-Type": "application/json",
            "workspaceId": workspaceId,
            "organizationId": jsonDecode(await getOData())["id"],
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

  Future grantRole(workspaceId, profileId, role) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(postWorkspaceGrantRoleApi,
          data: {
            "profileMemberId": profileId,
            "role": role,
          },
          options: Options(headers: {
            "Content-Type": "application/json",
            "workspaceId": workspaceId,
            "organizationId": jsonDecode(await getOData())["id"],
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

  Future addMember(workspaceId, profileId) async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.post("$addMemberToWorkspaceApi?profileId=$profileId",
              options: Options(headers: {
                "Content-Type": "application/json",
                "workspaceId": workspaceId,
                "organizationId": jsonDecode(await getOData())["id"],
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

  Future createWorkspace(data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(createWorkspaceApi,
          data: data,
          options: Options(headers: {
            "Content-Type": "application/json",
            "organizationId": jsonDecode(await getOData())["id"],
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

  Future updateWorkspace(data, workspaceId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.put("$updateWorkspaceApi$workspaceId",
          data: data,
          options: Options(headers: {
            "Content-Type": "application/json",
            "organizationId": jsonDecode(await getOData())["id"],
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

  Future updateAutomationWorkspace(data, workspaceId) async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.patch("$updateAutomationWorkspaceApi$workspaceId",
              data: data,
              options: Options(headers: {
                "Content-Type": "application/json",
                "organizationId": jsonDecode(await getOData())["id"],
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

  Future getWorkspaceDetail(workspaceId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get("$getWorkspaceDetailApi$workspaceId",
          options: Options(headers: {
            "Content-Type": "application/json",
            "organizationId": jsonDecode(await getOData())["id"],
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

  Future deleteWorkspace() async {
    final homeController = Get.put(HomeController());
    final apiToken = await getAccessToken();
    try {
      final response = await dio.delete(
          "$deleteWorkspaceApi${homeController.workGroupCardDataValue["id"]}",
          options: Options(headers: {
            "Content-Type": "application/json",
            "organizationId": jsonDecode(await getOData())["id"],
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

  Future leaveWorkspace() async {
    final homeController = Get.put(HomeController());
    final apiToken = await getAccessToken();
    try {
      final response = await dio.delete(leaveWorkspaceApi,
          options: Options(headers: {
            "Content-Type": "application/json",
            "workspaceId": homeController.workGroupCardDataValue["id"],
            "organizationId": jsonDecode(await getOData())["id"],
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

  Future deleteMemberWorkspace(profileId) async {
    final homeController = Get.put(HomeController());
    final apiToken = await getAccessToken();
    try {
      final response = await dio.delete("$addMemberToWorkspaceApi/$profileId",
          options: Options(headers: {
            "Content-Type": "application/json",
            "organizationId": jsonDecode(await getOData())["id"],
            "workspaceId": homeController.workGroupCardDataValue["id"],
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
}
