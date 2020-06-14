import 'dart:ui';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/base_helper.dart';
import '../bloc/queue.dart';
import '../model/token.dart';

import '../model/queue.dart';
import '../constants.dart';
import '../widgets/dash.dart';
import '../widgets/loader.dart';
import '../widgets/customStreamBuilder.dart';
import '../widgets/error.dart';
import '../utilities/time.dart';

/*
Display the token number, ETA, Distance
*/

class TokenScreen extends StatefulWidget {
  static const String id = '/token';
  final String queueId;
  TokenScreen({@required this.queueId});
  @override
  _TokenScreenState createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  Widget imgWidget = ClipRRect(
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
    child: Image.asset(
      'assets/images/profile_pic.jpg',
      fit: BoxFit.cover,
    ),
  );

  QueueBloc _queueDetailsBloc; //TODO Provide this

  @override
  void initState() {
    super.initState();
    _queueDetailsBloc = QueueBloc(widget.queueId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_queueDetailsBloc == null) {
      _queueDetailsBloc = QueueBloc(widget.queueId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.green,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: GestureDetector(
              onTap: () {
                // TODO to profile
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back_ios)),
          title: Text('Queue Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ChangeNotifierProvider.value(
            value: _queueDetailsBloc,
            child: RefreshIndicator(
              onRefresh: () => _queueDetailsBloc.fetchQueueData(),
              child: StreamBuilder<ApiResponse<Queue>>(
                stream: _queueDetailsBloc.queueStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    log('TokenPage Snapshot data: ${snapshot.data.toString()}');
                    switch (snapshot.data.status) {
                      case Status.LOADING:
                        return Loading(loadingMessage: snapshot.data.message);
                        break;
                      case Status.COMPLETED:
                        log('TokenPage COMPLETE Snapshot data: ${snapshot.data.data.toJson()}');

                        return QueueDetails(snapshot.data.data);
                        break;
                      case Status.ERROR:
                        return Error(
                          errorMessage: snapshot.data.message,
                          onRetryPressed: () =>
                              _queueDetailsBloc.fetchQueueData(),
                        );
                        break;
                    }
                  } else {
                    Text('no Snapshot data');
                  }
                  return Container();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QueueDetails extends StatefulWidget {
  final Queue queue;
  QueueDetails(this.queue) {
    log('QueueDetails constructor:${queue.toJson()}');
  }
  @override
  _QueueDetailsState createState() => _QueueDetailsState();
}

class _QueueDetailsState extends State<QueueDetails> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue[200],
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10))),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.queue.subscriber.name,
                            style: kBigTextStyle.copyWith(color: Colors.black)),
                        Text(widget.queue.subscriber.owner),
                        Text(
                          widget.queue.subscriber.address,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Grid2x2(Provider.of<QueueBloc>(context).queue),
              DashContainer(),
              TokenInfo(queue: widget.queue),
            ],
          ),
        ),
      ],
    );
  }
}

class TokenInfo extends StatefulWidget {
  final Queue queue;
  TokenInfo({this.queue});
  @override
  _TokenInfoState createState() => _TokenInfoState();
}

class _TokenInfoState extends State<TokenInfo> {
  bool validToken;
  QueueToken myToken;
  QueueBloc _queueDetailsBloc;

  @override
  Widget build(BuildContext context) {
    _queueDetailsBloc = Provider.of<QueueBloc>(context);
    return CustomStreamBuilder<ApiResponse<String>>(
      stream: _queueDetailsBloc.msgStream,
      initialWidget: GetTokenButton(),
      builder: (context, data) {
        log('msg stream: ${data.toString()}');
        switch (data.status) {
          case Status.LOADING:
            return Loading(
              loadingMessage: data.message,
            );
            break;
          case Status.COMPLETED:
            if (data.data == 'User not in queue.' ||
                data.data == 'Token cancelled successfully') {
              return GetTokenButton();
            } else if (data.data == 'User added to queue successfully.' ||
                data.data == 'User already  in queue.') {
              // There will be a token in the token stream, fetch that
              final tokenData = Provider.of<QueueBloc>(context).queue.token;
              log('tokenData from provider : ${tokenData.toJson()}');
              if (tokenData is QueueToken && tokenData.tokenNo != -1) {
                return Column(children: <Widget>[
                  TokenDisplay(tokenData.tokenNo),
                  CancelTokenButton(),
                ]);
              } else {
                return GetTokenButton();
              }
            }
            break;
          case Status.ERROR:
            return Error(
              errorMessage: data.message,
              onRetryPressed: () => _queueDetailsBloc.fetchQueueData(),
            );
            break;
        }
        return Container();
      },
    );
  }
}

class GetTokenButton extends StatelessWidget {
  const GetTokenButton({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _queueDetailsBloc = Provider.of<QueueBloc>(context);
    return Container(
      height: 50.0,
      margin: EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Material(
        borderRadius: BorderRadius.circular(20.0),
        shadowColor: Colors.greenAccent,
        color: Colors.green,
        elevation: 7.0,
        child: InkWell(
          onTap: () {
            // TODO Call api to get token
            _queueDetailsBloc.joinQueue();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                'Get Token',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CancelTokenButton extends StatelessWidget {
  const CancelTokenButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _queueDetailsBloc = Provider.of<QueueBloc>(context);
    return Container(
      height: 50.0,
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.red),
        borderRadius: BorderRadius.circular(20.0),
      ),
      alignment: Alignment.center,
      child: Material(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
        child: InkWell(
          onTap: () {
            // TODO Call api to join queue
            log('Calling cancel token on ${_queueDetailsBloc.queueId}');
            _queueDetailsBloc.cancelToken();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                'Cancel Token',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 10,
            decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10))),
          ),
          Expanded(
            child: Center(
                child: Dash(
                    direction: Axis.horizontal, dashColor: Colors.black38)),
          ),
          Container(
            width: 10,
            decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10))),
          ),
        ],
      ),
    );
  }
}

class TokenDisplay extends StatelessWidget {
  final int tokenNo;
  TokenDisplay(this.tokenNo);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Your Token Number',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 26),
            ),
            Text(
              tokenNo.toString(),
              style: kBigTextStyle.copyWith(fontSize: 50),
            ),
          ],
        ),
      ),
    );
  }
}

class Grid2x2 extends StatelessWidget {
  final Queue queue;
  Grid2x2(this.queue);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      child: Table(
        children: [
          TableRow(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                child: Grid2x2Item(
                  'Starts at',
                  '${getTime(queue.startDateTime)}',
                  '${getDate(queue.startDateTime)}',
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                child: Grid2x2Item(
                  'Ends at',
                  '${getTime(queue.endDateTime)}',
                  '${getDate(queue.endDateTime)}',
                )),
          ]),
          TableRow(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0.0),
                child: Grid2x2Item(
                  'Already in queue',
                  '${queue.totalIssuedTokens}',
                  'People',
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0.0),
                child: Grid2x2Item(
                  'Your turn may come at',
                  getTime(DateTime.now().add(queue.eta)).toString(),
                  getDate(DateTime.now().add(queue.eta)).toString(),
                )),
          ])
        ],
      ),
    );
  }
}

class Grid2x2Item extends StatelessWidget {
  final String top, center, bottom;
  Grid2x2Item(this.top, this.center, this.bottom);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(top, style: kSmallTextStyle),
        Text(center, style: kBigTextStyle),
        Text(bottom, style: kSmallTextStyle),
      ],
    );
  }
}
