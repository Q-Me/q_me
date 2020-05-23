import '../model/token.dart';
import 'dart:async';
import '../model/user.dart';
import '../api/base_helper.dart';
import '../api/endpoints.dart';

class TokenRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<Map<String, dynamic>> joinQueue(String queueId) async {
    final UserData userData = await getUserDataFromStorage();
    final response = await _helper.post(
      kJoinQueue,
      headers: {'Authorization': 'Bearer ${userData.accessToken}'},
      req: {'queue_id': queueId},
    );
    return {
      'msg': response['msg'],
      'token': QueueToken(tokenNo: response['token_no'])
    };
  }

  Future<Map<String, dynamic>> cancelToken(String queueId) async {
    final UserData userData = await getUserDataFromStorage();
    final response = await _helper.post(
      kCancelToken,
      headers: {'Authorization': 'Bearer ${userData.accessToken}'},
      req: {'queue_id': queueId},
    );
    return response;
  }

  Future<Map<String, dynamic>> getTokens(String status) async {
    final UserData userData = await getUserDataFromStorage();
    final response = await _helper.post(
      kGetTokens,
      headers: {'Authorization': 'Bearer ${userData.accessToken}'},
      req: {'status': status},
    );
    return response['token'].map((token) => QueueToken.fromJson(token)).toList();
  }
}
