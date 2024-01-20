// ignore: file_names
class Pojo {
  int? id;
  String item;
  String merchant;
  double price;
  String payment;
  String category;
  String ctime;

  Pojo({
    this.id,
    required this.item,
    required this.merchant,
    required this.price,
    required this.payment,
    required this.category,
    required this.ctime,
  });

  factory Pojo.fromMap(Map<String, dynamic> json) => Pojo(
        id: json['id'],
        item: json['item'],
        merchant: json['merchant'],
        price: json['price'],
        payment: json['payment'],
        category: json['category'],
        ctime: json['ctime'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item': item,
      'merchant': merchant,
      'price': price,
      'payment': payment,
      'category': category,
      'ctime': ctime,
    };
  }
}
