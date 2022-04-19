import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io'; //salvar dados no celular do usuário
import 'dart:async'; //
import 'dart:convert'; //converter dados json

class Home extends StatefulWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  //Lista vazia
  late List _listaTarefas = [];

  // Map para recuperar o item que está sendo excluido
  Map<String, dynamic> _ultimaTarefaRemovida = Map();

  //Instanciando o controlle tarefa
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationSupportDirectory();
    return File('${diretorio.path}/dados.json');
  }
  
  _salvarTarefa() async {
    
    String textoDigitado =  _controllerTarefa.text;

    // Criar dados
    Map<String, dynamic> tarefa = Map();
    tarefa['titulo'] = textoDigitado;
    tarefa['realizada'] = false;

    //Mostrar a tarefa na lista
    setState(() {
      _listaTarefas.add(tarefa);  
    });
    
    _salvarArquivo();
    _controllerTarefa.text = '';
  
  }

  _salvarArquivo() async {
    
    var arquivo = await _getFile();

    //Converter dados em json
    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
    //print('Caminho: ' + diretorio.path);
  }

  _lerArquivo() async {
    try{
      final arquivo = await _getFile();
      arquivo.readAsString();
    }catch(e){
      return null;
    }
  }


  Widget _criarItemLista(context, index){

    // final item não dá para ser usado para recuperar o dado
    //final item = _listaTarefas[index]['titulo'];

    return Dismissible(
      key: Key( DateTime.now().millisecondsSinceEpoch.toString() ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction){
        
        // recuperar último item excluído
        _ultimaTarefaRemovida = _listaTarefas[index];

        // Remover o item da lista e salvar a lista
        _listaTarefas.removeAt(index);
        _salvarArquivo();

        // Snackbar
        final snackbar =  SnackBar(
          //backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
          content: const Text('Tarefa removida!'),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: (){

              // Insere novamente item removido na lista
              setState(() {
                _listaTarefas.insert(index, _ultimaTarefaRemovida);  
              });              
              _salvarArquivo();


            },
          ),
        );

        Scaffold.of(context).showSnackBar(snackbar);

      },
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const <Widget>[
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      
      child: CheckboxListTile(
        title: Text(_listaTarefas[index]['titulo']),
        value: _listaTarefas[index]['realizada'], 
        onChanged: (valorAlterado){
          setState(() {
            _listaTarefas[index]['realizada'] = valorAlterado;
          });
          
          _salvarArquivo();
        },
      ),
    );
  }



  @override
  void initState(){
    super.initState();
    _lerArquivo().then((dados){
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });
  }


  @override
  Widget build(BuildContext context) {

    _salvarArquivo();
    //print('itens: ' + DateTime.now().millisecondsSinceEpoch.toString() );

    return Scaffold(


      appBar: AppBar(
        title: const Text('Lista de tarefas'),
        backgroundColor: Colors.purple
      ),



      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _listaTarefas.length,
              itemBuilder: _criarItemLista,
            ),
          )
        ],
      ),



      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: (){

          showDialog(
            context: context, 
            builder: (context){

              return AlertDialog(
                title: const Text('Adicionar Tarefa'),
                content: TextField(
                  controller: _controllerTarefa,
                  decoration: const InputDecoration(
                    labelText: 'Digite sua tarefa'
                  ),
                  onChanged: (text){
                    
                  },
                ),

                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('cancelar'),
                  ),

                  TextButton(
                    onPressed: (){
                      _salvarTarefa();
                      Navigator.pop(context);
                    },
                    child: const Text('salvar'),
                  ),

                ],
              );
            }
          );

          print('Botão pressionado');
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 6,
        //mini: false,
      ),


      // Outra opção para colocar botões
      /* floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          print('Botão pressionado');
        },
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Adicionar'), */
        /* shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        ), */
        /* 
        child: const Icon(Icons.add), 
        //mini: false,
      ),*/

      /* bottomNavigationBar: BottomAppBar(
        //shape: CircularNotchedRectangle(),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: (){}, 
              icon: const Icon(Icons.menu)
            ),
          ],
        ) 
      ), */
    );
  }
}