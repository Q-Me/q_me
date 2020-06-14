import 'package:flutter/material.dart';

enum Categories { Medical, Bank, Saloon, SuperMarket }

const Map<Categories, dynamic> categoryMap = {
  Categories.Medical: {
    "iconPath": 'assets/icons/medicine.png',
    "label": 'Medical Store',
  },
  Categories.Bank: {
    "icon": Icons.account_balance,
    "label": 'Bank',
  },
  Categories.SuperMarket: {
    "icon": Icons.shopping_cart,
    "label": 'Supermarket',
  },
  Categories.Saloon: {
    "iconPath": 'assets/icons/saloon.png',
    "label": 'Saloon',
  }
};

class CategoryBadge extends StatelessWidget {
  final String iconPath, label;
  final IconData icon;
  final bool pressed;
  CategoryBadge(
      {this.iconPath, @required this.label, this.icon, this.pressed = false});

  @override
  Widget build(BuildContext context) {
    Widget myIcon = iconPath != null
        ? Image.asset(
            // TODO push these images to server
            iconPath,
            color: pressed == true ? Colors.white : Colors.black,
            width: 25,
          )
        : Icon(
            icon,
            color: pressed == true ? Colors.white : Colors.black,
          );
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: pressed == true ? Colors.green : Colors.white,
        boxShadow: pressed == true
            ? []
            : [
                BoxShadow(
                    spreadRadius: 2,
                    color: Colors.green[200],
                    blurRadius: 3,
                    offset: Offset(0, 3))
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          myIcon,
          SizedBox(width: 5),
          Text(
            label,
            style:
                TextStyle(color: pressed == true ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }

  String getCategory() => label;
}
