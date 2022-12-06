import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart' show BarcodeFormat;
import 'dart:convert';

// Card sizes
const cardHeight = 150.0;
const cardWidth = 238.0;

// Card class
class UserCard extends StatelessWidget {
  UserCard({Key? key, required this.nameOfShop, required this.cardNumber, this.barcodeType = BarcodeType.QrCode})
      : super(key: key) {
    // TODO: add Barcode type recognizer
    barcodeType = BarcodeType.QrCode;
  }

  UserCard.fromScan({Key? key, required this.nameOfShop, required this.cardNumber, required BarcodeFormat format})
      : super(key: key) {
    barcodeType = convertBarcodeFormat(format);
  }

  final String nameOfShop;
  final String cardNumber;
  late BarcodeType barcodeType;

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
      child: Column(
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(nameOfShop,
              style: TextStyle(color: Theme.of(context).primaryColorDark)),
          Text(cardNumber, textAlign: TextAlign.center),
        ],
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
                      barcode: Barcode.fromType(barcodeType),
                      errorBuilder: (context, error) => Center(child: Text(error)),
                )))));
  }

  // Deserialization from JSON
  UserCard.fromJson(Map<String, dynamic> json)
      : nameOfShop = json['name'],
        cardNumber = json['number'],
        barcodeType = json['barcode'] as BarcodeType;

  // Serialization to JSON
  Map<String, dynamic> toJson() => {
        'name': nameOfShop,
        'number': cardNumber,
        'barcode': barcodeType.index,
      };
}

class StubCard extends UserCard {
  StubCard({super.nameOfShop = 'Add Card', super.cardNumber = ''});

  @override
  void showBarcode(BuildContext context) {
  }

}
