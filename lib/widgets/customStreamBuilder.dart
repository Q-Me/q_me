import 'dart:async';
import 'package:flutter/material.dart';

class CustomStreamBuilder<State> extends StatelessWidget {
  final Stream stream;
  final Widget errorWidget;
  final Widget initialWidget;
  final Widget Function(BuildContext context, State state) builder;

  CustomStreamBuilder(
      {@required this.stream,
      @required this.builder,
      this.errorWidget,
      this.initialWidget});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<State>(
      stream: stream,
      builder: (context, AsyncSnapshot<State> snapshot) {
        if (snapshot.hasError) {
          return errorWidget != null ? errorWidget : _buildErrorWidget(context);
        }
        if (!snapshot.hasData) {
          return initialWidget != null
              ? initialWidget
              : _buildBlankWidget(context);
        }
        return builder(context, snapshot.data);
      },
    );
  }

  Widget _buildErrorWidget(context) {
    return Text('error widget');
  }

  Widget _buildBlankWidget(context) {
    return Text('blank widget');
  }
}
