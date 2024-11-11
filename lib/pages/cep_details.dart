import 'dart:developer';

import 'package:app_cep/models/back4app_model.dart';
import 'package:app_cep/models/via_cep_model.dart';
import 'package:app_cep/repositories/dio_repository.dart';
import 'package:flutter/material.dart';

class CepDetails extends StatefulWidget {
  final Back4appModel cep;
  CepDetails({required this.cep, super.key});

  @override
  State<CepDetails> createState() => _CepDetailsState();
}

class _CepDetailsState extends State<CepDetails> {
  var repository = DioRepository();
  late Back4appModel cepModel = widget.cep;
  ViaCepModel? viaCepModel;

  bool editing = false;
  bool carregando = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("CEP Detalhes"),
        ),
        body: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Cep: ${cepModel.cep!}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Estado: ${cepModel.estado} - ${cepModel.uf}"),
                    Text("Cidade: ${cepModel.localidade}"),
                    Text(
                        "Logradouro: ${cepModel.logradouro!} ${cepModel.complemento}"),
                    Text("Bairro: ${cepModel.bairro!}"),
                    Text("DDD: ${cepModel.ddd}"),
                    Text("Criado: ${cepModel.created}"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () => setState(() {
                                  editing = !editing;
                                }),
                            child: const Text("Editar")),
                        TextButton(
                            onPressed: () => excluir(context, cepModel.id!),
                            child: const Text("Excluir"))
                      ],
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: (editing)
                  ? TextField(
                      onChanged: getCEP,
                      maxLength: 8,
                      decoration: const InputDecoration(
                        label: Text("CEP"),
                      ),
                    )
                  : Container(),
            ),
            ((viaCepModel == null)
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
                          onPressed: () => editar(context, widget.cep.cep!),
                          icon: const Icon(Icons.edit)),
                    ),
                  ))
          ],
        ),
      ),
    );
  }

  excluir(BuildContext context, String id) async {
    await repository.removeCepBack4App(id);
    showSnackMsg("CEP Excluido!", Colors.red[900]);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  editar(BuildContext context, String id) async {
    try {
      var result = await repository.getCepBack4App(cep: cepModel.cep);

      if (result.isEmpty) {
        await repository.editCepBack4App(widget.cep.id!, cepModel.toJsonSave());
        if (context.mounted) {
          showSnackMsg("CEP Alterado com sucesso!", Colors.green[900]);

          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          showSnackMsg("CEP Alterado com sucesso!", Colors.amber[900]);
        }
      }
    } catch (e) {
      log(e.toString());
    }
    log(id);
  }

  getCEP(String cep) async {
    cep = cep.trim();
    if (cep.length >= 8) {
      viaCepModel = null;
      setState(() {
        carregando = true;
      });

      String tmp = ((int.tryParse(cep) != null) ? cep : "");

      if (tmp == "") {
        showSnackMsg("Digite apenas números", Colors.amber[900]);
        return;
      }

      cep = tmp;
      var result = await repository.getViaCEP(cep);
      setState(() {
        carregando = false;
      });

      if (result != null) {
        if (result["erro"] == "true") return null;
        viaCepModel = ViaCepModel.fromJson(result);
        cepModel = Back4appModel.fromJson(viaCepModel!.toJsonBack4());
        setState(() {});
      }
    } else {
      viaCepModel = null;
      cepModel = widget.cep;
    }
    setState(() {});
  }

  showSnackMsg(String msg, Color? color) {
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(backgroundColor: color, content: Text(msg)));
  }
}
