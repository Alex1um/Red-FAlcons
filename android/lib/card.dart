import 'package:flutter/material.dart';


class UserCard extends StatelessWidget {
  const UserCard({Key? key, required this.nameOfShop, required this.cardNumber}) : super(key: key);
  final String nameOfShop;
  final String cardNumber;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 150,
      width: 238,
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
        children: <Widget> [
          Text(nameOfShop, style: TextStyle(color: Theme.of(context).primaryColorDark)),
          Text(cardNumber, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
