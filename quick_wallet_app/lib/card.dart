import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart' show BarcodeFormat;
import 'package:quick_wallet_app/user_session.dart';
import 'dart:convert';
import 'shops.dart';

// Card sizes
const cardHeight = 150.0;
const cardWidth = 238.0;
const defaultBarcodeType = BarcodeType.QrCode;
const userCardColor = Colors.deepPurpleAccent;

// Card class
class UserCard extends StatelessWidget {
  UserCard(
      {Key? key,
      required this.shop,
      required this.cardNumber,
      BarcodeType? barcode})
      : this.barcode = barcode ?? shop.default_code_type,
        super(key: key);

  UserCard.fromResponse(Map<String, dynamic> res, UserSession session) {
    shop =
        session.shops.singleWhere((element) => element.id == res['store_id']);
    cardNumber = res['code'];
    cardID = res['id'];
    barcode = BarcodeType.values[res['code_type']];
  }

  late Shop shop;
  int? cardID;
  late String cardNumber;
  late BarcodeType barcode;

  static BarcodeType convertBarcodeFormat(BarcodeFormat format) {
    BarcodeType ret;
    switch (format) {
      case BarcodeFormat.code128:
        ret = BarcodeType.Code128;
        break;
      case BarcodeFormat.code39:
        ret = BarcodeType.Code39;
        break;
      case BarcodeFormat.code93:
        ret = BarcodeType.Code93;
        break;
      case BarcodeFormat.codebar:
        ret = BarcodeType.Codabar;
        break;
      case BarcodeFormat.dataMatrix:
        ret = BarcodeType.DataMatrix;
        break;
      case BarcodeFormat.ean13:
        ret = BarcodeType.CodeEAN13;
        break;
      case BarcodeFormat.ean8:
        ret = BarcodeType.CodeEAN8;
        break;
      case BarcodeFormat.itf:
        ret = BarcodeType.Itf;
        break;
      case BarcodeFormat.upcA:
        ret = BarcodeType.CodeUPCA;
        break;
      case BarcodeFormat.upcE:
        ret = BarcodeType.CodeUPCE;
        break;
      case BarcodeFormat.pdf417:
        ret = BarcodeType.PDF417;
        break;
      case BarcodeFormat.aztec:
        ret = BarcodeType.Aztec;
        break;
      case BarcodeFormat.unknown:
      case BarcodeFormat.all:
      case BarcodeFormat.qrCode:
      default:
        ret = BarcodeType.QrCode;
        break;
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: cardHeight,
      width: cardWidth,
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey,
        // Decoration
        // image: DecorationImage(
        //     image: NetworkImage('https://yandex.ru/images/search?text=mastercard%20picture&from=tabbar&p=1&pos=37&rpt=simage&img_url=http%3A%2F%2Fmemberscommunitycu.org%2Fwp-content%2Fuploads%2F2018%2F06%2FMastercard-01.png&lr=65')
        // ),
        border: Border.all(
          color: Colors.grey,
          width: 5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10.0,
        ),
        child: Column(
          // textDirection: TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              shop.name,
              style: TextStyle(color: Colors.white),
            ),
            Text(
              cardNumber,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void showBarcode(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Container(
                color: Colors.white,
                child: Center(
                    child: BarcodeWidget(
                  data: cardNumber,
                  barcode: Barcode.fromType(barcode),
                  errorBuilder: (context, error) => Center(child: Text(error)),
                )))));
  }

  // Deserialization from JSON
  UserCard.fromJson(Map<String, dynamic> json)
      : shop = Shop.fromJson(json['shop']),
        cardNumber = json['code'],
        barcode = BarcodeType.values[json['code_type']],
        cardID = json['id'];

  // Serialization to JSON
  Map<String, dynamic> toJson() {
    var enc = {
      'code': cardNumber,
      'code_type': barcode.index,
      'shop': shop,
    };
    if (cardID != null) {
      enc['id'] = cardID!;
    }
    return enc;
  }

  Map<String, dynamic> toBody() => {
        'store_id': shop.id,
        'code': cardNumber,
        'code_type': barcode.index,
      };
}

class StubCard extends UserCard {
  StubCard() : super(shop: Shop.undefined(name: 'Add Card'), cardNumber: '');

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: cardHeight,
      width: cardWidth,
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: userCardColor,
        // Decoration
        // image: DecorationImage(
        //     image: NetworkImage('https://yandex.ru/images/search?text=mastercard%20picture&from=tabbar&p=1&pos=37&rpt=simage&img_url=http%3A%2F%2Fmemberscommunitycu.org%2Fwp-content%2Fuploads%2F2018%2F06%2FMastercard-01.png&lr=65')
        // ),
        border: Border.all(
          color: userCardColor,
          width: 5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        // textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            shop.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}
