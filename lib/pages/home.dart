import 'dart:convert';
import 'dart:developer';

import 'package:app_cep/models/back4app_model.dart';
import 'package:app_cep/models/via_cep_model.dart';
import 'package:app_cep/pages/cep_details.dart';
import 'package:app_cep/repositories/dio_repository.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DioRepository repository = DioRepository();
  ViaCepModel? viaCepModel;
  List<Back4appModel> back4appModels = [];
  bool carregando = false;

  var textController = TextEditingController();

  @override
  void initState() {
    getCepsBack4App();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("VicaCepApp"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                maxLength: 8,
                decoration: decoration,
                controller: textController,
                onChanged: (v) => getCEP(v),
              ),
              carregando
                  ? const Center(child: CircularProgressIndicator())
                  : ((viaCepModel == null)
                      ? Container()
                      : Card(
                          child: ListTile(
                            title: Text(
                                "${viaCepModel!.cep} - ${viaCepModel!.localidade}, ${viaCepModel!.uf}"),
                            subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${viaCepModel?.logradouro ?? ""}, ${viaCepModel!.bairro}"),
                                ]),
                            trailing: IconButton(
                                onPressed: salvarCep,
                                icon: const Icon(Icons.add)),
                          ),
                        )),
              const Divider(),
              Expanded(
                  child: ListView.builder(
                itemCount: back4appModels.length,
                itemBuilder: (BuildContext context, int index) {
                  Back4appModel model = back4appModels[index];
                  return (back4appModels.isEmpty)
                      ? const Text("Nenhum cep Cadastrado")
                      : Card(
                          child: ListTile(
                            subtitle: Text(
                                "${model.cep} - ${model.localidade}, ${model.uf}"),
                            title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${model.logradouro ?? ""}, ${model.bairro}"),
                                ]),
                            trailing: IconButton(
                                onPressed: () => excluir(model.id!),
                                icon: const Icon(Icons.delete)),
                            onTap: () async {
                              await Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return CepDetails(cep: model);
                              }));
                              getCepsBack4App();
                            },
                          ),
                        );
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  var decoration = const InputDecoration(
      label: Text("Buscar CEP"), suffix: Icon(Icons.search));

  getCEP(String cep) async {
    cep = cep.trim();
    if (cep.length >= 8) {
      viaCepModel = null;
      setState(() {
        carregando = true;
      });

      String tmp = ((int.tryParse(cep) != null) ? cep : "");

      if (tmp == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Digite apenas números")));
      }

      cep = tmp;
      var result = await repository.getViaCEP(cep);
      setState(() {
        carregando = false;
      });

      if (result != null) {
        if (result["erro"] == "true") return null;
        viaCepModel = ViaCepModel.fromJson(result);
      }
    } else {
      viaCepModel = null;
    }
    setState(() {});
  }

  salvarCep() async {
    var cep = Back4appModel.fromJson(viaCepModel!.toJsonBack4());
    var r = await repository.getCepBack4App(cep: cep.cep!);

    if (r.isEmpty) {
      await repository.salvarCepBack4App(cep);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Salvo Com Sucesso!"),
        ));
        getCepsBack4App();
        viaCepModel = null;
        textController.clear();
        return;
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.amber[900],
        content: const Text("Cep Já Cadastrado"),
      ));
      viaCepModel = null;
      textController.clear();
      setState(() {});
      return;
    }
  }

  Future getCepsBack4App() async {
    back4appModels.clear();
    var r = await repository.getCepBack4App();

    for (var model in r) {
      var m = Back4appModel.fromJson(model);
      back4appModels.add(m);
    }
    setState(() {});
  }

  excluir(String id) async {
    await repository.removeCepBack4App(id);
    showSnackMsg("CEP Excluido!", Colors.red[900]);
    getCepsBack4App();
  }

  showSnackMsg(String msg, Color? color) {
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(backgroundColor: color, content: Text(msg)));
  }
}
