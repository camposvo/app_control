import 'package:control_slave/helper/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:control_slave/helper/constant.dart';
import 'package:control_slave/providers/providers_pages.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final info = Provider.of<ProviderPages>(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
        appBar: setAppBarTwo(context, "Bienvenido"),
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
                     /* Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            image:
                            DecorationImage(image: AssetImage(AppImage.fortuna))),
                      ),*/

                      SizedBox(
                        height: 100,
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(width -20, 40),
                            shape: StadiumBorder(),
                            backgroundColor: AppColor.themeColor,
                            padding: EdgeInsets.all(20.0),
                        ),
                        onPressed: () async {
                          //await api.testNotify(info.persona.user.pkUsuario);
                          Navigator.pushNamed(context, 'mainMenu');
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
