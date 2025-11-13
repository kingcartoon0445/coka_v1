import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../constants.dart';
import 'api_url.dart';

class CustomerApi {
  final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));

  Future getCustomerList(
    workspaceId,
    offset,
    limit, {
    String? filter,
    String? groupId = "",
    String? searchText = "",
    String? stageList = "",
    String? ratingList = "",
    String? memberList = "",
    String? teamList = "",
    String? tagList = "",
    startDate = "",
    endDate = "",
    String? categoryList = "",
    String? sourceList = "",
  }) async {
    var filterData = filter ?? '[{ Column: "lastModifiedDate", Dir: "DESC" }]';
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getCustomerListApi?Limit=$limit&Offset=$offset&Sort=$filterData&StageGroupId=$groupId&SearchText=$searchText&Fields=FullName&StartDate=$startDate&EndDate=$endDate$stageList$ratingList$memberList$teamList&view=FULL$categoryList$sourceList$tagList",
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

  Future getDetailCustomer(workspaceId, contactId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(getDetailCustomerApi + contactId,
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

  Future createCustomer(workspaceId, data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(createCustomerApi,
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

  Future updateCustomer(workspaceId, customerId, data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.put("$updateCustomerApi$customerId",
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

  Future assignToCustomer(workspaceId, customerId, data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.patch("$updateCustomerApi$customerId/assignto",
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

  Future updateAvatarCustomer(workspaceId, customerId, data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.patch("$updateCustomerApi$customerId/avatar",
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

  Future updateRatingCustomer(workspaceId, customerId, rating) async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.patch("$updateCustomerApi$customerId/rating?rating=$rating",
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

  Future importCustomer(workspaceId, data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(importCustomerApi,
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

  Future deleteCustomer(workspaceId, customerId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.delete("$updateCustomerApi$customerId",
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

  Future getJourneyList(workspaceId, contactId, {String? filter}) async {
    var filterData = filter ?? '[{ Column: "lastModifiedDate", Dir: "ASC" }]';
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$journeyApi$contactId/journey?Limit=100&Offset=0&Sort=$filterData",
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

  Future updateJourney(workspaceId, contactId, data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post("$journeyApi$contactId/note",
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

  Future checkPhone(workspaceId, data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(phoneCheckApi,
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

  Future getTagList(workspaceId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(getTagListApi,
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

  Future getSourceList(workspaceId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(getSourceListApi,
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

  Future getStatisticsByStageGroup(
    workspaceId, {
    String? searchText = "",
    String? stageGroupId = "",
    String? startDate = "",
    String? endDate = "",
    String? categoryList = "",
    String? sourceList = "",
    String? rating = "",
    String? tags = "",
    String? assignTo = "",
    String? teamId = "",
  }) async {
    final apiToken = await getAccessToken();
    try {
      print(
          "Bắt đầu gọi API getStatisticsByStageGroup với workspaceId=$workspaceId");

      // Xây dựng URL với các tham số không rỗng
      String url = "$statisticsByStageGroup?workspaceId=$workspaceId";

      // Thêm các tham số không rỗng vào URL
      if (searchText != null && searchText.isNotEmpty) {
        url += "&searchText=$searchText";
      }

      if (stageGroupId != null && stageGroupId.isNotEmpty) {
        url += "&stageGroupId=$stageGroupId";
      }

      // if (startDate != null && startDate.isNotEmpty) {
      //   url += "&startDate=$startDate";
      // }

      // if (endDate != null && endDate.isNotEmpty) {
      //   url += "&endDate=$endDate";
      // }

      if (categoryList != null && categoryList.isNotEmpty) {
        url += "&categoryList=$categoryList";
      }

      if (sourceList != null && sourceList.isNotEmpty) {
        url += "&sourceList=$sourceList";
      }

      // Chỉ thêm rating khi không rỗng
      if (rating != null && rating.isNotEmpty) {
        url += "&rating=$rating";
      }

      if (tags != null && tags.isNotEmpty) {
        url += "&tags=$tags";
      }

      if (assignTo != null && assignTo.isNotEmpty) {
        url += "&assignTo=$assignTo";
      }

      if (teamId != null && teamId.isNotEmpty) {
        url += "&teamId=$teamId";
      }

      print("URL API: $url");
      String orId = jsonDecode(await getOData())["id"];
      Map<String, dynamic> header = {
        "Content-Type": "application/json",
        "organizationId": orId,
        "Authorization": "Bearer $apiToken",
      };
      log("duy url: " + url);
      log("duy header: " + header.toString());

      final response = await dio.get(url, options: Options(headers: header));

      print("duy Kết quả API: ${response.statusCode}");

      if (response.data != null) {
        // Kiểm tra dữ liệu trả về
        if (response.data["content"] == null) {
          print("API trả về content null");
          response.data["content"] = [];
        }

        // Kiểm tra từng phần tử trong content
        if (response.data["content"] is List) {
          List contentList = response.data["content"];
          for (int i = 0; i < contentList.length; i++) {
            var item = contentList[i];
            // Đảm bảo count không null
            if (item["count"] == null) {
              print("Phát hiện count null trong item: $item");
              item["count"] = 0;
            }
            // Đảm bảo groupName không null
            if (item["groupName"] == null) {
              print("Phát hiện groupName null trong item: $item");
              item["groupName"] = "Không xác định";
            }
          }
        }
      }

      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      log("duy " + response!.data.toString());
      print("DioException khi gọi API getStatisticsByStageGroup: ${e.message}");
      if (response != null) {
        print("Response error data: ${response.data}");
        return response.data;
      } else {
        print("Request options: ${e.requestOptions}");
        print("Error message: ${e.message}");
        return {
          "code": -1,
          "message": "Lỗi kết nối: ${e.message}",
          "content": []
        };
      }
    } catch (e) {
      print("Lỗi không xác định khi gọi API getStatisticsByStageGroup: $e");
      return {"code": -1, "message": "Lỗi không xác định: $e", "content": []};
    }
  }
}
