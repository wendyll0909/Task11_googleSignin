import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_firebase/auth_service.dart';
import 'service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final service = ItemService();
  bool showFavorites = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("Task11_Erosido"),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              showFavorites ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                showFavorites = !showFavorites;
              });
            },
          ),

          IconButton(
  icon: Icon(Icons.logout, color: Colors.white),
  onPressed: () async {
    await AuthService().signOut();
    // Remove the SnackBar completely
    // The StreamBuilder in main.dart will automatically switch to LoginPage
  },
),
        ],
      ),

      body: StreamBuilder(
        stream: service.getItems(onlyFavorites: showFavorites),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((item) {
              final id = item.id;
              final data = item.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(data['name']),
                  subtitle: Text("Quantity: ${data['quantity']}"),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          data['isFavorite']
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          service.toggleFavorite(id, data['isFavorite']);
                        },
                      ),

                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          openEditDialog(context, item);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          service.deleteItem(id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => openAddDialog(context),
      ),
    );
  }

  void openAddDialog(BuildContext context) {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController qtyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: qtyCtrl,
                decoration: InputDecoration(labelText: "Quantity"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                service.addItem(nameCtrl.text, int.parse(qtyCtrl.text));
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void openEditDialog(BuildContext context, DocumentSnapshot item) {
    TextEditingController nameCtrl = TextEditingController(text: item['name']);
    TextEditingController qtyCtrl = TextEditingController(
      text: item['quantity'].toString(),
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Edit item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: qtyCtrl,
                decoration: InputDecoration(labelText: "Quantity"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                service.updateItem(
                  item.id,
                  nameCtrl.text,
                  int.parse(qtyCtrl.text),
                );
                Navigator.pop(context);
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }
}
