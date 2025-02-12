import 'package:graphql_flutter/graphql_flutter.dart';
import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';

class GraphQLConfig {
  static String? token = "";

  static HttpLink httpLink = HttpLink(
    'http://192.168.0.107:4020/graphql',
    //'https://inventario.ribe.cl:4020/graphql',
  );

  static WebSocketLink webSocketLink = new WebSocketLink(
    'ws://inventario.ribe.cl:4020/graphql',
    config: SocketClientConfig(
      autoReconnect: true,
      inactivityTimeout: Duration(seconds: 30),
    ),
  );

  ///if you want to pass token
  static ValueNotifier<GraphQLClient> graphInit() {
    // We're using HiveStore for persistence,
    // so we need to initialize Hive.
    final AuthLink authLink = AuthLink(
        //getToken: () async => 'Bearer $token',
        getToken: () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? tokenToUse = prefs.getString("jwt");
      token = tokenToUse?.toUpperCase() ?? "Token no encontrado";

      return 'Bearer $token';
    });

    final Link link = authLink.concat(httpLink).concat(webSocketLink);

    final link2 =
        Link.split((request) => request.isSubscription, webSocketLink, link);

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link2,
        cache: GraphQLCache(
          store: HiveStore(),
        ),
        // The default store is the InMemoryStore, which does NOT persist to disk
      ),
    );

    return client;
  }

  GraphQLClient clientToQuery() {

    AuthLink authLink = AuthLink(
        getToken: () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? tokenToUse = prefs.getString("jwt");
      token = tokenToUse?.toUpperCase() ?? "Token no encontrado";
      return 'Bearer $token';
    });

    final Link link = authLink.concat(httpLink); //.concat(webSocketLink);
    final link2 =
        //Link.split((request) => request.isSubscription, webSocketLink, link);
    Link.split((request) => request.isSubscription, webSocketLink, link);
    return GraphQLClient(
      cache: GraphQLCache(
        store: HiveStore(),
      ),
      link: link,
    );
  }
}
