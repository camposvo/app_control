import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';
import 'api/client.dart';
import 'src/app.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:control/providers/providers_pages.dart';

void main() async {

  await dotenv.load(fileName: ".env");
  await initHiveForFlutter();
  final token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOnsidXN1YV9pZCI6IkFuZHJvaWQifX0.';
  await api.saveToken(token);

  final box = await Hive.openBox('boxname');
  //await box.clear();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProviderPages()),
      ],
      child: MyApp(),
    ),
  );


}