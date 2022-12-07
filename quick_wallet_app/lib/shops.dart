import 'package:convert/convert.dart';
import 'package:barcode_widget/barcode_widget.dart' show BarcodeType;
import 'package:quick_wallet_app/card.dart';

class Shop {
  final int id;
  final int? default_code_type;
  final String name;

  const Shop({required this.id, required this.name, this.default_code_type});


  Shop.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        default_code_type = json['default_code_type'];

  // Serialization to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'default_code_type': default_code_type ?? defaultBarcodeType.index,
  };
}


