class BookingItemData {
  String subscriberName;
  int distance; // from the user's location in meters
  String
      newUpdate; // latest update from the subscriber end like new stock arrival etc
  String
      category; // which category the subscribers falls into like grocery store or bank or doctor
  String hotTag; // tag given like NEW or TRENDING

  BookingItemData(
      {this.subscriberName,
      this.distance,
      this.newUpdate,
      this.category,
      this.hotTag});
}
/*
const categories = {
  'Grocery Store': <BookingItemData>[
    BookingItemData(
      subscriberName: 'Annapurna Store',
      distance: 200,
      newUpdate: 'Wheat Stock arrives',
      hotTag: 'NEW',
      category: 'categories[0]',
    ),
  ],
  'Dairy': [],
  'Banks': [],
  'Medical Stores': []
}; // 'Grocery Store'};

List<BookingItemData> grocer = BookingItemData(
  subscriberName: 'Mother Dairy',
  distance: 200,
  newUpdate: 'all dairy items available',
  hotTag: 'NEW',
  category: 'Dairy',
);
//BookingItemData(
//subscriberName: 'SBI Bank',
//distance: 400,
//newUpdate: 'Cash deposits done',
//hotTag: 'NEW',
//    category: categories[2],
//  ),
//];
*/
