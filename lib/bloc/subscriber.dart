import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:qme/api/base_helper.dart';
import 'package:qme/model/queue.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/appointment.dart';
import 'package:qme/repository/queue.dart';
import 'package:qme/repository/subscribers.dart';
import 'package:qme/utilities/logger.dart';

class SubscriberBloc2 extends ChangeNotifier {
  Subscriber subscriber;
  String subscriberId, queueStatus, accessToken;

  SubscriberRepository _subscriberRepository;

  StreamController _imagesController;

  StreamSink<ApiResponse<List<String>>> get imagesSink =>
      _imagesController.sink;

  Stream<ApiResponse<List<String>>> get imageStream => _imagesController.stream;

  SubscriberBloc2(this.subscriberId) {
    _imagesController = StreamController<ApiResponse<List<String>>>();

    _subscriberRepository = SubscriberRepository();

    fetchSubscriberDetails();
  }

  fetchSubscriberDetails() async {
    imagesSink.add(ApiResponse.loading('Loading images'));
    try {
      accessToken = await getAccessTokenFromStorage();
      subscriber = await _subscriberRepository.fetchSubscriberDetails(
          subscriberId: subscriberId);
      imagesSink.add(ApiResponse.completed(subscriber.displayImages));
      notifyListeners();
    } on Exception catch (e) {
      logger.e(e.toString());
      imagesSink.add(ApiResponse.error(e.toString()));
    }
  }

  // fetchSubscriberReviews() async{
  //   try{
  //     accessToken = await getAccessTokenFromStorage();

  //   }
  // }

  dispose() {
    super.dispose();
    _imagesController?.close();
  }
}
