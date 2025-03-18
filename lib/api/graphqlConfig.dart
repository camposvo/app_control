import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQLConfig {
  static String? token = "";

  static HttpLink httpLink = HttpLink(
    'https://portal5.ribe.cl:4099/graphql',
  );

  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt");
  }

  static AuthLink _createAuthLink() {
    return AuthLink(
      getToken: () async {
        token = await _getToken();
        return '$token';
      },
    );
  }


  static Link _createLink() {
    final AuthLink authLink = _createAuthLink();

    // Request Interceptor to log request details
    final Link logLink = Link.function((operation, [forward]) {
      // Log the headers and body before sending the request
      print('Request: ${operation.operation}');

      final httpLinkHeaders = operation.context.entry<HttpLinkHeaders>();
      if (httpLinkHeaders != null) {
        print('HttpLinkHeaders: ${httpLinkHeaders.headers}');
      } else {
        print('HttpLinkHeaders no encontrado en el contexto.');
      }
        return forward!(operation);

    });

    return authLink.concat(httpLink);

    //return authLink.concat(logLink).concat(httpLink);
  }


  static ValueNotifier<GraphQLClient> graphInit() {
    final Link link = _createLink();

    return ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(
          store: HiveStore(),
        ),
      ),
    );
  }

  GraphQLClient clientToQuery() {
    final Link link = _createLink();

    return GraphQLClient(
      queryRequestTimeout: const Duration(seconds: 600),
      cache: GraphQLCache(
        store: HiveStore(),
      ),
      link: link,
    );
  }
}
