import 'package:flutter/material.dart';
import 'card.dart';
import 'package:barcode_widget/barcode_widget.dart'
    show BarcodeType, defaultBarcodeType;

class CardAdder extends StatefulWidget {
  CardAdder({super.key, this.cardNumber, this.cardName, this.barcodeType});

  BarcodeType? barcodeType;
  String? cardNumber;
  String? cardName;

  @override
  State<StatefulWidget> createState() => _CardAdder();
}

class _CardAdder extends State<CardAdder> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // _CardAdder(this._cardNumber, this._cardName);
  // Showing error below email field
  String? _cardNumberError;

  // Showing error below password field
  String? _cardNameError;

  // Email field value
  String? _cardNumber;

  // Password field value
  String? _cardName;

  // Request on submit
  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(
          context,
          UserCard(
            cardNumber: _cardNumber!,
            barcodeType: widget.barcodeType ?? defaultBarcodeType,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
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
                      TextFormField(
                        decoration: InputDecoration(
                          label: const Text('Shop name'),
                          errorText: _cardNameError,
                        ),
                        onSaved: (name) {
                          _cardName = name!;
                        },
                        initialValue: widget.cardName,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          label: const Text('Card Number'),
                          errorText: _cardNumberError,
                        ),
                        onSaved: (number) {
                          _cardNumber = number!;
                        },
                        initialValue: widget.cardNumber,
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(onPressed: _onSubmit, child: const Text('Submit'))
            ],
          ),
        ),
      ),
    );
  }
}
