import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qme/bloc/slotview_bloc.dart';

final String subscriberId = 'nplhS-7cJ';
final String accessToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IkVZRkpGbWlnMCIsIm5hbWUiOiJQaXl1c2giLCJwaG9uZSI6Iis5MTk2NzM1ODI1MTciLCJpc1VzZXIiOnRydWUsImlhdCI6MTU5NzkyNjAzNCwiZXhwIjoxNTk4MDEyNDM0fQ.dYjmeiiofpFXoYCd9EAh2U3CvGf7dZiFTdt7dC1IZEg';

void main() {
  group('Slot View Bloc Test', () {
    blocTest(
      'Initialise with Initial State',
      build: () => SlotViewBloc(
        subscriberId: subscriberId,
        accessToken: accessToken,
      ),
      expect: [],
    );
    blocTest(
      'Dated requested',
      build: () => SlotViewBloc(
        subscriberId: subscriberId,
        accessToken: accessToken,
      ),
      act: (bloc) => bloc.add(
        DatedReceptionsRequested(date: DateTime.now()),
      ),
      expect: [SlotViewLoading(), SlotViewLoadSuccess([])],
    );
  });
}
