import 'package:flutter/material.dart';


import 'package:control/helper/constant.dart';
import 'package:provider/provider.dart';

import '../pages/controlList.dart';
import '../providers/providers_pages.dart';


class TabBarPage extends StatefulWidget {
  @override
  _TabBarPageState createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> {
  bool isButtonClick = false;
  //int selectedIndex = 0;

  final List<Widget> listScreen = [

  ];

  @override
  Widget build(BuildContext context) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    return new Scaffold(
      body: listScreen[info.selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColor.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: info.selectedIndex,
          onTap: (index) => onTabTapped(context, index),
          items: [
            new BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              activeIcon: Icon(
                Icons.home,
                color: Colors.blue,
              ),
              label:"Armar Pedido",
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.add_box),
              activeIcon: Icon(
                Icons.add_box,
                color:Colors.blue,
              ),
              label: "Guardar Bacha",
            ),
          ]),
    );
  }

  void onTabTapped(BuildContext context, int index) {
    print("index${ index}");
    final info = Provider.of<ProviderPages>(context, listen: false);
    setState(() {
      info.selectedIndex = index;
    });


  }
}
