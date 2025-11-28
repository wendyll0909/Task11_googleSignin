import 'package:cloud_firestore/cloud_firestore.dart';

class ItemService {
  final CollectionReference items = FirebaseFirestore.instance.collection(
    'items',
  );

  Future addItem(String name, int quantity) async {
    return await items.add({
      'name': name,
      'quantity': quantity,
      'isFavorite': false,
    });
  }

  Stream<QuerySnapshot> getItems({bool onlyFavorites = false}) {
    if (onlyFavorites) {
      return items.where('isFavorite', isEqualTo: true).snapshots();
    }
    return items.snapshots();
  }

  Future updateItem(String id, String name, int quantity) async {
    return await items.doc(id).update({'name': name, 'quantity': quantity});
  }

  Future toggleFavorite(String id, bool current) async {
    return await items.doc(id).update({'isFavorite': !current});
  }

  Future deleteItem(String id) async {
    return await items.doc(id).delete();
  }
}
