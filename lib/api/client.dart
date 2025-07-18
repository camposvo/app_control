import 'dart:async';
import 'dart:convert';

import 'package:control/models/orgaInstrumento.dart';
import 'package:control/models/resultRevision.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../gql/control_gql.dart';
import '../helper/util.dart';
import 'graphqlConfig.dart';
import 'package:http/http.dart' as http;





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
      );

      if (result.hasException) {
        print(result.exception.toString());
        return null;
      }

      if (result.data != null) {
        String str =
        getPrettyJSONString(result.data?['organizaciones']['data']);

        return str;
      }

      //developer.log(result.data.toString());

      return null ;

    } catch (e) {
      print(e);
      return null ;
    }
  }

  Future<String?> getOrganizationFromJson() async {

    final String respuesta = await rootBundle.loadString('assets/json/organization.json');
    return respuesta;
  }

  Future<String?> getOrganInstruments(String orgaId) async {

    Util.printInfo("ID Orga", orgaId);

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
      );

      if (result.hasException) {
        print(result.exception.toString());
        return null;
      }

      if (result.data != null) {
        String str =
        getPrettyJSONString(result.data?['loadDataRevisiones']['data']);
        //Util.printInfo("data", str);
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

  Future<String?> getOrganInstrumentsFromJson() async {

    final String respuesta = await rootBundle.loadString('assets/json/orgaInstrumento.json');
    return respuesta;
  }

  Future<String?> insertFinalizados(String orgaId, List<InstFinalizado> data) async {

    final finished = finalizadosToJson(data);

    Util.printInfo("Finalizados", finished.toString());

   try {
      GraphQLConfig graphQLConfiguration = GraphQLConfig();
      GraphQLClient client = graphQLConfiguration.clientToQuery();
      QueryResult result = await client.mutate(
        MutationOptions(
            document: gql(gqlControl.gqlSaveComment()),
            variables: {'orgaId': orgaId,
              'finalizados': finished
                  },
            fetchPolicy: FetchPolicy.networkOnly),
      );

      if (result.hasException) {
        print(result.exception.toString());
        Util.printInfo("Finalizados", " ${result.exception.toString()}");
        return null;
      }
      if (result.data != null) {
        return 'Operacion Completada Exitosamente';
      }

      return null;
    } catch (e) {
      return null;
    }

    return null;

  }

  Future<String?> insertPruebas(String orgaId, Prueba data) async {

    final test = data.toJson();

    Util.printInfo("Peticion", test.toString());

   try {
      GraphQLConfig graphQLConfiguration = GraphQLConfig();
      GraphQLClient client = graphQLConfiguration.clientToQuery();
      QueryResult result = await client.mutate(
        MutationOptions(
            document: gql(gqlControl.gqlSaveTest()),
            variables: {'orgaId': orgaId,
              'prueba': test
            },
            fetchPolicy: FetchPolicy.networkOnly),
      );

      if (result.hasException) {
        Util.printInfo("prueba ERRORR QUERY : ",result.exception.toString());
        return null;
      }
      if (result.data != null) {
        Util.printInfo("prueba : ","Guardo");
        print(result.data);

        return 'Operacion Completada Exitosamente';
      }
      return null;

    } catch (e) {
      Util.printInfo("EXCEPTIO ERRORR QUERY : ",e.toString());
      print(e);
      return null;
    }

    return null;

  }

  Future<String?> insertComments(String orgaId, List<PuntComment> data) async {

    final test = CommentToJson(data);

    //Util.printInfo("Comentarios", test.toString());

    try {
      GraphQLConfig graphQLConfiguration = GraphQLConfig();
      GraphQLClient client = graphQLConfiguration.clientToQuery();
      QueryResult result = await client.mutate(
        MutationOptions(
            document: gql(gqlControl.gqlSaveTestComment()),
            variables: {'orgaId': orgaId,
              'comentarios': test
            },
            fetchPolicy: FetchPolicy.networkOnly),
      );

      if (result.hasException) {
        Util.printInfo("prueba ERRORR QUERY : ",result.exception.toString());
        return null;
      }
      if (result.data != null) {
        Util.printInfo("comentario : ","Guardo");
        Util.printInfo("Resultado: ", result.data.toString());


        return 'Operacion Completada Exitosamente';
      }
      return null;

    } catch (e) {
      Util.printInfo("EXCEPTIO ERRORR QUERY : ",e.toString());
      print(e);
      return null;
    }

    return null;

  }

  Future<String?> updateIntrument(String instId, String orgaId, double value) async {

    dynamic filter = {
      "condiciones": {
        "field": "inst_id",
        "operador": "EQUAL",
        "value": instId
      }
    };

    dynamic fields = {
      "inst_proteccion": value
    };

    Util.printInfo("test", filter.toString());
    Util.printInfo("test", fields.toString());


    try {
      GraphQLConfig graphQLConfiguration = GraphQLConfig();
      GraphQLClient client = graphQLConfiguration.clientToQuery();
      QueryResult result = await client.mutate(
        MutationOptions(
            document: gql(gqlControl.gqlUpdateInstrument()),
            variables: {'orgaId': orgaId,
              'filter': filter,
              'fields': fields
            },
            fetchPolicy: FetchPolicy.networkOnly),
      );

      if (result.hasException) {
        Util.printInfo("prueba : ",result.exception.toString());
        return null;
      }
      if (result.data != null) {
        Util.printInfo("prueba : ","Guardo");
        print(result.data);

        return 'Operacion Completada Exitosamente';
      }
      return null;

    } catch (e) {

      print(e);
      return null;
    }

  }

  Future<String?> fetchImage(String urlImage) async {
    final url = Uri.parse(urlImage);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = "*35^Gt1wwjgh3j47sn3j341@asd";

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Incluye el token en el encabezado
        },
      );

      if (response.statusCode == 200) {
         return response.body;
      } else {
        print('Error en la petición: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return null;
      }
    } catch (e) {
      // Ocurrió un error al realizar la petición
      print('Error: $e');
      return null;
    }
  }

}

final api = _Clients();
