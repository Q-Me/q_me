import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({
    Key key,
  }) : super(key: key);

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
          style: TextStyle(fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Search by location',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            prefixIcon: Icon(
              Icons.search,
            ),
          ),
        ),
      ),
    );
  }
}
