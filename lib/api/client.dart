import 'dart:async';
import 'dart:convert';



import 'dart:developer' as developer;

import 'package:control/models/orgaInstrumento.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../gql/control_gql.dart';
import 'graphqlConfig.dart';





class _Clients {

  String getPrettyJSONString(Object jsonObject) {
    dynamic result = JsonEncoder.withIndent('  ').convert(jsonObject);
    if (result == 'null') return  '';
    return result;
  }

  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', token);
  }

  Future<String?> getOrganization() async {

    dynamic filter = {
            "condiciones": {
                "field": "orga_activo",
                "operador": "EQUAL",
                "value": "1"
            }
        };


    try {
      GraphQLConfig graphQLConfiguration = GraphQLConfig();
      GraphQLClient _client = graphQLConfiguration.clientToQuery();
      QueryResult result = await _client.query(
        QueryOptions(
            document: gql(gqlControl.gqlOrganizations()),
            fetchPolicy: FetchPolicy.networkOnly,
            variables: {
              'filter': filter,
            },
        ),
      ).timeout(const Duration(minutes: 2));

      if (result.hasException) {
        print(result.exception.toString());
        return null;
      }

      if (result.data != null) {
        print(result.data );
        String str =
        getPrettyJSONString(result.data?['organizaciones']['data']);

        return str;
      }

      //developer.log(result.data.toString());

      return null ;

    } on TimeoutException catch (_) {
      // Manejar la excepción de tiempo de espera
      print("La solicitud ha expirado. Por favor, inténtalo de nuevo.");
      return null ;

    } catch (e) {
      print(e);
      return null ;
    }
  }

  Future<String?> getOrganInstruments(String orgaId) async {

    try {
      GraphQLConfig graphQLConfiguration = GraphQLConfig();
      GraphQLClient _client = graphQLConfiguration.clientToQuery();
      QueryResult result = await _client.query(
        QueryOptions(
          document: gql(gqlControl.gqlOrgaInstrument()),
          fetchPolicy: FetchPolicy.networkOnly,
          variables: {
            "orgaId": orgaId
          }
        ),
      ).timeout(const Duration(minutes: 2));

      if (result.hasException) {
        print(result.exception.toString());
        return null;
      }

      if (result.data != null) {
        String str =
        getPrettyJSONString(result.data?['loadDataRevisiones']['data']);
        return str;
      }

      //developer.log(result.data.toString());

      return null ;

    } on TimeoutException catch (_) {
      // Manejar la excepción de tiempo de espera
      print("La solicitud ha expirado. Por favor, inténtalo de nuevo.");
      return null ;

    } catch (e) {
      print(e);
      return null ;
    }
  }




}

final api = _Clients();
