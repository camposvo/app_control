import 'package:control/models/organizacion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:control/helper/constant.dart';
import 'package:control/providers/providers_pages.dart';

import '../api/client.dart';
import '../helper/common_widgets.dart';
import '../helper/mqttManager.dart';
import '../helper/util.dart';
import '../models/orgaInstrumento.dart';
import 'package:flutter/services.dart';


enum WidgetState { SHOW_MENU,  LOAD }

class MenuSystem extends StatefulWidget {
  const MenuSystem({super.key});

  @override
  State<MenuSystem> createState() => _MenuSystemState();
}

class _MenuSystemState extends State<MenuSystem> {

  WidgetState _widgetState = WidgetState.LOAD;
 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _widgetState = WidgetState.LOAD;
    setState(() {});
    _widgetState = WidgetState.SHOW_MENU;
    setState(() {});

  }


  @override
  Widget build(BuildContext context) {
    switch (_widgetState) {
      case WidgetState.LOAD:
        return _buildScaffold(context,Center(
          child: circularProgressMain(),
        ) ) ;

      case WidgetState.SHOW_MENU:
        return  _buildScaffold(context,_showMenu(context) ) ;

    }
  }

  Widget _buildScaffold(BuildContext context, Widget body) {

    final info = Provider.of<ProviderPages>(context, listen: false);
    final name = info.isOrganization ? info.organization!.orgaNombre : '';

    return Scaffold(
        drawer: setDrawer(context),
        appBar: setAppBarMain(context, name, "Seleccionar Modo"),
        body: body
    );
  }


  Widget _showMenu(BuildContext context) {
    final info = Provider.of<ProviderPages>(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final code = info.mainTopic;

    return Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 50,),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(width -20, 40),
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                  ),
                  backgroundColor: AppColor.themeColor,
                  padding: EdgeInsets.all(10.0),
                ),
                onPressed: ()  {

                  info.moduleSelected = ModuleSelect.NO_SYSTEM;
                  Navigator.pushNamed(context, 'showRevision')
                      .then((_)  {
                    setState(() {});
                  });
                  setState(() {});

                },
                child: Text('Sin Sistema',  style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),),
              ),

              SizedBox(height: 20,),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(width -20, 40),
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                  ),
                  backgroundColor: AppColor.redColor,
                  padding: EdgeInsets.all(10.0),
                ),
                onPressed: null,
                child: Text('Con Sistema',  style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),),
              ),

              SizedBox(height: 20,),

            ],
          ),
        )
    );
  }


}
