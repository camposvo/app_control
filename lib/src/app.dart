import 'package:control/pages/dashboard/dashboard.dart';
import 'package:control/pages/mainMenu.dart';
import 'package:control/pages/showOrganization.dart';
import 'package:control/pages/welcome.dart';
import 'package:flutter/material.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:control/routes/routes.dart';
import 'package:control/api/graphqlConfig.dart';
import 'package:control/helper/shared_manager.dart';

import 'package:control/pages/login.dart';



class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {


    ValueNotifier<GraphQLClient> client = GraphQLConfig.graphInit();

    return GraphQLProvider(
      client: client,
      child: new MaterialApp(
        home: new DashboardPage(),
        debugShowCheckedModeBanner: false,
        supportedLocales: [SharedManager.shared.language],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routes: getApplicationRoutes(),

      ),
    );
  }
}


