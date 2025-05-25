import 'dart:async';

import 'package:control/helper/util.dart';
import 'package:control/models/organizacion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

import '../api/client.dart';
import '../helper/common_widgets.dart';
import '../helper/constant.dart';
import '../models/orgaInstrumento.dart';
import '../models/variable.dart';
import '../providers/providers_pages.dart';

enum WidgetState { LOADING, LOADED, ERROR_GRAPHQL }

class ShowOrganization extends StatefulWidget {
  @override
  _ShowOrganizationState createState() => _ShowOrganizationState();
}

class _ShowOrganizationState extends State<ShowOrganization> {
  List<Organization> _organizations = [];
  List<Organization> _filterList = [];

  WidgetState _widgetState = WidgetState.LOADING;

  @override
  void initState() {
    super.initState();
     _loadJsonData(context);
  }

  Future<void> _loadJsonData(BuildContext context) async {    
    final result = await _getOrganizations(context);
   
    if (!result){
      _widgetState = WidgetState.ERROR_GRAPHQL;
      setState(() {});
      return;
    }

    _widgetState = WidgetState.LOADED;
    setState(() {});
    return;
  }

  Future<bool> _getOrganizations(BuildContext context) async {
    final result =await api.getOrganization();

    //final result =await api.getOrganizationFromJson();

    if(result == null){
        return false;
    }
    _organizations = organizationFromJson(result);
    _filterList =organizationFromJson(result);
    return true;
  }


  @override
  Widget build(BuildContext context) {

    switch (_widgetState) {     

      case WidgetState.LOADING:
        return _buildScaffold(context,Center(
          child: circularProgressMain(),
        ) ) ;

      case WidgetState.LOADED:
        return _buildScaffold(context, _showList(context)) ;

      case WidgetState.ERROR_GRAPHQL:
        return _buildScaffold(context,Center(
          child: Text("Error con el Servidor Graphql"),
        ) ) ;

    }
    
  }


  Widget _buildScaffold(BuildContext context, Widget body) {
    return Scaffold(
        backgroundColor: AppColor.containerBody,
        drawer: setDrawer(context),
        appBar: setAppBarMain(context, "Organizaciones","Listado"),
        body: body
    );
  }

  _onSearch(String search) {
    _filterList = _organizations.where((item) {
      return item.orgaNombre.toLowerCase().contains(search);
    }).toList();

    setState(() {});
  }

  _search() {
    return Container(
      height: 48,
      child: TextField(
        onChanged: (value) => _onSearch(value),
        decoration: setSearchDecoration(),
      ),
    );
  }

  Widget _showList(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          _search(),
          SizedBox(
            height: 7,
          ),
          Expanded(
            child:_createListView(context),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _createListView(BuildContext context) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    return Container(
        height: MediaQuery.of(context).size.height,
        child: _filterList.length > 0
            ? ListView.builder(
          itemCount: _filterList.length,
          itemBuilder: (context, index) {
            return InkWell(
                child: _itemListView(index, context), onTap: () {
              info.organization = _filterList[index];
              setState(() {});

              Navigator.pushNamed(context, 'menuSystem',
                  arguments: {'id': _filterList[index].orgaId})
                  .then((_)  {
              });

            });
          },
        )
            : Center(
          child: Text(
            "No Encontrado",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ));
  }

  Widget _itemListView(int index, BuildContext context) {
    final info = Provider.of<ProviderPages>(context, listen: false);
    final nombre = _filterList[index].orgaNombre;

    final widthItem = MediaQuery.of(context).size.width - 80;


    return new Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Material(
        color: Colors.grey,
        elevation: 2.0,
        borderRadius: BorderRadius.circular(10),
        child: new Padding(
          padding: new EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: widthItem,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    setCommonText2(nombre.toUpperCase(), Colors.white, 16.0, FontWeight.w800, 20),

                  ],
                ),
              ),
             /* ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                  ),
                  backgroundColor: AppColor.secondaryColor,
                  padding: EdgeInsets.all(10.0),
                ),
                onPressed: () {
                  info.organization = _filterList[index];
                  setState(() {});

                  Navigator.pushNamed(context, 'showRevision',
                      arguments: {'id': _filterList[index].orgaId})
                      .then((_)  {
                  });

                },
                child: Text('Ir',  style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
} // FIn MAIN WIDGET
