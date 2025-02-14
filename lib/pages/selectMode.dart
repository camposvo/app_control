import 'package:control/helper/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:control/helper/constant.dart';
import 'package:control/providers/providers_pages.dart';



class SelectMode extends StatelessWidget {
  const SelectMode({super.key});

  @override
  Widget build(BuildContext context) {
    final info = Provider.of<ProviderPages>(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final organization = info.organizations.firstWhere((item) => item.orgaId == info.orgaId);
    print(organization.orgaNombre);



    return Scaffold(
        appBar: setAppBarTwo(context,organization.orgaNombre),
        body: Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
            child: Theme(
                data: ThemeData(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: AppColor.themeColor,
                        secondary: AppColor.secondaryColor,
                      ),
                ),
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [

                        SizedBox(
                          height: 100,
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(width -20, 40),
                              shape: StadiumBorder(),
                              backgroundColor: AppColor.backgroundBtnColor,
                              padding: EdgeInsets.all(10.0),
                          ),
                          onPressed: () async {
                            //await api.testNotify(info.persona.user.pkUsuario);
                            Navigator.pushNamed(context, 'instrument');
                          },
                          child: Text('Manual',  style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                          ),),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(width -20, 40),
                            shape: StadiumBorder(),
                            backgroundColor: AppColor.backgroundBtnColor,
                            padding: EdgeInsets.all(10.0),
                          ),
                          onPressed: () async {
                            //await api.testNotify(info.persona.user.pkUsuario);
                            Navigator.pushNamed(context, 'Automatico');
                          },
                          child: Text('Automatico',  style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                          ),),
                        ),
                      ],
                    ),
                  ),
                ))));
  }
}
