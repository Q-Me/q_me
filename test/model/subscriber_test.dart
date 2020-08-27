import 'dart:convert';

import 'package:qme/model/subscriber.dart';
import 'package:test/test.dart';

void main() {
  test('w/ json ...', () {
    final testSubscriber = Subscriber.fromJson(
      json.decode(r'''
            {
            "id": "lJELQyMtS",
            "name": "S1",
            "description": "NULL",
            "owner": "Kavya",
            "email": "Kavya24@gmail.com",
            "phone": "+918585992062",
            "address": "Patna Estate",
            "tags": "[\"ABC\",\"CDE\"]",
            "longitude": 85.594095,
            "latitude": 25.137566,
            "rating": 5,
            "category": "Saloon",
            "profileImage": null,
            "verified": 0,
            "displayImages": ["lJELQyMtS_1.jpeg","lJELQyMtS_2.png"]
          }'''),
    );
    print(testSubscriber.toJson());
    expect(
      testSubscriber,
      Subscriber(
        id: "lJELQyMtS",
        name: "S1",
        description: "",
        owner: "Kavya",
        email: "Kavya24@gmail.com",
        phone: "+918585992062",
        address: "Patna Estate",
        tags: List<String>.from(["ABC", "CDE"]),
        longitude: 85.594095,
        latitude: 25.137566,
        rating: 5,
        category: "Saloon",
        displayImages: List<String>.from(["lJELQyMtS_1.jpeg", "lJELQyMtS_2.png"]),
        verified: false,
      ),
    );
  });
}
