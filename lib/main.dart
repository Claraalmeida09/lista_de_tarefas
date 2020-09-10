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
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _toDoController = TextEditingController();

  List _shopList = [];

  Map<String, dynamic> _lastRemoved;

  //para sabermos de que posição foi deletado
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _shopList = json.decode(data);
      });
    });
  }

  // criar função para adicionar item na lista
  void _addToDo() {
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      setState(() {
        //pegar o que estiver escrito no inserir item e add na lista
        Map<String, dynamic> newShop = Map();
        newShop['title'] = _toDoController.text;
        _toDoController.text = '';
        newShop['ok'] = false;
        _shopList.add(newShop);
        _saveData();
      });
    }

  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _shopList.sort((a, b) {
        if (a['ok'] && !b['ok'])
          return 1;
        else if (!a['ok'] && b['ok'])
          return -1;
        else
          return 0;
      });
      _saveData();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
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
                child: Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: _toDoController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Insira um item';
                            }
                          },
                          decoration: InputDecoration(
                              labelText: 'Inserir Item',
                              labelStyle:
                                  TextStyle(color: Colors.deepOrange[900])),
                          style: TextStyle(color: Colors.deepOrange[900]),
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      RaisedButton(
                          color: Colors.deepOrange[900],
                          //Chamando a função add do botão
                          onPressed: _addToDo,
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          )),
                    ],
                  ),
                )),
            // Expanded é utilizado quando o widget não sabe qual o comprimento terá
            Expanded(
                //ListView - widget que cria listas
                // builder é um construtor que a lista seja construída conforme for rodando ela
                child: RefreshIndicator(
                    child: ListView.builder(
                        padding: EdgeInsets.only(top: 10.0),
                        itemCount: _shopList.length,
                        itemBuilder: buildItem),
                    onRefresh: _refresh))
          ],
        ));
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        // add o ícone do tipo align para que ele não fique centralizado,
        // responsável pelo alinhamento no lado esquerdo
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        activeColor: Colors.deepOrange[900],
        title: Text(_shopList[index]['title']),
        value: _shopList[index]['ok'],
        secondary: CircleAvatar(
          backgroundColor: Colors.deepOrange[900],
          child: Icon(_shopList[index]['ok'] ? Icons.check : Icons.error),
          //chama uma função quando há variação true ou falso
        ),
        onChanged: (c) {
          setState(() {
            _shopList[index]['ok'] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_shopList[index]);
          _lastRemovedPos = index;
          _shopList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text('Item \"${_lastRemoved['title']}\" removido!'),
            action: SnackBarAction(
                label: 'Desfazer',
                onPressed: () {
                  setState(() {
                    _shopList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                }),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
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
