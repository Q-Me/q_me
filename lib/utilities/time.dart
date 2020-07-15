import 'package:intl/intl.dart';
import 'package:qme/model/queue.dart';

String getDate(DateTime dateTime) => DateFormat("dd-MM-yyyy").format(dateTime);

String getTimeAmPm(DateTime dateTime) => DateFormat("jm").format(dateTime);

DateTime nextTokenTime(Queue queue) => queue.startDateTime.add(
      Duration(
        minutes: queue.totalIssuedTokens * queue.avgTimeOnCounter,
      ),
    );
