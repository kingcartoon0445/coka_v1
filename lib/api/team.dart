import 'dart:convert';

import 'package:coka/api/api_url.dart';
import 'package:coka/constants.dart';
import 'package:dio/dio.dart';


class TeamApi {
  final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));

  Future getTeamList(workspaceId, searchText, {bool? isTreeView}) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$teamApi/getlistpaging?Limit=200&Offset=0&SearchText=$searchText&IsTreeView=${isTreeView ?? true}&Status=1&Sort=[{ Column: 'Name', Dir: 'ASC' }]",
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

  Future getDetailTeam(workspaceId, teamId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get("$teamApi/getdetail/$teamId",
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

  Future createTeam(workspaceId, data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post("$teamApi/create",
          data: data,
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

  Future updateTeam(workspaceId, teamId, data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.put("$teamApi/update/$teamId",
          data: data,
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

  Future deleteTeam(workspaceId, teamId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.delete("$teamApi/delete/$teamId",
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

  Future setRole(workspaceId, teamId, profileId, role) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post("$teamApi/$teamId/user/role",
          data: {"profileId": profileId, "role": role},
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

  Future deleteManager(workspaceId, teamId, profileId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.delete("$teamApi/$teamId/user/role",
          data: {"profileId": profileId},
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

  Future getMemberInTeamList(workspaceId, teamId, searchText) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$teamApi/$teamId/user/getlistpaging?SearchText=$searchText&Status=1",
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

  Future getMemberInWorkspaceList(workspaceId, searchText) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$teamApi/user/getlistpaging?SearchText=$searchText&Fields=FULLNAME&Limit=200",
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

  Future addMember(workspaceId, teamId, profileId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post("$teamApi/$teamId/user/add",
          data: {"profileId": profileId},
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

  Future deleteMember(workspaceId, teamId, profileId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.delete("$teamApi/$teamId/user/$profileId",
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
}
