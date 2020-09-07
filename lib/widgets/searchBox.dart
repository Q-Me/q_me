import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qme/bloc/home_bloc/home_bloc.dart';
import 'package:qme/utilities/logger.dart';

class SearchBox extends StatefulWidget {
  const SearchBox({
    Key key,
  }) : super(key: key);

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  TextEditingController _controller;
  final FocusNode _searchFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 10),
              // spreadRadius: 10,
              blurRadius: 20,
              color: Colors.black26,
            )
          ]),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 40,
        child: TextFormField(
          controller: _controller,
          focusNode: _searchFocus,
          style: TextStyle(fontSize: 18),
          textInputAction: TextInputAction.search,
          onFieldSubmitted: (value) {
            BlocProvider.of<HomeBloc>(context).add(SetLocation(value));
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search by location',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          ),
          onEditingComplete: () {
            _searchFocus.unfocus();
          },
        ),
      ),
    );
  }
}
