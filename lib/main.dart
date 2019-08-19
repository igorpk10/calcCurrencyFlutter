import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:async";
import "dart:convert";

const request = "https://api.hgbrasil.com/finance?format=json&key=60df7606";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white))),
    ),
  ));
}

//Metodo de chamada da api, assyncrono
Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Controllers
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  //Variaveis 
  double dolar;
  double euro;

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  //Controlers functions area
  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar) / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = ((euro * this.euro) / dolar).toStringAsFixed(2);
  }

  //Screen Area
  @override
  Widget build(BuildContext context) {
    //Widget que permite colocar a appbar, onde voce deve inicializar o metodo title com uma appbar e o body com o que desejar :D
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text("\$ Conversor MEAN \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      // Body sendo iniciado com o FutureBuilder por causa da chamada assyncrona, para tratamento
      body: FutureBuilder<Map>(
          //Define qual o future para que o flutter saiba quais informacoes deve realizar o acompanhamento
          future: getData(),
          //Define actions para cada estado das informacoes (Pode-se criar uma loadScreen enquanto está no await)
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Loading",
                    style: TextStyle(color: Colors.lightBlue, fontSize: 30),
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error on loading D:",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 150.0,
                          color: Colors.amber,
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 30),
                            child: textField(
                                "Reais", "R\$", realController, _realChanged)),
                        Divider(),
                        textField(
                            "Dólares", "U\$", dolarController, _dolarChanged),
                        Divider(),
                        textField("Euros", "€", euroController, _euroChanged)
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget textField(String label, String prefix, TextEditingController controller,
    Function function) {
  return TextField(
    controller: controller,
    onChanged: function,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    style: TextStyle(color: Colors.greenAccent, fontSize: 30, fontWeight: FontWeight.bold),
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber, fontSize: 30),
        border: OutlineInputBorder(),
        prefixText: "$prefix "),
  );
}
