class Back4appModel {
  String? id;
  String? cep;
  String? logradouro;
  String? complemento;
  String? bairro;
  String? localidade;
  String? uf;
  String? estado;
  String? ddd;
  String? created;

  Back4appModel({
    this.cep,
    this.logradouro,
    this.complemento,
    this.bairro,
    this.localidade,
    this.uf,
    this.estado,
    this.ddd,
  });

  Back4appModel.fromJson(Map<String, dynamic> json) {
    id = json['objectId'];
    created = json['createdAt'];
    cep = json['cep'];
    logradouro = json['logradouro'];
    complemento = json['complemento'];
    bairro = json['bairro'];
    localidade = json['localidade'];
    uf = json['uf'];
    estado = json['estado'];
    ddd = json['ddd'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cep'] = cep;
    data['logradouro'] = logradouro;
    data['complemento'] = complemento;
    data['bairro'] = bairro;
    data['localidade'] = localidade;
    data['uf'] = uf;
    data['ddd'] = ddd;
    data['estado'] = estado;

    return data;
  }

  Map<String, dynamic> toJsonSave() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['cep'] = cep;
    data['logradouro'] = logradouro;
    data['complemento'] = complemento;
    data['bairro'] = bairro;
    data['localidade'] = localidade;
    data['uf'] = uf;
    data['estado'] = estado;

    data['ddd'] = ddd;

    return data;
  }
}
