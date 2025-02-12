import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'src/app.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:control/providers/providers_pages.dart';

void main() async {

  await dotenv.load(fileName: ".env");
  await initHiveForFlutter();
  //await Hive.openBox("boxname");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProviderPages()),
      ],
      child: MyApp(),
    ),
  );


}