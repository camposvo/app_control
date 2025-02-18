import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

import '../helper/common_widgets.dart';
import '../helper/constant.dart';
import '../models/orgaInstrumento.dart';
import '../models/variable.dart';
import '../providers/providers_pages.dart';

class Organization extends StatefulWidget {
  @override
  _OrganizationState createState() => _OrganizationState();
}

class _OrganizationState extends State<Organization> {
  List<OrgaInstrumento> _organizations = [];
  List<OrgaInstrumento> _filterList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
     _loadJsonData(context);
  }

  Future<void> _loadJsonData(BuildContext context) async {
    final info = Provider.of<ProviderPages>(context, listen: false);

    isLoading = true;
    String jsonString  = await rootBundle.loadString('assets/json/data.json');
    setState(() {
      _organizations = orgaInstrumentoFromJson(jsonString);
      _filterList = orgaInstrumentoFromJson(jsonString);
      info.organizations = orgaInstrumentoFromJson(jsonString);
      
      isLoading = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.containerBody,
      appBar: setAppBarTwo(context, "Edificios"),
      body: contentBody(context)
    );
  }


  onSearch(String search) {
    _filterList = _organizations.where((item) {
      return item.orgaNombre.toLowerCase().contains(search);
    }).toList();

    setState(() {});
  }

  _search() {
    return Container(
      height: 48,
      child: TextField(
        onChanged: (value) => onSearch(value),
        decoration: setSearchDecoration(),
      ),
    );
  }

  Widget contentBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          _search(),
          SizedBox(
            height: 7,
          ),
          Expanded(
            child: (isLoading)
                ? Center(child: CircularProgressIndicator())
                : _createListView(context),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _createListView(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        child: _filterList.length > 0
            ? ListView.builder(
          itemCount: _filterList.length,
          itemBuilder: (context, index) {
            return InkWell(
                child: _itemListView(index, context), onTap: () {
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
    final instrument = _filterList[index].orgaInstrumentos;

    final size = MediaQuery.of(context).size;
    final width = size.width;

    return new Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Material(
        color: Colors.white,
        elevation: 2.0,
        borderRadius: BorderRadius.circular(10),
        child: new Padding(
          padding: new EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    setCommonText2(nombre.toUpperCase(), Colors.black, 16.0, FontWeight.w800, 20),
                    setCommonText(instrument.length.toString(), AppColor.themeColor, 16.0, FontWeight.w800, 20),


                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Radio de 10.0
                  ),
                  backgroundColor: AppColor.secondaryColor,
                  padding: EdgeInsets.all(10.0),
                ),
                onPressed: () async {
                  setState(() {
                    info.orgaId = _filterList[index].orgaId;
                  });

                  Navigator.pushNamed(context, 'selectMode',
                      arguments: {'id': _filterList[index].orgaId})
                      .then((_) async {
                  });


                },
                child: Text('Ir',  style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
} // FIn MAIN WIDGET
