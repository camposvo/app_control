import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:control/helper/constant.dart';
import 'package:control/helper/common_widgets.dart';
import 'package:control/providers/providers_pages.dart';

import '../../api/client.dart';
import '../../helper/util.dart';
import '../../models/orgaInstrumento.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
    });

  }



  bool existOrganization(BuildContext context) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    return info.isOrganization;
  }

  bool isConnected(BuildContext context) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    return info.connected;
  }

  bool dataPending(BuildContext context) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    return info.pendingData;
  }

  Color getColor(int index, BuildContext context) {

    if( index == 0 ) return AppColor.secondaryColor; // Organizacion

    if( index == 1){ // Conectar Dispositivo
      if( isConnected(context)) return AppColor.GreenReady;
      return AppColor.secondaryColor;
    }

    if( index == 2 && existOrganization(context) && isConnected(context))  //Cargar datos Sin sistema
        return AppColor.secondaryColor;


    if( index == 3){ // Enviar Datos
      if(dataPending(context)){
        return AppColor.GreenReady;
      }

    }

    if( index == 4){ // Conectar Dispositivo
      return AppColor.secondaryColor;
    }


    return Colors.grey;


    }

  Widget build(BuildContext context) {
    final info = Provider.of<ProviderPages>(context, listen: false);

    final name = info.isOrganization ? info.organization!.orgaNombre : '';
    final revision = info.revision != null ? info.revision!.reviNumero : '';

    return Scaffold(
      backgroundColor: AppColor.containerBody,
      appBar: setAppBarMain(context, "Dashboard", "Ribe"),
      drawer: setDrawer(context),
      body: Stack(
        children:[ ListView(
          padding: paddingMain(),
          children: <Widget>[
            Row(
              children: <Widget>[
                setCommonText(
                    "Edificio: ", Colors.black, 18.0, FontWeight.w500, 1),
                setCommonText(name, Colors.black, 18.0, FontWeight.w800, 1),
              ],
            ),
            Row(
              children: <Widget>[
                setCommonText(
                    "Revision: ", Colors.black, 18.0, FontWeight.w500, 1),
                setCommonText(revision, Colors.black, 18.0, FontWeight.w800, 1),
              ],
            ),
            Row(
              children: <Widget>[
                setCommonText(
                    "Sesión: ", Colors.black, 18.0, FontWeight.w500, 1),
                setCommonText(info.mainTopic, Colors.black, 18.0, FontWeight.w800, 1),
              ],
            ),
            spaceForm(),
            _gridAdmin(context),
            //_setGridViewListing(context)
          ],
        ),
          _isLoading ? Center(
            child: circularProgressMain(),
          ): SizedBox.shrink(),
      ]
      ),
    );
  }

  Widget _gridAdmin(BuildContext context) {
    return new Container(
      height: MediaQuery.of(context).size.height,
      child: new GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: (3 / 2.5),
        children: new List<Widget>.generate(AppDashb.listAdmin.length, (index) {
          return new GridTile(
            child: new InkWell(
              onTap: () async {
                for (var i = 0; i < AppDashb.listAdmin.length; i++) {
                  AppDashb.listAdmin[i]['isSelect'] = false;
                }
                AppDashb.listAdmin[index]['isSelect'] = true;
                switch (index) {
                  case 0:
                    Navigator.pushNamed(context, 'organizations')
                        .then((_)  {
                          setState(() {});
                    });
                    break;
                  case 1:
                    Navigator.pushNamed(context, 'selectMode')
                        .then((_)  {
                      setState(() {});
                    });

                    break;
                  case 2:
                    if (!existOrganization(context)) break;
                    if (!isConnected(context)) break;

                    Navigator.pushNamed(context, 'instrument')
                        .then((_)  {
                      setState(() {});
                    });

                    break;
                  case 3:
                    if (!dataPending(context)) break;

                    Navigator.pushNamed(context, 'sendData')
                        .then((_)  {
                      setState(() {});
                    });

                    break;

                  case 4:
                    Navigator.pushNamed(context, 'settingData')
                        .then((_)  {
                      setState(() {});
                    });

                    break;

                  default:
                }
              },
              child: Container(
                  padding: EdgeInsets.all(5),
                  child:  Material(
                    color: getColor(index, context),
                    elevation: 2.0,
                    borderRadius:
                        BorderRadius.circular(AppConst.borderRadiusDash),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          AppDashb.listAdmin[index]['icon'],
                           Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              setCommonText(AppDashb.listAdmin[index]['title'],
                                  Colors.white, 16.0, FontWeight.w700, 2),
                              SizedBox(
                                height: 3,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )),
            ),
          );
        }),
      ),
    );
  }

}
