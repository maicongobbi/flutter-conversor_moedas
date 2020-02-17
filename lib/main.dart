import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'dart:async';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=c746bd10";

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

double dolar;
double euro;
double atualDolar;
double atualEuro;
final realController = TextEditingController();
final dolarController = TextEditingController();
final euroController = TextEditingController();

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //barra de cima
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Conversor de Moedas"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          //é  map pq o json vira como map
          future: getData(), //quem vai servir o futurebuilder com dados

          builder: (context, snapshot) {
            //builder mostrará na tela o que acontece enquanto carrega
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return centralizadoTexto("carregando...");
                break;

              default:
                //qdo terminar de carregar
                if (snapshot.hasError) {
                  return centralizadoTexto("erro ao carregar dados =(");
                } else {
                  dolar = getDolar(snapshot);
                  euro = getEuro(snapshot);
                  atualDolar = dolar;
                  atualEuro = euro;
                  return scroll();
                }
            }
          }),
    );
  }
}

SingleChildScrollView scroll() {
  return SingleChildScrollView(
    padding: EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        icon,
        campoTexto("Real", ""),
        Divider(),
        campoTexto("Dólares", atualDolar.toStringAsPrecision(3)),
        Divider(),
        campoTexto("Euros", euro.toStringAsPrecision(3))
      ],
    ),
  );
}

Icon get icon {
  return Icon(
    Icons.monetization_on,
    size: 150,
    color: Colors.amber,
  );
}

void _clearAll() {
  realController.text = "";
  dolarController.text = "";
  euroController.text = "";
}

TextField campoTexto(String label, String valorAtual) {
  return TextField(
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    controller: label == "Real"
        ? realController
        : label == "Dólares" ? dolarController : euroController,
    onChanged: label == "Real"
        ? _realChanged
        : label == "Dólares" ? _dolarChanged : _euroChanged,
    decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 10),
        labelText: label + " - " + valorAtual,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText:
            label == "Real" ? "R\$: " : label == "Dólares" ? "USD: " : "EUR: "),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
  );
}

void _realChanged(String text) {
  if (text.isEmpty) {
    _clearAll();
    return;
  }

  double real = double.parse(text);
  dolarController.text = (real / dolar).toStringAsPrecision(3);
  euroController.text = (real / euro).toStringAsPrecision(3);
}

void _dolarChanged(String text) {
  if (text.isEmpty) {
    _clearAll();
    return;
  }
  double dola = double.parse(text);
  realController.text = (dola * dolar).toStringAsPrecision(3);
  euroController.text = (dola * dolar / euro).toStringAsPrecision(3);
}

void _euroChanged(String text) {
  if (text.isEmpty) {
    _clearAll();
    return;
  }
  double euros = double.parse(text);
  realController.text = (euro * euros).toStringAsPrecision(3);
  dolarController.text = (euro * euros / dolar).toStringAsPrecision(3);
}

Text mensagem(String mensagem) {
  print("mensagem" + mensagem);
  return Text(mensagem,
      style: TextStyle(color: Colors.amber, fontSize: 25),
      textAlign: TextAlign.center);
}

Center centralizadoTexto(mensagem) {
  print("texto centralizado" + mensagem);
  return Center(
      child: Text(mensagem,
          style: TextStyle(color: Colors.amber, fontSize: 25),
          textAlign: TextAlign.center));
}

double getDolar(AsyncSnapshot snap) {
  return snap.data["results"]["currencies"]["USD"]["buy"];
}

double getEuro(AsyncSnapshot snap) {
  return snap.data["results"]["currencies"]["EUR"]["buy"];
}

void main() async {
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white))))));
} //fim main

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

/* theme: ThemeData(
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white))
  )
) */
