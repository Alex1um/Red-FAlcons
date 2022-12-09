import 'package:flutter/material.dart';
import 'package:quick_wallet_app/user_session.dart';
import 'card.dart';
import 'package:barcode_widget/barcode_widget.dart'
    show BarcodeType, defaultBarcodeType;
import 'package:filter_list/filter_list.dart';
import 'shops.dart';

class CardAdder extends StatefulWidget {
  CardAdder(
      {super.key, this.cardNumber, this.barcodeType, required this.session});

  final UserSession session;
  BarcodeType? barcodeType;
  String? cardNumber;

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
  Shop? _cardShop;

  // Request on submit
  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await widget.session
          .addCard(UserCard(shop: _cardShop!, cardNumber: _cardNumber!, barcode: widget.barcodeType,));
      Navigator.pop(
        context,
      );
    }
  }

  void openShopSelector() async {
    await FilterListDelegate.show(
      context: context,
      list: widget.session.shops,
      onItemSearch: (shop, query) {
        return shop.name.toLowerCase().contains(query.toLowerCase());
      },
      onApplyButtonClick: (list) {
        setState(() {
          _cardShop = list![0];
        });
      },
      tileLabel: (shop) => shop!.name,
      enableOnlySingleSelection: true,

    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add new card'),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center,
          // padding: const EdgeInsets.symmetric(horizontal: 15),
          children: [
            Form(
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
                        // color: Theme.of(context).,
                        color: userCardColor,
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        textDirection: TextDirection.ltr,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              _cardShop == null ? 'Select shop' : _cardShop!.name,
                              // style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            onTap: openShopSelector,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.0,),
                            child: TextFormField(
                            decoration: InputDecoration(
                              label: const Text(
                                  'Card Number'
                              ),
                              errorText: _cardNumberError,
                            ),
                            onSaved: (number) {
                              _cardNumber = number!;
                            },
                            initialValue: widget.cardNumber,
                          ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
      bottomSheet:
      // Padding(
          // padding: EdgeInsets.symmetric(vertical: 100.0, horizontal: 15.0),
          // child:
        ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
              onPressed: _onSubmit,
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 24.0),
              ))
    // ),
    );
  }
}
