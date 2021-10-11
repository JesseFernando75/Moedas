import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

var url = Uri.https(
    'api.hgbrasil.com', '/finance', {'?': 'format=json&key=9843c585'});

void main() async {
  print(await buscaDados());
  runApp(MaterialApp(home: Home()));
}

Future<Map> buscaDados() async {
  var response = await http.get(url);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realControl = TextEditingController();
  final dolarControl = TextEditingController();
  final euroControl = TextEditingController();
  final libraControl = TextEditingController();

  double dolar = 0, euro = 0, libra = 0;

  void _clearAll() {
    realControl.text = "";
    dolarControl.text = "";
    euroControl.text = "";
    libraControl.text = "";
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dolarControl.text = (real / dolar).toStringAsFixed(2);
    euroControl.text = (real / euro).toStringAsFixed(2);
    libraControl.text = (real / libra).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    realControl.text = (dolar * this.dolar).toStringAsFixed(2);
    euroControl.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    libraControl.text = (dolar * this.dolar / libra).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double euro = double.parse(text);
    realControl.text = (euro * this.euro).toStringAsFixed(2);
    dolarControl.text = (euro * this.euro / dolar).toStringAsFixed(2);
    libraControl.text = (euro * this.euro / libra).toStringAsFixed(2);
  }

  void _libraChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double libra = double.parse(text);
    realControl.text = (libra * this.libra).toStringAsFixed(2);
    dolarControl.text = (libra * this.libra / dolar).toStringAsFixed(2);
    euroControl.text = (libra * this.libra / euro).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: Text("Conversor de moedas"),
        backgroundColor: Colors.blueGrey[800],
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: buscaDados(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                    child: Text(
                  "Carregando",
                  style: TextStyle(color: Colors.blueGrey[800], fontSize: 25),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                    "Erro ao carregar",
                    style:
                        TextStyle(color: Colors.redAccent[700], fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                } else {
                  dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                  libra = snapshot.data!["results"]["currencies"]["GBP"]["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.monetization_on_outlined,
                            size: 150.0, color: Colors.white),
                        Divider(
                          height: 25,
                        ),
                        gerarCampoTexto(
                            "Real", "R\$  ", realControl, _realChanged),
                        Divider(
                          height: 25,
                        ),
                        gerarCampoTexto(
                            "Dólar", "US\$  ", dolarControl, _dolarChanged),
                        Divider(
                          height: 25,
                        ),
                        gerarCampoTexto(
                            "Euro", "EUR\€  ", euroControl, _euroChanged),
                        Divider(
                          height: 25,
                        ),
                        gerarCampoTexto("Libra esterlina", "£  ", libraControl,
                            _libraChanged),
                        Divider(
                          height: 25,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blueGrey[800],
                            padding: const EdgeInsets.all(16.0),
                            primary: Colors.white,
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          onPressed: () => _clearAll(),
                          child: const Text('Limpar'),
                        ),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget gerarCampoTexto(String label, String prefix, TextEditingController value,
    Function changed) {
  return TextField(
    controller: value,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.all(12),
      labelText: label,
      labelStyle: TextStyle(color: Colors.white, fontSize: 18.0),
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 0.0)),
      prefixText: prefix,
      prefixStyle: TextStyle(color: Colors.white, fontSize: 18.0),
    ),
    style: TextStyle(color: Colors.white, fontSize: 25.0),
    onChanged: changed as void Function(String)?,
    keyboardType: TextInputType.number,
  );
}
