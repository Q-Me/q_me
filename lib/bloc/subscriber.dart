import '../repository/subscribers.dart';
import 'dart:async';
import '../api/base_helper.dart';
import '../model/subscriber.dart';

class SubscribersBloc {
  SubscribersRepository _subscribersRepository;

  StreamController _subscribersListController;

  StreamSink<ApiResponse<List<Subscriber>>> get subscribersListSink =>
      _subscribersListController.sink;

  Stream<ApiResponse<List<Subscriber>>> get subscribersListStream =>
      _subscribersListController.stream;

  SubscribersBloc() {
    _subscribersListController =
        StreamController<ApiResponse<List<Subscriber>>>();
    _subscribersRepository = SubscribersRepository();
    fetchSubscribersList();
  }

  fetchSubscribersList() async {
    subscribersListSink
        .add(ApiResponse.loading('Fetching Popular Subscribers'));
    try {
      List<Subscriber> subscribers =
          await _subscribersRepository.fetchSubscriberList();
      subscribersListSink.add(ApiResponse.completed(subscribers));
    } catch (e) {
      subscribersListSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _subscribersListController?.close();
  }
}

class SingleSubscriberBloc {
  SingleSubscriberRepository _subscriberRepository;

  StreamController _subscriberController;

  StreamSink<ApiResponse<Subscriber>> get subscriberSink =>
      _subscriberController.sink;

  Stream<ApiResponse<Subscriber>> get subscribersListStream =>
      _subscriberController.stream;

  SingleSubscriberBloc(String subscriberId) {
    _subscriberController = StreamController<ApiResponse<Subscriber>>();
    _subscriberRepository = SingleSubscriberRepository();
    fetchSubscriber(subscriberId);
  }

  fetchSubscriber(String subscriberId) async {
    subscriberSink.add(ApiResponse.loading('Fetching subscriber details'));
    try {
      Subscriber subscriber =
          await _subscriberRepository.fetchSubscriber(subscriberId);
      subscriberSink.add(ApiResponse.completed(subscriber));
    } catch (e) {
      subscriberSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _subscriberController?.close();
  }
}
