import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(
        fontSize: 18,
      ),
      decoration: InputDecoration(
        hintText: 'Search...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        fillColor: Colors.black26,
        suffixIcon: Icon(
          Icons.search,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
