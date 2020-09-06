import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista de compras',
      home: Home(),
      theme: ThemeData(
          // hintColor: Colors.white,
          primaryColor: Colors.deepOrange[900],
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange[900])),
            hintStyle: TextStyle(color: Colors.deepOrange[900]),
          ))));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _shopList = ['Arroz', 'Feijão'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.deepOrange[100],
        appBar: AppBar(
          title: Text('Lista de Compras'),
          centerTitle: true,
          leading: Icon(Icons.add_shopping_cart),
        ),
        body: Column(
          children: [
            // responsável por dar o espaçamento onde será inserido os dados
            Container(
              padding: EdgeInsets.fromLTRB(17, 4, 7, 1),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          labelText: 'Inserir Item',
                          labelStyle: TextStyle(color: Colors.deepOrange[900])),
                      style: TextStyle(color: Colors.deepOrange[900]),
                    ),
                  ),
                  SizedBox(width: 4,),
                  RaisedButton(
                      color: Colors.deepOrange[900],
                      onPressed: () {},
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
            // Expanded é utilizado quando o widget não sabe qual o comprimento terá
            Expanded(
                //ListView - widget que cria listas
                // builder é um construtor que a lista seja construída conforme for rodando ela
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 10.0),
                    itemCount: _shopList.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        title: Text( _shopList[index]['title']),
                        value: _shopList[index]['ok'],
                        secondary: CircleAvatar(
                          child: Icon(_shopList[index]['ok'] ?
                          Icons.check : Icons.error),
                        ),
                      );
                    }))
          ],
        ));
  }

  //Função para armazenar a lista de dados
  Future<File> _getFile() async {
    // o comando getApplication... não é executado imediatamente, dessa forma, usa-se o await
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.json');
  }

  //Função para salvar a lista de dados
  Future<File> _saveData() async {
    // recebendo a lista, transformando-a em json e armazenando em uma string
    String data = json.encode(_shopList);
    //pegar o arquivo onde ele será salvo (_get file retorna um valor futuro)
    final file = await _getFile();
    //escrever a lista de dados como texto dentro do arquivo
    return file.writeAsString(data);
  }

//função para receber meus dados
  Future<String> _readData() async {
    //try catch tentar executar algo e caso esse algo der errado, será exibido um erro dentro do catch
    try {
      final file = await _getFile();
      // tentar ler o arquivo como string
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
