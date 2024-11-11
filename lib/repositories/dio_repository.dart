import 'dart:developer';

import 'package:app_cep/models/back4app_model.dart';
import 'package:dio/dio.dart';

class DioRepository {
  final _dio = Dio(BaseOptions(
    baseUrl: "https://parseapi.back4app.com/classes",
    headers: {
      "X-Parse-Application-Id": "Uz8yZIbECPWrlV7V3VSmvF1ZvzgAtbZERTxU2wEL",
      "X-Parse-REST-API-Key": "mJ2gNXw6uTmAeT3TWxVPhi5hCYtSHzjRjwdBJM06",
      "Content-Type": "application/json",
    },
  ));

  Future? getViaCEP(String cep) async {
    String baseURL = "https://viacep.com.br/ws/$cep/json/";

    try {
      var response = await _dio.get(baseURL);
      return response.data;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future? salvarCepBack4App(Back4appModel cep) async {
    String uri = "/viacep";

    try {
      await _dio.post(uri, data: cep.toJson());
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  Future<List> getCepBack4App({String? cep}) async {
    String paramns = (cep != null) ? '?where={"cep": "$cep"}' : "";
    String uri = '/viacep$paramns';

    try {
      var result = await _dio.get(uri);
      return result.data["results"];
    } catch (e) {
      log([cep, e].toString());
      return [];
    }
  }

  Future<void> removeCepBack4App(String id) async {
    String uri = "/viacep/$id";
    try {
      await _dio.delete(uri);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> editCepBack4App(String id, data) async {
    String uri = "/viacep/$id";
    try {
      await _dio.put(uri, data: data);
    } catch (e) {
      log(e.toString());
    }
  }
}
