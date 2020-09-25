import 'package:flutter/material.dart';
import 'package:todo_app/NoDoitem.dart';
import 'package:todo_app/database_helper.dart';
import 'date_formatter.dart';

class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  final TextEditingController _textEditingController = new TextEditingController();
  var db = new DatabaseHelper();
  final List<NoDoItem> _itemList = <NoDoItem>[];

  _handleSubmit(String text) async{
    NoDoItem item = new NoDoItem(text, dateFormatted());
    int saveItemId = await db.saveItem(item);
    NoDoItem addedItem = await db.getItem(saveItemId);
//    print("Item saved id : $saveItemId");
  setState(() {
    _itemList.insert(0, addedItem);
  });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _readToDoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: ListTile(
          title: Icon(Icons.add),
        ),
        onPressed: _showFormDialog,
      ),
      body: Column(
        children: <Widget>[
          Flexible(
              child: ListView.builder(
                itemCount: _itemList.length,
                padding: const EdgeInsets.all(8.0),
                reverse: false,
                itemBuilder: (_,int index){
                  return Card(
                    color: Colors.white10,
                    child: ListTile(
                      title: _itemList[index],
                      onLongPress: () {

                        _showUpdateDialog(_itemList[index],index);

                      },
                      trailing: Listener(
                        key: Key(_itemList[index].itemName),
                        child: Icon(Icons.remove_circle,
                        color: Colors.redAccent,

                        ),
                        onPointerDown: (pointerEvent) {

                          _showDeleteDialog(_itemList[index].id,index);
                        },
                      ),
                    ),

                  );

                },
              ),

          ),
          Divider(height: 1.0,)
        ],
      ),
    );


  }

  _showFormDialog() {
    var alert =  AlertDialog(
      title: Text("Enter item"),
      content: Row(
        children: <Widget>[
          Expanded(
              child:TextField(
                autofocus: true,
                controller: _textEditingController,
                decoration: InputDecoration(
                  labelText: "Item",
                  hintText: "eg. Buying grocery",
                  icon: Icon(Icons.note_add),
                ),
              ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              _handleSubmit(_textEditingController.text);
              _textEditingController.clear();
              Navigator.pop(context);
            } ,
            child: Text("Save"),
        ),
        FlatButton(
          onPressed: ()=>Navigator.pop(context) ,


          child: Text("Cancel"),
        )

      ],
    );
    showDialog(context: context,builder:(_){
      return alert;
    }

    );
  }

  _readToDoList() async{
    List items = await db.getItems();
    items.forEach((item) {
//      NoDoItem noDoItem = NoDoItem.map(items);
//      print("Db items ${noDoItem.itemName}");
    setState(() {
      _itemList.add(NoDoItem.map(item));
    });

    });
  }

  void _deleteNoDo(int id, int index) async{
    await db.deleteItem(id);
    setState(() {
      _itemList.removeAt(index);
    });

  }

  _showDeleteDialog(int id,int index) {
    var alert = AlertDialog(
      content: Row(
        children: <Widget>[
          Expanded(
            child:Text("Are you sure you want to delete this item?"),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            _deleteNoDo(id, index);
            Navigator.pop(context);
          } ,
          child: Text("Yes"),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          } ,


          child: Text("No"),
        )

      ],
    );

    showDialog(context: context,builder: (_){
      return alert;
    });
  }

  _showUpdateDialog(NoDoItem item, int index) {

    var alert = AlertDialog(
      title: Text("Update item"),
      content: Row(

        children: <Widget>[
          Expanded(
            child:TextField(
              autofocus: true,
              controller: _textEditingController,
              decoration: InputDecoration(
                labelText: "Item",
                hintText: "eg. Buying grocery",
                icon: Icon(Icons.update),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () async{
          NoDoItem updatedItem = NoDoItem.fromMap({"itemName" : _textEditingController.text,
            "dateCreated" : dateFormatted(),
            "id" : item.id});
            _handleSubmitUpdate(item,index);
            await db.updateItem(updatedItem);
            setState(() {
              _readToDoList();
            });
          _textEditingController.clear();

          Navigator.pop(context);


          } ,
          child: Text("Update"),
        ),
        FlatButton(
          onPressed: ()=>Navigator.pop(context) ,


          child: Text("Cancel"),
        )

      ],
    );
    showDialog(context: context,builder:(_){
      return alert;
    }

    );
  }

  void _handleSubmitUpdate(NoDoItem item, int index) {
   setState(() {
     _itemList.removeWhere((element){
       _itemList[index].itemName == item.itemName;
     });
   });
  }


}

