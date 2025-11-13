import 'dart:convert';

import 'package:dio/dio.dart';

import '../constants.dart';
import 'api_url.dart';

class OrganApi {
  final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));

  Future getListOrgan() async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get("$getOrganizationListApi?limit=100",
          options: Options(headers: {
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

  Future getOrganQR() async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.get(getOrganizationQrCodeApi((await getOData())["id"]),
              options: Options(headers: {
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

  Future getOrgan() async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          getOrganizationDetailApi + jsonDecode(await getOData())["id"],
          options: Options(headers: {
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

  Future getOrganV2(String organizationId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(getOrganizationDetailApiV2(organizationId),
          options: Options(headers: {
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

  Future getOrganMembers(searchText, offset, {int? status}) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getOrgMemberListApi?SearchText=$searchText&Status=${status ?? ""}&Fields=[fullName]&offset=$offset&limit=20",
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

  Future grantRoleOrganMember(profileId, role) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(postOrgRoleMemberApi,
          data: {"profileMemberId": profileId, "role": role},
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

  Future deleteOrganMember(profileId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.delete(deleteOrgMemberApi + profileId,
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

  Future createOrgan(data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(postOrganizationCreateApi,
          data: data,
          options: Options(headers: {
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

  Future updateOrgan(data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.put(
          patchOrganizationUpdateApi + jsonDecode(await getOData())["id"],
          data: data,
          options: Options(headers: {
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

  Future deleteOrgan() async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.delete(
          deleteOrganizationApi + jsonDecode(await getOData())["id"],
          options: Options(headers: {
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

  Future leaveOrgan() async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.delete(leaveOrganizationApi,
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

  Future getOrgMembersForSelection(
      {String searchText = "",
      int offset = 0,
      int limit = 1000,
      int status = 1}) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getOrgMemberListApi?searchText=$searchText&offset=$offset&limit=$limit&status=$status",
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
}
