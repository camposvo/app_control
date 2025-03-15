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

  Future<bool> _refresh() async {
    _isLoading = true;
    setState(() {});
    final info = Provider.of<ProviderPages>(context, listen: false);

    final id = info.organization.orgaId;
    final result =await api.getOrganInstruments(id);
    if(result == null){
      showError("Error Recuperando la Data");
      _isLoading = false;
      setState(() {});
      return false;
    }

    final _orgaInstruments = orgaInstrumentoFromJson(result);
    final temp = _orgaInstruments.firstWhere((item) => item.orgaId == id);

    info.mainData.removeWhere((element) => element.orgaId == id);
    info.mainData.add(temp);

    showMsg("Data ha sido Actualizada");
    _isLoading = false;
    setState(() {});
   
    return true;
  }

  bool checkOrganization(BuildContext context) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    return info.isOrganization;
  }

  bool checkConnection(BuildContext context) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    return info.connected;
  }

  Widget build(BuildContext context) {
    final info = Provider.of<ProviderPages>(context, listen: false);

    final name = info.isOrganization ? info.organization.orgaNombre : '';
    final revision = info.revision != null ? info.revision!.reviNumero : '';

    return Scaffold(
      backgroundColor: AppColor.containerBody,
      appBar: setAppBarMain(context, "Titulo Dashboard", "Otro"),
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
            spaceForm(),
            _gridAdmin(context),
            //_setGridViewListing(context)
          ],
        ),
          _isLoading ? Center(
            child: CircularProgressIndicator(),
          ): SizedBox.shrink(),
      ]
      ),
    );
  }

  _gridAdmin(BuildContext context) {
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
                    Navigator.pushNamed(context, 'organizations');
                    break;
                  case 1:
                    if (!checkOrganization(context)) break;
                    Navigator.pushNamed(context, 'selectMode');
                    break;
                  case 2:
                    if (!checkOrganization(context)) break;
                    if (!checkConnection(context)) break;
                    Navigator.pushNamed(context, 'instrument');
                    break;
                  case 3:
                    if (!checkOrganization(context)) break;
                    await _refresh();
                    break;
                  case 4:
                    if (!checkOrganization(context)) break;
                    Navigator.pushNamed(context, 'sendData');
                    break;

                  default:
                }
              },
              child: new Container(
                  padding: new EdgeInsets.all(5),
                  child: new Material(
                    color: AppColor.secondaryColor,
                    elevation: 2.0,
                    borderRadius:
                        BorderRadius.circular(AppConst.borderRadiusDash),
                    child: new Container(
                      padding: new EdgeInsets.all(12),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          AppDashb.listAdmin[index]['icon'],
                          new Column(
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
