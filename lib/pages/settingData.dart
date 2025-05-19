import 'dart:convert';

import 'package:control/helper/common_widgets.dart';
import 'package:control/helper/util.dart';
import 'package:control/models/resultRevision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:control/helper/constant.dart';
import 'package:control/providers/providers_pages.dart';

import '../api/client.dart';
import '../models/orgaInstrumento.dart';

class SettingData extends StatefulWidget {
  @override
  State<SettingData> createState() => _SettingDataState();
}

class _SettingDataState extends State<SettingData> {
  late ResultRevision resultRevision;

  bool _isLoading = false;
  String _message = "";

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final info = Provider.of<ProviderPages>(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
        drawer: setDrawer(context),
        appBar: setAppBarMain(
          context,
          "Ribe",
          "Enviar Datos",
        ),
        body: Container(
            padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 40.0),
            child: Theme(
                data: ThemeData(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: AppColor.themeColor,
                        secondary: AppColor.secondaryColor,
                      ),
                ),
                child: Stack(

                  children: [
                    Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          height: 100,
                        ),
                      
                        SizedBox(
                          height: 50,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(width - 20, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10.0), // Radio de 10.0
                            ),
                            backgroundColor: AppColor.redColor,
                            padding: EdgeInsets.all(10.0),
                          ),
                          onPressed: () async {
                            final result = await showConfirm(context);

                            if(!result){
                              return;
                            }
                           
                            if (result){
                              _message = "Borrando Data ...";
                              _isLoading = true;
                              setState(() {});
                              
                              await info.clearData();
                             }


                            _isLoading = false;
                            setState(() {});
                            showMsg("Datos Borrados Exitosamente");

                          },
                          child: Text(
                            'Borrar Datos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                    _isLoading ? Center(
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(20), // Radio de redondeo
                          ),
                          child: SizedBox(
                            height: 150,
                            width: 250,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      circularProgress(Colors.white),
                            SizedBox(
                               height: 10,
                            ),
                            setCommonText(_message, Colors.white, 16.0, FontWeight.w500, 20),
                                                    ],
                                                  ),
                          )),
                    ): SizedBox.shrink(),
               ]
                )

    )
    )
    );
  }
}
