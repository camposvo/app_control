import 'package:control/helper/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:control/helper/constant.dart';
import 'package:control/providers/providers_pages.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final info = Provider.of<ProviderPages>(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      drawer: setDrawer(context),
        appBar: setAppBarMain(context, "Ribe","Bienvenido"),
        body: Container(
            padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 40.0),
            child: Theme(
                data: ThemeData(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: AppColor.themeColor,
                        secondary: AppColor.secondaryColor,
                      ),
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                         SizedBox(
                        height: 100,
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(width -20, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                          ),
                            backgroundColor: AppColor.themeColor,
                            padding: EdgeInsets.all(10.0),
                        ),
                        onPressed: () async {
                          Navigator.pushNamed(context, 'organizations');
                        },
                        child: Text('Iniciar',  style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),),
                      ),
                    ],
                  ),
                ))));
  }
}
